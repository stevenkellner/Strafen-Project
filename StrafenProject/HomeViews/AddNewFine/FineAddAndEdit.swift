//
//  FineAddAndEdit.swift
//  StrafenProject
//
//  Created by Steven on 28.04.23.
//

import SwiftUI

struct FineAddAndEdit: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @EnvironmentObject private var imageStorage: FirebaseImageStorage
    
    private let fineToEdit: Fine?
    
    private let shownOnSheet: Bool
    
    @State private var personId: Person.ID?
    
    @State private var payedState: PayedState = .unpayed
    
    @State private var date = Date()
    
    @State private var reasonMessage: String?
    
    @State private var amount: Amount?
    
    @State private var isPickPersonSheetShown = false
    
    @State private var isPickReasonTemplateSheetShown = false
    
    @State private var showUnknownErrorAlert = false
    
    init(fine fineToEdit: Fine? = nil, shownOnSheet: Bool) {
        self.fineToEdit = fineToEdit
        self.shownOnSheet = shownOnSheet
        if let fineToEdit {
            self._personId = State(initialValue: fineToEdit.personId)
            self._payedState = State(initialValue: fineToEdit.payedState)
            self._date = State(initialValue: fineToEdit.date)
            self._reasonMessage = State(initialValue: fineToEdit.reasonMessage)
            self._amount = State(initialValue: fineToEdit.amount)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                if self.fineToEdit == nil {
                    Section {
                        Button {
                            self.isPickPersonSheetShown = true
                        } label: {
                            if let personId = self.personId,
                               let personName = self.personName {
                                HStack {
                                    if let image = self.imageStorage.personImages[personId] {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 30, height: 30)
                                            .clipShape(Circle())
                                    }
                                    Text(personName.formatted())
                                }.foregroundColor(.primary)
                            } else {
                                Text("fine-add-and-edit|pick-person-button", comment: "Pick person button in fine add and edit.")
                            }
                        }
                    }.sheet(isPresented: self.$isPickPersonSheetShown) {
                        FinePickPerson(personId: self.$personId)
                    }.task {
                        if let personId = self.personId {
                            await self.imageStorage.fetch(.person(clubId: self.appProperties.club.id, personId: personId))
                        }
                    }.onChange(of: self.personId) { personId in
                        Task {
                            if let personId {
                                await self.imageStorage.fetch(.person(clubId: self.appProperties.club.id, personId: personId))
                            }
                        }
                    }
                }
                Section {
                    Button {
                        self.isPickReasonTemplateSheetShown = true
                    } label: {
                        if let reasonMessage = self.reasonMessage,
                           let amount = self.amount {
                            HStack {
                                Text(reasonMessage)
                                Spacer()
                                Text(amount.formatted)
                                    .foregroundColor(.red)
                            }.foregroundColor(.primary)
                        } else {
                            Text("fine-add-and-edit|pick-reason-template-button", comment: "Pick reason template in fine add and edit.")
                        }
                    }
                }.sheet(isPresented: self.$isPickReasonTemplateSheetShown) {
                    FinePickReasonTemplate(reasonMessage: self.$reasonMessage, amount: self.$amount)
                }
                Section {
                    if self.fineToEdit != nil {
                        Toggle(String(localized: "fine-add-and-edit|payed-toggle-text", comment: "Text before payed toggle in fine add and edit."), isOn: self.isFinePayed)
                            .toggleStyle(.switch)
                    }
                    DatePicker(String(localized: "fine-add-and-edit|date-text", comment: "Text before date picker in fine add and edit."), selection: self.$date, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
            }.navigationTitle(String(localized: "fine-add-and-edit|title", comment: "Navigation title of fine add and edit."))
                .navigationBarTitleDisplayMode(self.shownOnSheet ? .inline : .large)
                .toolbar(self.toolbar)
        }.alert(self.unknownErrorAlertTitle, isPresented: self.$showUnknownErrorAlert) {
            Button {} label: {
                Text("got-it-button", comment: "Text of a 'got it' button.")
            }
        }
    }
    
    @ToolbarContentBuilder var toolbar: some ToolbarContent {
        if self.shownOnSheet {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    self.dismiss()
                } label: {
                    Text("cancel-button", comment: "Text of cancel button.")
                }
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                Task {
                    await self.saveFine()
                }
            } label: {
                Text(self.fineToEdit == nil ? String(localized: "fine-add-and-edit|add-button", comment: "Add fine button in fine add and edit.") : String(localized: "fine-add-and-edit|save-button", comment: "Save fine button in fine add and edit."))
            }.disabled(self.personId == nil || self.reasonMessage?.isEmpty ?? true || self.amount == nil || self.amount == .zero)
        }
    }
    
    private var personName: Person.PersonName? {
        guard let personId = self.personId else {
            return nil
        }
        return self.appProperties.persons[personId]?.name
    }
    
    private var isFinePayed: Binding<Bool> {
        return Binding {
            return self.payedState == .payed
        } set: { isPayed in
            self.payedState = isPayed ? .payed : .unpayed
        }

    }
    
    private var unknownErrorAlertTitle: String {
        if self.fineToEdit == nil {
            return String(localized: "fine-add-and-edit|unknown-error-alert|cannot-add-title", comment: "Cannot add fine alert title in fine add and edit.")
        }
        return String(localized: "fine-add-and-edit|unknown-error-alert|cannot-save-title", comment: "Cannot save fine alert title in fine add and edit.")
    }
    
    private func saveFine() async {
        guard let personId = self.personId,
              let reasonMessage = self.reasonMessage,
              let amount = self.amount else {
            return
        }
        do {
            let fineId = self.fineToEdit?.id ?? Fine.ID()
            let fine = Fine(id: fineId, personId: personId, payedState: self.payedState, date: self.date, reasonMessage: reasonMessage, amount: amount)
            let fineEditFunction: FineEditFunction
            if self.fineToEdit == nil {
                fineEditFunction = .add(clubId: self.appProperties.club.id, fine: fine)
            } else {
                fineEditFunction = .update(clubId: self.appProperties.club.id, fine: fine)
            }
            try await FirebaseFunctionCaller.shared.call(fineEditFunction)
            self.appProperties.fines[fineId] = fine
            self.reset()
            self.dismiss()
        } catch {
            self.showUnknownErrorAlert = true
        }
    }
    
    private func reset() {
        self.personId = nil
        self.payedState = .unpayed
        self.date = Date()
        self.reasonMessage = nil
        self.amount = nil
    }
}
