//
//  ReasonTemplateAddAndEdit.swift
//  StrafenProject
//
//  Created by Steven on 28.04.23.
//

import SwiftUI

struct ReasonTemplateAddAndEdit: View {
    private enum InputFocus {
        case reasonMessage
    }
    
    @Environment(\.dismiss) private var dismiss
        
    @EnvironmentObject private var appProperties: AppProperties
    
    private let reasonTemplateToEdit: ReasonTemplate?
    
    @State private var reasonMessage = ""
    
    @State private var countsItem: ReasonTemplate.Counts.Item?
    
    @State private var maxCount: Int = 0
    
    @State private var amount: FineAmount = .amount(.zero)
        
    @State private var showUnknownErrorAlert = false
    
    @State private var isAddAndEditButtonLoading = false
    
    @FocusState private var inputFocus: InputFocus?
    
    init(reasonTemplate reasonTemplateToEdit: ReasonTemplate? = nil) {
        self.reasonTemplateToEdit = reasonTemplateToEdit
        if let reasonTemplateToEdit {
            self._reasonMessage = State(initialValue: reasonTemplateToEdit.reasonMessage)
            self._countsItem = State(initialValue: reasonTemplateToEdit.counts?.item)
            self._maxCount = State(initialValue: reasonTemplateToEdit.counts?.maxCount ?? 0)
            self._amount = State(initialValue: reasonTemplateToEdit.amount)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(String(localized: "reason-template-add-and-edit|reason-message-textfield", comment: "Reason message textfield placeholder in reason template add and edit."), text: self.$reasonMessage)
                        .focused(self.$inputFocus, equals: .reasonMessage)
                        .onChange(of: self.inputFocus) { _ in
                            self.reasonMessage = self.reasonMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    Picker(String(localized: "reason-template-add-and-edit|counts-item-picker", comment: "Counts item picker description in reason template add and edit"), selection: self.$countsItem) {
                        Text("reason-template-add-and-edit|counts-item-none", comment: "Counts item option for no repetition in reason template add and edit.")
                            .tag(nil as ReasonTemplate.Counts.Item?)
                        ForEach(ReasonTemplate.Counts.Item.allCases, id: \.self) { item in
                            Text(item.formatted)
                                .tag(item as ReasonTemplate.Counts.Item?)
                        }
                    }
                    if self.countsItem != nil {
                        Stepper(self.maxCount == 0 ? String(localized: "reason-template-add-and-edit|max-counts-none", comment: "No max count is specified for reason template counts in reason template add and edit.") : String(localized: "reason-template-add-and-edit|max-count-desciption?max-count=\(self.maxCount)", comment: "Max count description for reason template counts in reason template add and edit. 'max-count' parameter is the max count."), value: self.$maxCount, in: 0...1000)
                    }
                }
                FineAmountInput(fineAmount: self.$amount)
            }.modifier(self.rootModifiers)
        }
    }
    
    @ModifierBuilder private var rootModifiers: some ViewModifier {
        NavigationTitleModifier(localized: LocalizedStringResource("reason-template-add-and-edit|title", comment: "Navigation title of reason template add and edit."), displayMode: .inline)
        ToolbarModifier(content: self.toolbar)
        let unknownErrorAlertTitle = self.reasonTemplateToEdit == nil ?
            String(localized: "reason-template-add-and-edit|unknown-error-alert|cannot-add-title", comment: "Cannot add reason template alert title in reason template add and edit.") :
            String(localized: "reason-template-add-and-edit|unknown-error-alert|cannot-save-title", comment: "Cannot save reason template alert title in reason template add and edit.")
        AlertModifier(unknownErrorAlertTitle, isPresented: self.$showUnknownErrorAlert) {
            Button {} label: {
                Text("got-it-button", comment: "Text of a 'got it' button.")
            }
        }
    }
    
    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarButton(placement: .topBarLeading, localized: LocalizedStringResource("cancel-button", comment: "Text of cancel button.")) {
                self.dismiss()
        }
        ToolbarButton(placement: .topBarTrailing, localized: self.reasonTemplateToEdit == nil ? LocalizedStringResource("reason-template-add-and-edit|add-button", comment: "Add reason template button in reason template add and edit.") : LocalizedStringResource("reason-template-add-and-edit|save-button", comment: "Save reason template button in reason template add and edit.")) {
            await self.saveReasonTemplate()
        }.loading(self.isAddAndEditButtonLoading)
            .disabled(self.reasonMessage == "" || self.amount.isZero)
    }
    
    private func saveReasonTemplate() async {
        self.isAddAndEditButtonLoading = true
        defer {
            self.isAddAndEditButtonLoading = false
        }
        self.reasonMessage = self.reasonMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let reasonTemplateId = self.reasonTemplateToEdit?.id ?? ReasonTemplate.ID()
            var counts: ReasonTemplate.Counts? = nil
            if let countsItem = self.countsItem {
                counts = ReasonTemplate.Counts(item: countsItem, maxCount: self.maxCount == 0 ? nil : self.maxCount)
            }
            let reasonTemplate = ReasonTemplate(id: reasonTemplateId, reasonMessage: self.reasonMessage, amount: self.amount, counts: counts)
            if self.reasonTemplateToEdit == nil {
                let reasonTemplateAddFunction = ReasonTemplateAddFunction(clubId: self.appProperties.club.id, reasonTemplate: reasonTemplate)
                try await FirebaseFunctionCaller.shared.call(reasonTemplateAddFunction)
            } else {
                let reasonTemplateUpdateFunction = ReasonTemplateUpdateFunction(clubId: self.appProperties.club.id, reasonTemplate: reasonTemplate)
                try await FirebaseFunctionCaller.shared.call(reasonTemplateUpdateFunction)
            }
            self.appProperties.reasonTemplates[reasonTemplateId] = reasonTemplate
            self.reset()
            self.dismiss()
        } catch {
            self.showUnknownErrorAlert = true
        }
    }
    
    private func reset() {
        self.reasonMessage = ""
        self.amount = .amount(.zero)
    }
}
