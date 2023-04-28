//
//  SettingsEditor.swift
//  StrafenProject
//
//  Created by Steven on 28.04.23.
//

import SwiftUI

struct SettingsEditor: View {
        
    @EnvironmentObject private var settingsManager: SettingsManager
    
    @State private var appearance: Settings.Appearance = .system
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("settings|appearance", selection: self.$appearance) {
                        ForEach(Settings.Appearance.allCases, id: \.self) { appearance in
                            Text(appearance.formatted)
                        }
                    }.onChange(of: self.appearance) { appearance in
                        try? self.settingsManager.save(appearance, at: \.appearance)
                        UIApplication.shared.rootViewController?.overrideUserInterfaceStyle = appearance.uiStyle
                    }
                }
                Section {
                    Button(role: .destructive) {
                        try? self.settingsManager.save(nil, at: \.signedInPerson)
                        try? FirebaseAuthenticator.shared.signOut()
                    } label: {
                        HStack {
                            Spacer()
                            Text("settings|sign-out", comment: "Sign out button in settings editor.")
                            Spacer()
                        }
                    }
                }
            }.navigationTitle(String(localized: "settings|title", comment: "Navigation title of the settings."))
                .onAppear {
                    self.appearance = self.settingsManager.appearance
                }
        }
    }
}
