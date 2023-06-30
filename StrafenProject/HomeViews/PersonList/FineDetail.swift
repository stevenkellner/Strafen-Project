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
    
    private let personName: PersonName
    
    @State private var isEditFineSheetShown = false
    
    init(_ fine: Binding<Fine>, personName: PersonName) {
        self._fine = fine
        self.personName = personName
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("fine-detail|fine-of-person", comment: "Text before the person name of the fine.")
                    Spacer()
                    Text(self.personName.formatted())
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
                    Text(self.fine.amount.formatted(.short))
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
        }.modifier(self.rootModifiers)
    }
    
    @ModifierBuilder private var rootModifiers: some ViewModifier {
        DismissHandlerModifier()
        NavigationTitleModifier(self.fine.reasonMessage, displayMode: .large)
        if self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder) {
            ToolbarModifier {
                ToolbarButton(placement: .topBarTrailing, localized: LocalizedStringResource("edit-button", comment: "Text of the edit button.")) {
                    self.isEditFineSheetShown = true
                }
            }
            SheetModifier(isPresented: self.$isEditFineSheetShown) {
                FineAddAndEdit(fine: self.fine, referrer: .updateFine)
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
