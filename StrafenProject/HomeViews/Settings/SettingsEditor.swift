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
    
    @State private var sorting: Settings.Sorting = Settings.Sorting.default
    
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
                    self.sortingPicker(String(localized: "settings|sorting|person-title", comment: "Title of the person sorting in settings."), selection: self.$sorting.personSorting)
                    self.sortingPicker(String(localized: "settings|sorting|reason-template-title", comment: "Title of the person sorting in settings."), selection: self.$sorting.reasonTemplateSorting)
                    self.sortingPicker(String(localized: "settings|sorting|fine-title", comment: "Title of the fine sorting in settings."), selection: self.$sorting.fineSorting)
                } header: {
                    Text(String(localized: "settings|sorting|title", comment: "Title of the sorting section in settings."))
                        .foregroundColor(.secondary)
                        .font(.callout)
                }.onChange(of: self.sorting) { sorting in
                    try? self.settingsManager.save(sorting, at: \.sorting)
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
                    self.sorting = self.settingsManager.sorting
                }
        }
    }
    
    @ViewBuilder private func sortingPicker<T>(_ title: String, selection: Binding<Settings.Sorting.SortingKeyAndOrder<T>>) -> some View where T: Sortable {
        Picker(title, selection: selection) {
            ForEach(T.SortingKey.allCases, id: \.self) { sortingKey in
                Text(sortingKey.formatted(order: .ascending))
                    .tag(Settings.Sorting.SortingKeyAndOrder<T>(sortingKey: sortingKey, order: .ascending))
                Text(sortingKey.formatted(order: .descending))
                    .tag(Settings.Sorting.SortingKeyAndOrder<T>(sortingKey: sortingKey, order: .descending))
            }
        }
    }
}
