//
//  FineDetail.swift
//  StrafenProject
//
//  Created by Steven on 27.04.23.
//

import SwiftUI

struct FineDetail: View {
    
    @Environment(\.redactionReasons) private var redactionReasons
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @Binding private var fine: Fine
    
    private let person: Person
    
    @State private var isEditFineSheetShown = false
    
    init(_ fine: Binding<Fine>, person: Person) {
        self._fine = fine
        self.person = person
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("fine-detail|fine-of-person", comment: "Text before the person name of the fine.")
                    Spacer()
                    Text(self.person.name.formatted())
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("fine-detail|fine", comment: "Text before the reason message of the fine.")
                    Spacer()
                    Text(self.fine.reasonMessage)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text(self.fine.payedState == .payed ? String(localized: "fine-detail|payed-amount", comment: "Text before the payed amount of the fine.") : String(localized: "fine-detail|unpayed-amount", comment: "Text before the unpayed amount of the fine."))
                    Spacer()
                    Text(self.fine.amount.formatted)
                        .foregroundColor(self.fine.payedState == .payed ? .green : .red)
                }
                HStack {
                    Text("fine-detail|date", comment: "Text before the date of the fine.")
                    Spacer()
                    Text(self.fine.date.formatted(date: .long, time: .omitted))
                        .foregroundColor(.secondary)
                }
            }
            if self.appProperties.signedInPerson.isAdmin {
                Button {
                    Task {
                        await self.editPayedState()
                    }
                } label: {
                    Text(self.fine.payedState == .unpayed ? String(localized: "fine-detail|mark-as-payed-button", comment: "Mark the fine as payed button.") : String(localized: "fine-detail|already-payed-button", comment: "Fine is already payed button."))
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                }.disabled(self.fine.payedState == .payed)
            }
        }.navigationTitle(self.fine.reasonMessage)
            .navigationBarTitleDisplayMode(.large)
            .if(self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder)) { view in
                view.toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.isEditFineSheetShown = true
                        } label: {
                            Text("edit-button", comment: "Text of the edit button.")
                        }
                    }
                }
                .sheet(isPresented: self.$isEditFineSheetShown) {
                    FineAddAndEdit(fine: self.fine, shownOnSheet: true)
                }
            }
    }
    
    private func editPayedState() async {
        let previousPayedState = self.fine.payedState
        do {
            let payedState: PayedState = self.fine.payedState == .payed ? .unpayed : .payed
            self.appProperties.fines[self.fine.id]?.payedState = payedState
            let fineEditPayedFunction = FineEditPayedFunction(clubId: self.appProperties.club.id, fineId: self.fine.id, payedState: payedState)
            try await FirebaseFunctionCaller.shared.call(fineEditPayedFunction)
        } catch {
            self.appProperties.fines[self.fine.id]?.payedState = previousPayedState
        }
    }
}
