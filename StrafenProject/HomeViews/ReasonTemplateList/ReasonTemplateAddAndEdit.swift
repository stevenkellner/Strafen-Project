//
//  ReasonTemplateAddAndEdit.swift
//  StrafenProject
//
//  Created by Steven on 28.04.23.
//

import SwiftUI

struct ReasonTemplateAddAndEdit: View {
    
    @Environment(\.dismiss) private var dismiss
        
    @EnvironmentObject private var appProperties: AppProperties
    
    private let reasonTemplateToEdit: ReasonTemplate?
    
    @State private var reasonMessage = ""
    
    @State private var amount: Amount = .zero
        
    @State private var showUnknownErrorAlert = false
    
    init(reasonTemplate reasonTemplateToEdit: ReasonTemplate? = nil) {
        self.reasonTemplateToEdit = reasonTemplateToEdit
        if let reasonTemplateToEdit {
            self._reasonMessage = State(initialValue: reasonTemplateToEdit.reasonMessage)
            self._amount = State(initialValue: reasonTemplateToEdit.amount)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(String(localized: "reason-template-add-and-edit|reason-message-textfield", comment: "Reason message textfield placeholder in reason template add and edit."), text: self.$reasonMessage)
                } header: {
                    Text("reason-template-add-and-edit|reason-message-textfield", comment: "Reason message textfield placeholder in reason template add and edit.")
                }
                Section {
                    TextField(String(localized: "reason-template-add-and-edit|amount-textfield", comment: "Amount textfield placeholder in reason template add and edit."), value: self.$amount, format: .amount)
                } header: {
                    Text("reason-template-add-and-edit|amount-textfield", comment: "Amount textfield placeholder in reason template add and edit.")
                }
            }.navigationTitle(String(localized: "reason-template-add-and-edit|title", comment: "Navigation title of reason template add and edit."))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(self.toolbar)
        }.alert(self.unknownErrorAlertTitle, isPresented: self.$showUnknownErrorAlert) {
            Button {} label: {
                Text("got-it-button", comment: "Text of a 'got it' button.")
            }            
        }
    }
    
    @ToolbarContentBuilder var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                self.dismiss()
            } label: {
                Text("cancel-button", comment: "Text of cancel button.")
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                Task {
                    await self.saveReasonTemplate()
                }
            } label: {
                Text(self.reasonTemplateToEdit == nil ? String(localized: "reason-template-add-and-edit|add-button", comment: "Add reason template button in reason template add and edit.") : String(localized: "reason-template-add-and-edit|save-button", comment: "Save reason template button in reason template add and edit."))
            }.disabled(self.reasonMessage == "" || self.amount == .zero)
        }
    }
    
    private var unknownErrorAlertTitle: String {
        if self.reasonTemplateToEdit == nil {
            return String(localized: "reason-template-add-and-edit|unknown-error-alert|cannot-add-title", comment: "Cannot add reason template alert title in reason template add and edit.")
        }
        return String(localized: "reason-template-add-and-edit|unknown-error-alert|cannot-save-title", comment: "Cannot save reason template alert title in reason template add and edit.")
    }
        
    private func saveReasonTemplate() async {
        do {
            let reasonTemplateId = self.reasonTemplateToEdit?.id ?? ReasonTemplate.ID()
            let reasonTemplate = ReasonTemplate(id: reasonTemplateId, reasonMessage: self.reasonMessage, amount: self.amount)
            let reasonTemplateEditFunction: ReasonTemplateEditFunction
            if self.reasonTemplateToEdit == nil {
                reasonTemplateEditFunction = .add(clubId: self.appProperties.club.id, reasonTemplate: reasonTemplate)
            } else {
                reasonTemplateEditFunction = .update(clubId: self.appProperties.club.id, reasonTemplate: reasonTemplate)
            }
            try await FirebaseFunctionCaller.shared.call(reasonTemplateEditFunction)
            self.appProperties.reasonTemplates[reasonTemplateId] = reasonTemplate
            self.reset()
            self.dismiss()
        } catch {
            self.showUnknownErrorAlert = true
        }
    }
    
    private func reset() {
        self.reasonMessage = ""
        self.amount = .zero
    }
}
