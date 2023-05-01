//
//  FinePickReasonTemplate.swift
//  StrafenProject
//
//  Created by Steven on 28.04.23.
//

import SwiftUI

struct FinePickReasonTemplate: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var appProperties: AppProperties
        
    @Binding private var reasonMessage: String?
    
    @Binding private var counts: ReasonTemplate.Counts?
    
    @Binding private var amount: Amount?
    
    @State private var searchText = ""
    
    @State private var isCustomReasonSheetShown = false
    
    init(reasonMessage: Binding<String?>, amount: Binding<Amount?>, counts: Binding<ReasonTemplate.Counts?>) {
        self._reasonMessage = reasonMessage
        self._counts = counts
        self._amount = amount
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button {
                        self.isCustomReasonSheetShown = true
                    } label: {
                        Text("fine-pick-reason-template|custom-reason-button", comment: "Custom reason button of fine pick reason template.")
                    }
                }.sheet(isPresented: self.$isCustomReasonSheetShown) {
                    FineCustomReason { reasonMessage, amount in
                        self.reasonMessage = reasonMessage
                        self.counts = nil
                        self.amount = amount
                        self.dismiss()
                    }
                }
                Section {
                    let sortedReasonTemplates = self.appProperties.sortedReasonTemplates.sortedSearchableList(search: self.searchText)
                    ForEach(sortedReasonTemplates) { reasonTemplate in
                        Button {
                            self.reasonMessage = reasonTemplate.reasonMessage
                            self.counts = reasonTemplate.counts
                            self.amount = reasonTemplate.amount
                            self.dismiss()
                        } label: {
                            HStack {
                                Text(reasonTemplate.formatted)
                                Spacer()
                                Text(reasonTemplate.amount.formatted)
                                    .foregroundColor(.red)
                            }.foregroundColor(.primary)
                        }
                    }
                }
            }.navigationTitle(String(localized: "fine-pick-reason-template|title", comment: "Title of fine pick reason template."))
                .navigationBarTitleDisplayMode(.large)
                .searchable(text: self.$searchText, prompt: String(localized: "fine-pick-reason-template|search-placeholder", comment: "Placeholder text of search bar in fine pick reason template."))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.dismiss()
                        } label: {
                            Text("cancel-button", comment: "Text of cancel button.")
                        }
                    }
                }
        }
    }
}
