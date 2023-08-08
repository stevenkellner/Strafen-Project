//
//  FineAddAndEdit.swift
//  StrafenProject
//
//  Created by Steven on 28.04.23.
//

import SwiftUI

struct FineAddAndEdit: View {
    enum Referrer {
        case addNewTab
        case addNewFineList
        case updateFine
    }
    
    @Environment(\.redactionReasons) private var redactionReasons
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @EnvironmentObject private var imageStorage: FirebaseImageStorage
    
    private let fineToEdit: Fine?
    
    private let referrer: Referrer
    
    @State private var personIds: [Person.ID] = []
    
    @State private var payedState: PayedState = .unpayed
    
    @State private var date = Date()
    
    @State private var reasonMessage: String?
    
    @State private var counts: ReasonTemplate.Counts?
    
    @State private var count = 1
    
    @State private var amount: Amount?
    
    @State private var isPickPersonSheetShown = false
    
    @State private var isPickReasonTemplateSheetShown = false
    
    @State private var showUnknownErrorAlert = false
    
    @State private var isAddAndEditButtonLoading = false
    
    init(fine fineToEdit: Fine? = nil, referrer: Referrer) {
        self.fineToEdit = fineToEdit
        self.referrer = referrer
        if let fineToEdit {
            self._personIds = State(initialValue: [fineToEdit.personId])
            self._payedState = State(initialValue: fineToEdit.payedState)
            self._date = State(initialValue: fineToEdit.date.date)
            self._reasonMessage = State(initialValue: fineToEdit.reasonMessage)
            self._amount = State(initialValue: fineToEdit.amount)
        }
    }
    
    init(personId: Person.ID, referrer: Referrer) {
        self.fineToEdit = nil
        self.referrer = referrer
        self._personIds = State(initialValue: [personId])
    }
    
    var body: some View {
        NavigationView {
            Form {
                if self.referrer != .updateFine {
                    Section {
                        Button {
                            self.isPickPersonSheetShown = true
                        } label: {
                            if let personId = self.personIds.first,
                               let personName = self.personName(of: personId) {
                                HStack {
                                    if let image = self.imageStorage.personImages[personId] {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 30, height: 30)
                                            .clipShape(Circle())
                                    }
                                    if self.personIds.count >= 2, let secondPersonName = self.personName(of: self.personIds[1]) {
                                        Text("fine-add-and-edit|multiple-persons-selected?first-person-name=\(personName.formatted())&second-person-name=\(secondPersonName.formatted())&other-persons-count\(self.personIds.count - 2)", comment: "Multiple persons selected text in fine add and edit.")
                                    } else {
                                        Text(personName.formatted())
                                    }
                                }.foregroundColor(.primary)
                            } else {
                                Text("fine-add-and-edit|pick-person-button", comment: "Pick person button in fine add and edit.")
                                    .unredacted()
                            }
                        }.disabled(self.referrer == .addNewFineList || self.redactionReasons.contains(.placeholder))
                    }.sheet(isPresented: self.$isPickPersonSheetShown) {
                        FinePickPerson(personIds: self.$personIds)
                    }.task {
                        if let personId = self.personIds.first {
                            await self.imageStorage.fetch(.person(clubId: self.appProperties.club.id, personId: personId))
                        }
                    }.onChange(of: self.personIds) { personIds in
                        Task {
                            if let personId = personIds.first {
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
                                Text((self.counts == nil ? amount : (amount * self.count)).formatted(.short))
                                    .foregroundColor(.red)
                            }.foregroundColor(.primary)
                        } else {
                            Text("fine-add-and-edit|pick-reason-template-button", comment: "Pick reason template in fine add and edit.")
                                .unredacted()
                        }
                    }.disabled(self.redactionReasons.contains(.placeholder))
                    if let counts = self.counts {
                        Stepper(counts.item.formatted(count: self.count), value: self.$count, in: 1...(counts.maxCount ?? 1000))
                    }
                }.sheet(isPresented: self.$isPickReasonTemplateSheetShown) {
                    FinePickReasonTemplate(reasonMessage: self.$reasonMessage, amount: self.$amount, counts: self.$counts)
                }
                Section {
                    if self.referrer == .updateFine {
                        Toggle(String(localized: "fine-add-and-edit|payed-toggle-text", comment: "Text before payed toggle in fine add and edit."), isOn: self.isFinePayed)
                            .toggleStyle(.switch)
                    }
                    DatePicker(String(localized: "fine-add-and-edit|date-text", comment: "Text before date picker in fine add and edit."), selection: self.$date, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }.disabled(self.redactionReasons.contains(.placeholder))
            }.modifier(self.rootModifiers)
        }
    }
    
