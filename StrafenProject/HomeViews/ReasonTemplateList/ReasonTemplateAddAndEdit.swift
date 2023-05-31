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
    
    @State private var amount: Amount = .zero
        
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
                Section {
                    TextField(String(localized: "reason-template-add-and-edit|amount-textfield", comment: "Amount textfield placeholder in reason template add and edit."), value: self.$amount, format: .amount(.short))
                }
            }.navigationTitle(String(localized: "reason-template-add-and-edit|title", comment: "Navigation title of reason template add and edit."))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(self.toolbar)
                .onChange(of: self.inputFocus) { _ in
                    self.reasonMessage = self.reasonMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                }
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
            if self.isAddAndEditButtonLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Button {
                    Task {
                        await self.saveReasonTemplate()
                    }
                } label: {
                    Text(self.reasonTemplateToEdit == nil ? String(localized: "reason-template-add-and-edit|add-button", comment: "Add reason template button in reason template add and edit.") : String(localized: "reason-template-add-and-edit|save-button", comment: "Save reason template button in reason template add and edit."))
                }.disabled(self.reasonMessage == "" || self.amount == .zero)
            }
        }
    }
    
    private var unknownErrorAlertTitle: String {
        if self.reasonTemplateToEdit == nil {
            return String(localized: "reason-template-add-and-edit|unknown-error-alert|cannot-add-title", comment: "Cannot add reason template alert title in reason template add and edit.")
        }
        return String(localized: "reason-template-add-and-edit|unknown-error-alert|cannot-save-title", comment: "Cannot save reason template alert title in reason template add and edit.")
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
