//
//  ReasonTemplateList.swift
//  StrafenProject
//
//  Created by Steven on 27.04.23.
//

import SwiftUI

struct ReasonTemplateList: View {
    
    @Environment(\.redactionReasons) private var redactionReasons
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @State private var searchText = ""
    
    @State private var isReasonTemplateAddSheetShown = false
        
    var body: some View {
        NavigationStack {
            List {
                ReasonTemplateListView(search: self.searchText)
            }.redacted(reason: self.redactionReasons)
                .modifier(self.rootModifiers)
        }.unredacted()
    }
    
    @ModifierBuilder private var rootModifiers: some ViewModifier {
        NavigationTitleModifier(localized: LocalizedStringResource("reason-template-list|navigation-title", comment: "Title of the reason template list."))
        RefreshableModifier {
            await self.appProperties.refresh()
        }
        SearchableModifier(text: self.$searchText, prompt: String(localized: "reason-template-list|search-placeholer", comment: "Placeholder text of search bar in reason template list."))
        if self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder) {
            ToolbarModifier {
                ToolbarButton(placement: .topBarTrailing, systemImage: "plus") {
                    self.isReasonTemplateAddSheetShown = true
                }
            }
            SheetModifier(isPresented: self.$isReasonTemplateAddSheetShown) {
                ReasonTemplateAddAndEdit()
            }
        }
    }
}
