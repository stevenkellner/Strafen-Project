//
//  Profile.swift
//  StrafenProject
//
//  Created by Steven on 28.04.23.
//

import SwiftUI

struct Profile: View {
    
    @Environment(\.redactionReasons) private var redactionReasons
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @State private var isChangeProfileImageSheetShown = false
    
    var body: some View {
        NavigationStack {
            List {
                PersonInfoSection(self.appProperties.signedInPerson)
                FineListView(of: self.appProperties.signedInPerson)
            }.modifier(self.rootModifiers)
        }
    }
        
    @ModifierBuilder private var rootModifiers: some ViewModifier {
        NavigationTitleModifier(self.appProperties.signedInPerson.name.formatted(), displayMode: .large)
        RefreshableModifier {
            await self.appProperties.refresh()
        }
        ToolbarModifier {
            ToolbarButton(placement: .navigationBarTrailing, localized: "profile|change-profile-image-button") {
                self.isChangeProfileImageSheetShown = true
            }.disabled(self.redactionReasons.contains(.placeholder))
                .unredacted
        }
        SheetModifier(isPresented: self.$isChangeProfileImageSheetShown) {
            ProfileChangeImage()
        }
    }
}
