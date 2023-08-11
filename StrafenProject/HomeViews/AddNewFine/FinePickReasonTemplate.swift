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
    
    @EnvironmentObject private var settingsManager: SettingsManager
        
    @Binding private var reasonMessage: String?
    
    @Binding private var counts: ReasonTemplate.Counts?
    
    @Binding private var amount: FineAmount?
    
    @State private var searchText = ""
    
    @State private var isCustomReasonSheetShown = false
    
    init(reasonMessage: Binding<String?>, amount: Binding<FineAmount?>, counts: Binding<ReasonTemplate.Counts?>) {
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
                    FineCustomReason(initialReasonMessage: self.formattedReasonMessage, initialAmount: self.amount ?? .amount(.zero)) { reasonMessage, amount in
                        self.reasonMessage = reasonMessage
                        self.counts = nil
                        self.amount = amount
                        self.dismiss()
                    }
                }
                Section {
                    let sortedReasonTemplates = self.appProperties.sortedReasonTemplates(by: self.settingsManager.sorting.reasonTemplateSorting).searchableGroup(search: self.searchText)
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
                                Text(reasonTemplate.amount.formatted(.short))
                                    .foregroundColor(.red)
                            }.foregroundColor(.primary)
                        }
                    }
                }
            }.modifier(self.rootModifiers)
        }
    }
    
    @ModifierBuilder private var rootModifiers: some ViewModifier {
        NavigationTitleModifier(localized: LocalizedStringResource("fine-pick-reason-template|title", comment: "Title of fine pick reason template."), displayMode: .large)
        SearchableModifier(text: self.$searchText, prompt: String(localized: "fine-pick-reason-template|search-placeholder", comment: "Placeholder text of search bar in fine pick reason template."))
        ToolbarModifier {
            ToolbarButton(placement: .topBarTrailing, localized: LocalizedStringResource("cancel-button", comment: "Text of cancel button.")) {
                self.dismiss()
            }
        }
    }
    
    private var formattedReasonMessage: String {
        return ReasonTemplate(id: ReasonTemplate.ID(), reasonMessage: self.reasonMessage ?? "", amount: self.amount ?? .amount(.zero), counts: self.counts).formatted
    }
}
