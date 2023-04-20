//
//  ContentView.swift
//  StrafenProject
//
//  Created by Steven on 06.04.23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var settingsManager = SettingsManager()
    
    @State private var activeToolbarItem: Toolbar.Item = .profile
    
    var body: some View {
        VStack {
            if FirebaseAuthenticator.shared.user != nil && self.settingsManager.signedInPerson != nil {
                HStack {
                    switch self.activeToolbarItem {
                    case .profile:
                        Text(describing: Toolbar.Item.profile)
                    case .personList:
                        Text(describing: Toolbar.Item.personList)
                    case .reasonList:
                        Text(describing: Toolbar.Item.reasonList)
                    case .addNewFine:
                        Text(describing: Toolbar.Item.addNewFine)
                    case .settings:
                        Text(describing: Toolbar.Item.settings)
                    }
                }.toolbar(active: self.$activeToolbarItem)
            } else {
                StartPageView()
            }
        }.environmentObject(self.settingsManager)
    }
}
