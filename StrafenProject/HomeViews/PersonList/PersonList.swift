//
//  PersonList.swift
//  StrafenProject
//
//  Created by Steven on 21.04.23.
//

import SwiftUI

struct PersonList: View {
    
    @Environment(\.redactionReasons) private var redactionReasons
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @EnvironmentObject private var settingsManager: SettingsManager
    
    @State private var searchText = ""
    
    @State private var isPersonAddSheetShown = false
    
    var body: some View {
        NavigationStack {
            List {
                PersonListView(search: self.searchText)
            }.redacted(reason: self.redactionReasons)
                .modifier(self.rootModifiers)
        }.unredacted()
    }
    
    @ModifierBuilder private var rootModifiers: some ViewModifier {
        NavigationTitleModifier(localized: LocalizedStringResource("person-list|title", comment: "Navigation title of the person list."))
        RefreshableModifier {
            await self.appProperties.refresh()
        }
        SearchableModifier(text: self.$searchText, prompt: String(localized: "person-list|search-person", comment: "Search person placeholder of search bar in person list."))
        if self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder) {
            ToolbarModifier {
                ToolbarItem(placement: .topBarLeading) {
                    ShareLink(item: "", message: Text(self.appProperties.shareText(sorting: self.settingsManager.sorting)), preview: SharePreview(String(localized: "person-list|share-title", comment: "Title of share preview when sharing persons.")))
                }
                ToolbarButton(placement: .topBarTrailing, systemImage: "plus") {
                    self.isPersonAddSheetShown = true
                }
            }
        }
        if self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder) {
            SheetModifier(isPresented: self.$isPersonAddSheetShown) {
                PersonAddAndEdit()
            }
        }
    }
}
