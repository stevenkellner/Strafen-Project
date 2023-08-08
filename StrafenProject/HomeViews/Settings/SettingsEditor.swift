//
//  SettingsEditor.swift
//  StrafenProject
//
//  Created by Steven on 28.04.23.
//

import SwiftUI

struct SettingsEditor: View {
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @EnvironmentObject private var settingsManager: SettingsManager
    
    @State private var appearance: Settings.Appearance = .system
    
    @State private var sorting: Settings.Sorting = Settings.Sorting.default
    
    @State private var isPaypalMeAlertShown = false
    
    @State private var paypalMeLink = ""
    
    var body: some View {
        NavigationStack {
            List {
                self.appearancePicker
                self.sortingPicker
                self.paypalMeInput
                self.deleteCacheButton
                self.signOutButton
            }.navigationTitle(String(localized: "settings|title", comment: "Navigation title of the settings."))
                .onAppear {
                    self.appearance = self.settingsManager.appearance
                    self.sorting = self.settingsManager.sorting
                }
        }
    }
    
    @ViewBuilder private var appearancePicker: some View {
        Section {
            Picker(String(localized: "settings|appearance", comment: "Title of the appearance section in settings."), selection: self.$appearance) {
                ForEach(Settings.Appearance.allCases, id: \.self) { appearance in
                    Text(appearance.formatted)
                }
            }.onChange(of: self.appearance) { appearance in
                try? self.settingsManager.save(appearance, at: \.appearance)
                UIApplication.shared.rootViewController?.overrideUserInterfaceStyle = appearance.uiStyle
            }
        }
    }
    
    @ViewBuilder private var sortingPicker: some View {
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
    
    @ViewBuilder private var paypalMeInput: some View {
        if self.appProperties.signedInPerson.isAdmin {
            Section {
                Button {
                    self.isPaypalMeAlertShown = true
                } label: {
                    HStack {
                        Image("paypal_logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                        if let paypalMeLink = self.appProperties.club.paypalMeLink {
                            Text("settings|paypal-me|change-link-button?old-link=\(paypalMeLink)", comment: "Change old paypal.me link button in settings editor.")
                        } else {
                            Text("settings|paypal-me|add-link-button", comment: "Add new paypal.me link button in settings editor.")
                        }
                    }
                }
            }.onAppear {
                if let paypalMeLink = self.appProperties.club.paypalMeLink {
                    self.paypalMeLink = paypalMeLink
                } else {
                    self.paypalMeLink = ""
                }
            }.alert(self.appProperties.club.paypalMeLink == nil ? String(localized: "settings|paypal-me|alert-title-add-link", comment: "Add paypal.me link alert title.") : String(localized: "settings|paypal-me|alert-title-change-link", comment: "Change paypal.me link alert title."), isPresented: self.$isPaypalMeAlertShown) {
                TextField(String(localized: "settings|paypal-me|input-placeholder", comment: "paypal.me textfield input placeholder in settings editor."), text: self.$paypalMeLink)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                AsyncButton {
                    await self.setPaypalMe()
                } label: {
                    Text("save-button", comment: "Text of save button.")
                }.disabled(self.parsedPaypalMeName == nil)
                if appProperties.club.paypalMeLink != nil {
                    AsyncButton(role: .destructive) {
                        await self.deletePaypalMe()
                    } label: {
                        Text("settings|paypal-me|delete-button", comment: "Delete button in paypal.me change alert in settings editor.")
                    }
                }
                Button(role: .cancel) {} label: {
                    Text("cancel-button", comment: "Text of cancel button.")
                }
            } message: {
                Text("settings|paypal-me|alert-message")
            }
        }
    }
    
    @ViewBuilder private var deleteCacheButton: some View {
        Section {
            Button(role: .destructive) {
                do {
                    try AppPropertiesCache.shared.removeList(type: Person.self)
                    try AppPropertiesCache.shared.removeList(type: ReasonTemplate.self)
                    try AppPropertiesCache.shared.removeList(type: Fine.self)
                } catch {
                    print(error)
                }
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("settings|delete-cache", comment: "Delete cache button in settings editor.")
                }
            }
        }
    }
    
    @ViewBuilder private var signOutButton: some View {
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
    }
    
    private var parsedPaypalMeName: String? {
        let regex = #/^(?:https:\/\/)?(?:www\.)?[Pp][Aa][Yy][Pp][Aa][Ll]\.[Mm][Ee]\/(?<name>[A-Za-z0-9]{2,20})(?:\?.*)?$/#
        guard let match = try? regex.wholeMatch(in: self.paypalMeLink) else {
            return nil
        }
        return String(match.output.name)
    }
    
    private func deletePaypalMe() async {
        do {
            let paypalMeSetFunction = PaypalMeSetFunction(clubId: self.appProperties.club.id, paypalMeLink: nil)
            try await FirebaseFunctionCaller.shared.call(paypalMeSetFunction)
            self.appProperties.signedInPerson.club.paypalMeLink = nil
            if var signedInPerson = self.settingsManager.signedInPerson {
                signedInPerson.club.paypalMeLink = nil
                try? self.settingsManager.save(signedInPerson, at: \.signedInPerson)
            }
        } catch {}
        self.paypalMeLink = ""
    }
    
    private func setPaypalMe() async {
        guard let paypalMeName = self.parsedPaypalMeName else {
            return
        }
        let paypalMeLink = "paypal.me/\(paypalMeName)"
        do {
            let paypalMeSetFunction = PaypalMeSetFunction(clubId: self.appProperties.club.id, paypalMeLink: paypalMeLink)
            try await FirebaseFunctionCaller.shared.call(paypalMeSetFunction)
            self.appProperties.signedInPerson.club.paypalMeLink = paypalMeLink
            if var signedInPerson = self.settingsManager.signedInPerson {
                signedInPerson.club.paypalMeLink = paypalMeLink
                try? self.settingsManager.save(signedInPerson, at: \.signedInPerson)
            }
        } catch {}
        self.paypalMeLink = paypalMeLink
    }
}
