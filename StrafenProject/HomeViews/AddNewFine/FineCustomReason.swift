//
//  FineCustomReason.swift
//  StrafenProject
//
//  Created by Steven on 28.04.23.
//

import SwiftUI

struct FineCustomReason: View {
    private enum InputFocus {
        case reasonMessage
    }
    
    @Environment(\.dismiss) private var dismiss
    
    private let completionHandler: (_ reasonMessage: String, _ amount: Amount) -> Void
    
    @State private var reasonMessage = ""
    
    @State private var amount: Amount = .zero
    
    @FocusState private var inputFocus: InputFocus?
    
    init(handler completionHandler: @escaping (_ reasonMessage: String, _ amount: Amount) -> Void) {
        self.completionHandler = completionHandler
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(String(localized: "fine-custom-reason|reason-message-textfield", comment: "Reason message textfield placeholder in fine custom reason."), text: self.$reasonMessage)
                        .focused(self.$inputFocus, equals: .reasonMessage)
                }
                Section {
                    TextField(String(localized: "fine-custom-reason|amount-textfield", comment: "Amount textfield placeholder in fine custom reason."), value: self.$amount, format: .amount(.short))
                }
            }.navigationTitle(String(localized: "fine-custom-reason|title", comment: "Navigation title of fine custom reason."))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(self.toolbar)
                .onChange(of: self.inputFocus) { _ in
                    self.reasonMessage = self.reasonMessage.trimmingCharacters(in: .whitespacesAndNewlines)
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
                self.dismiss()
                self.reasonMessage = self.reasonMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                self.completionHandler(self.reasonMessage, self.amount)
            } label: {
                Text("confirm-button", comment: "Text of confirm button.")
            }.disabled(self.reasonMessage == "" || self.amount == .zero)
        }
    }
}
