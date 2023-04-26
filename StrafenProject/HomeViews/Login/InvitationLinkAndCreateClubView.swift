//
//  InvitationLinkAndCreateClubView.swift
//  StrafenProject
//
//  Created by Steven on 12.04.23.
//

import SwiftUI
import FirebaseAuth

struct InvitationLinkAndCreateClubView: View {
    var body: some View {
        VStack {
            InvitationLinkView()
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.secondary)
                Text("invitation-link-and-create-club|or", comment: "Or text between invitation link input and create club button.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                Rectangle()
                    .foregroundColor(.secondary)
                    .frame(height: 1)
            }.padding(.horizontal)
                .padding(.vertical, 30)
            CreateClubButtonView()
        }.navigationTitle(String(localized: "invitation-link-and-create-club|title", comment: "Title of register and create club view."))
    }
}

extension InvitationLinkAndCreateClubView {
    private struct InvitationLinkView: View {
        
        @EnvironmentObject private var settingsManager: SettingsManager
                
        @State private var invitationLink: String = ""
                
        @State private var buttonDisabled = true
        
        @State private var notFoundAlertShown = false
        
        @State private var personToInvite: InvitationLinkGetPersonFunction.ReturnType?
        
        @State private var isWelcomePersonSheetShown = false
        
        @State private var isSignInNavigationActive = false
            
        var body: some View {
            VStack {
                Section {
                    TextField(String(localized: "invitation-link-and-create-club|invitation-link|text-field-placeholder", comment: "Title of the invitation link input."), text: self.$invitationLink)
                        .font(.title3)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding(5)
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(5)
                        .onChange(of: self.invitationLink) { _ in
                            self.validateLink()
                        }
                } header: {
                    Text("invitation-link-and-create-club|invitation-link|text-field-title", comment: "Placeholder of the invitation link input.")
                        .foregroundColor(.secondary)
                        .fontWeight(.light)
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } footer: {
                    Text("invitation-link-and-create-club|invitation-link|text-field-description", comment: "Description of the invitation link input.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 5)
                }.padding(.horizontal)
                Button {
                    Task {
                        await self.handleInvitationLink()
                    }
                } label: {
                    Text("invitation-link-and-create-club|invitation-link|join-club-button", comment: "Button to join the club after input of invitation link.")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
                    .disabled(self.buttonDisabled)
                    .padding(.horizontal)
            }.alert(String(localized: "invitation-link-and-create-club|invitation-link|not-found-alert|title", comment: "Title of the alert shown when no person is found with specified invitation link."), isPresented: self.$notFoundAlertShown) {
                Button(String(localized: "invitation-link-and-create-club|invitation-link|not-found-alert|button", comment: "Button of the alert shown when no person is found with specified invitation link.")) {
                    self.invitationLink = ""
                    self.buttonDisabled = true
                }
            }
            .sheet(isPresented: self.$isWelcomePersonSheetShown) {
                if let person = self.personToInvite {
                    InvitationLinkWelcomePersonView(person, isSignInNavigationActive: self.$isSignInNavigationActive)
                }
            }
            .navigationDestination(isPresented: self.$isSignInNavigationActive) {
                LoginView(referrer: .invitationLink, afterSignIn: { user in
                    return await self.registerPerson(user: user)
                })
            }
        }
        
        private var linkRegex: Regex<(Substring, id: Substring)> {
            return #/^\s*invitation\/(?<id>\S{16})\s*$/#
        }
        
        private func validateLink() {
            if self.invitationLink.count == 16 {
                self.buttonDisabled = false
            } else {
                let match = try! self.linkRegex.wholeMatch(in: self.invitationLink)
                self.buttonDisabled = match == nil
            }
        }
        
        private func parseInvitationLinkId() -> String? {
            if self.invitationLink.count == 16 {
                return self.invitationLink
            } else {
                guard let match = try! self.linkRegex.wholeMatch(in: self.invitationLink) else {
                    return nil
                }
                return String(match.output.id)
            }
        }
        
        private func handleInvitationLink() async {
            self.buttonDisabled = true
            defer {
                self.buttonDisabled = false
            }
            guard let invitationLinkId = self.parseInvitationLinkId() else {
                return
            }
            let invitationLinkGetPersonFunction = InvitationLinkGetPersonFunction(invitationLinkId: invitationLinkId)
            do {
                self.personToInvite = try await FirebaseFunctionCaller.shared.call(invitationLinkGetPersonFunction)
                self.isWelcomePersonSheetShown = true
            } catch let error as FirebaseFunctionError {
                if error.code == .notFound {
                    self.notFoundAlertShown = true
                }
            } catch {}
        }
        
        private func registerPerson(user: User) async -> (message: String, button: String)? {
            guard let person = self.personToInvite else {
                return nil
            }
            let personRegisterFunction = PersonRegisterFunction(clubId: person.club.id, personId: person.id)
            do {
                _ = try await FirebaseFunctionCaller.shared.call(personRegisterFunction)
                try self.settingsManager.save(Settings.SignedInPerson(id: person.id, name: person.name, isAdmin: false, hashedUserId: Crypter.sha512(user.uid), club: person.club), at: \.signedInPerson)
                return nil
            } catch let error as FirebaseFunctionError {
                if error.code == .alreadyExists {
                    return (
                        message: String(localized: "login|custom-error-alert|register-person|already-exists-message", comment: "Login failed alert if person try to sign in is already registered."),
                        button: String(localized: "login|custom-error-alert|register-person|login-instead-button", comment: "Login failed alert if person try to sign in is already registered, button text to login instead.")
                    )
                }
                return nil
            } catch {
                return nil
            }
        }
    }
}

extension InvitationLinkAndCreateClubView {
    private struct CreateClubButtonView: View {
                
        var body: some View {
            VStack {
                Text("invitation-link-and-create-club|create-club-button-description", comment: "Description of the create club button.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                NavigationLink(destination: LoginView(referrer: .createClub, destination: { user in
                    CreateClubView(user: user)
                })) {
                    Text("invitation-link-and-create-club|create-club-button", comment: "Create new club button.")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                }.buttonStyle(.bordered)
            }.padding(.horizontal)
        }
    }
}
