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
    
    @State private var reasonMessage: String = ""
    
    @State private var amount: Amount = .zero
    
    @FocusState private var inputFocus: InputFocus?
    
    init(initialReasonMessage reasonMessage: String, initialAmount amount: Amount, handler completionHandler: @escaping (_ reasonMessage: String, _ amount: Amount) -> Void) {
        self._reasonMessage = State(initialValue: reasonMessage)
        self._amount = State(initialValue: amount)
        self.completionHandler = completionHandler
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(String(localized: "fine-custom-reason|reason-message-textfield", comment: "Reason message textfield placeholder in fine custom reason."), text: self.$reasonMessage)
                        .focused(self.$inputFocus, equals: .reasonMessage)
                        .onChange(of: self.inputFocus) { _ in
                            self.reasonMessage = self.reasonMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                }
                Section {
                    TextField(String(localized: "fine-custom-reason|amount-textfield", comment: "Amount textfield placeholder in fine custom reason."), value: self.$amount, format: .amount(.short))
                }
            }.modifier(self.rootModifiers)
        }
    }
    
    @ModifierBuilder private var rootModifiers: some ViewModifier {
        NavigationTitleModifier(localized: LocalizedStringResource("fine-custom-reason|title", comment: "Navigation title of fine custom reason."), displayMode: .inline)
        ToolbarModifier(content: self.toolbar)
    }
    
    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarButton(placement: .topBarLeading, localized: LocalizedStringResource("cancel-button", comment: "Text of cancel button.")) {
            self.dismiss()
        }
        ToolbarButton(placement: .navigationBarTrailing, localized: LocalizedStringResource("confirm-button", comment: "Text of confirm button.")) {
            self.dismiss()
            self.reasonMessage = self.reasonMessage.trimmingCharacters(in: .whitespacesAndNewlines)
            self.completionHandler(self.reasonMessage, self.amount)
        }.disabled(self.reasonMessage == "" || self.amount == .zero)
    }
}
