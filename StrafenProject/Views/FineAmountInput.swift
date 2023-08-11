//
//  FineAmountInput.swift
//  StrafenProject
//
//  Created by Steven on 11.08.23.
//

import SwiftUI

struct FineAmountInput: View {
    
    @Binding private var fineAmount: FineAmount
    
    @State private var amount: Amount = .zero
    
    @State private var item: FineAmount.Item?
    
    @State private var count: Int = 1
    
    init(fineAmount: Binding<FineAmount>) {
        self._fineAmount = fineAmount
        switch fineAmount.wrappedValue {
        case .amount(let amount):
            self._amount = State(initialValue: amount)
        case .item(let item, count: let count):
            self._item = State(initialValue: item)
            self._count = State(initialValue: count)
        }
    }
    
    var body: some View {
        Section {
            Picker(String(localized: "fine-amount-input|item-picker", comment: "Item picker in fine amount input."), selection: self.$item) {
                Text("fine-amount-input|item-picker-amount", comment: "Amount item of item picker in fine amount input.")
                    .tag(nil as FineAmount.Item?)
                ForEach(FineAmount.Item.allCases, id: \.self) { item in
                    Text(item.formatted)
                        .tag(item as FineAmount.Item?)
                }
            }.onChange(of: self.item) { item in
                if let item {
                    self.fineAmount = .item(item, count: self.count)
                } else {
                    self.fineAmount = .amount(self.amount)
                }
            }
            if self.item == nil {
                TextField(String(localized: "fine-amount-input|amount-textfield", comment: "Amount textfield placeholder in fine amount input."), value: self.$amount, format: .amount(.short))
                    .onChange(of: self.amount) { amount in
                        if self.item == nil {
                            self.fineAmount = .amount(amount)
                        }
                    }
            } else {
                Stepper(String(localized: "fine-amount-input|count-stepper?count=\(self.count)", comment: "Count stepper in fine amount input."), value: self.$count, in: 1...1000)
                    .onChange(of: self.count) { count in
                        if let item = self.item {
                            self.fineAmount = .item(item, count: count)
                        }
                    }
            }
        }
    }
}