    @ModifierBuilder private var rootModifiers: some ViewModifier {
        NavigationTitleModifier(localized: LocalizedStringResource("fine-add-and-edit|title", comment: "Navigation title of fine add and edit."), displayMode: self.referrer == .addNewTab ? .large : .inline)
        ToolbarModifier(content: self.toolbar)
        let unknownErrorAlertTitle = self.fineToEdit == nil ?
            String(localized: "fine-add-and-edit|unknown-error-alert|cannot-add-title", comment: "Cannot add fine alert title in fine add and edit.") :
            String(localized: "fine-add-and-edit|unknown-error-alert|cannot-save-title", comment: "Cannot save fine alert title in fine add and edit.")
        AlertModifier(unknownErrorAlertTitle, isPresented: self.$showUnknownErrorAlert) {
            Button {} label: {
                Text("got-it-button", comment: "Text of a 'got it' button.")
            }
        }
    }
    
    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        if self.referrer != .addNewTab {
            ToolbarButton(placement: .topBarLeading, localized: LocalizedStringResource("cancel-button", comment: "Text of cancel button.")) {
                self.dismiss()
            }
        }
        ToolbarButton(placement: .topBarTrailing, localized: self.fineToEdit == nil ? LocalizedStringResource("fine-add-and-edit|add-button", comment: "Add fine button in fine add and edit.") : LocalizedStringResource("fine-add-and-edit|save-button", comment: "Save fine button in fine add and edit.")) {
            await self.saveFine()
        }.loading(self.isAddAndEditButtonLoading)
            .disabled(self.redactionReasons.contains(.placeholder) || self.personIds == [] || self.reasonMessage?.isEmpty ?? true || self.amount == nil || self.amount == .zero)
            .unredacted
    }
    
    private func personName(of personId: Person.ID) -> PersonName? {
        return self.appProperties.persons[personId]?.name
    }
    
    private var isFinePayed: Binding<Bool> {
        return Binding {
            return self.payedState == .payed
        } set: { isPayed in
            self.payedState = isPayed ? .payed : .unpayed
        }
    }
        
    private func saveFine() async {
        self.isAddAndEditButtonLoading = true
        defer {
            self.isAddAndEditButtonLoading = false
        }
        guard !self.personIds.isEmpty,
              var reasonMessage = self.reasonMessage,
              var amount = self.amount else {
            return
        }
        if let counts = self.counts {
            reasonMessage = "\(reasonMessage) (\(counts.item.formatted(count: self.count)))"
            amount *= self.count
        }
        do {
            try await withThrowingTaskGroup(of: Void.self) { [reasonMessage, amount] taskGroup in
                for personId in self.personIds {
                    taskGroup.addTask {
                        try await self.saveFine(personId: personId, reasonMessage: reasonMessage, amount: amount)
                    }
                }
                try await taskGroup.waitForAll()
            }
            self.reset()
            self.dismiss()
        } catch {
            self.showUnknownErrorAlert = true
        }
    }
    
    private func saveFine(personId: Person.ID, reasonMessage: String, amount: Amount) async throws {
        let fineId = self.fineToEdit?.id ?? Fine.ID()
        let fine = Fine(id: fineId, personId: personId, payedState: self.payedState, date: UtcDate(self.date), reasonMessage: reasonMessage, amount: amount)
        if self.fineToEdit == nil {
            let fineAddFunction = FineAddFunction(clubId: self.appProperties.club.id, fine: fine)
            try await FirebaseFunctionCaller.shared.call(fineAddFunction)
        } else {
            let fineUpdateFunction = FineUpdateFunction(clubId: self.appProperties.club.id, fine: fine)
            try await FirebaseFunctionCaller.shared.call(fineUpdateFunction)
        }
        self.personIds = self.personIds.filter { $0 != personId }
        self.appProperties.fines[fineId] = fine
        if let containsFineId = self.appProperties.persons[personId]?.fineIds.contains(fineId), !containsFineId {
            self.appProperties.persons[personId]?.fineIds.append(fineId)
        }
        if self.fineToEdit == nil, let personName = self.personName(of: personId) {
            Task {
                let notificationPayload = NotificationPayload(title: String(localized: "fine-add-and-edit|new-fine-notification|title?name=\(personName.first)", comment: "Title of the notification send when a new fine is created. 'name' parameter is the name of the person of this fine."), body: "\(amount.formatted(.short)) | \(reasonMessage)")
                let notificationPushFunction = NotificationPushFunction(clubId: self.appProperties.club.id, personId: personId, payload: notificationPayload)
                try? await FirebaseFunctionCaller.shared.call(notificationPushFunction)
            }
        }
    }
    
    private func reset() {
        if referrer == .addNewTab {
            self.personIds = []
        }
        if referrer == .updateFine {
            self.payedState = .unpayed
        } else {
            self.date = Date()
            self.reasonMessage = nil
            self.amount = nil
        }
        self.counts = nil
        self.count = 1
    }
}
