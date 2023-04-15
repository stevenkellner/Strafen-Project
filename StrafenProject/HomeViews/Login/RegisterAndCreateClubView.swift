//
//  RegisterAndCreateClubView.swift
//  StrafenProject
//
//  Created by Steven on 12.04.23.
//

import SwiftUI

struct RegisterAndCreateClubView: View {
            
    var body: some View {
        VStack {
            RegisterView()
            // TODO create club
        }.navigationTitle(String(localized: "register-and-create-club|title", comment: "Title of register and create club view."))
    }
}

extension RegisterAndCreateClubView {
    struct RegisterView: View {
        
        @State private var invitationLink: String = "Y8T4Gul9W4cU3BFd" // TODO
                
        @State private var buttonDisabled = true
        
        @State private var notFoundAlertShown = false
        
        @State private var personToInvite: InvitationLinkGetPersonFunction.ReturnType?
        
        var body: some View {
            VStack {
                Section {
                    TextField(String(localized: "register-and-create-club|invitation-link|text-field-placeholder", comment: "Title of the invitation link input."), text: self.$invitationLink)
                        .font(.title3)
                        .padding(5)
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(5)
                        .onChange(of: self.invitationLink) { _ in
                            self.validateLink()
                        }
                } header: {
                    Text("register-and-create-club|invitation-link|text-field-title", comment: "Placeholder of the invitation link input.")
                        .foregroundColor(.secondary)
                        .fontWeight(.light)
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } footer: {
                    Text("register-and-create-club|invitation-link|text-field-description", comment: "Description of the invitation link input.")
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
                    Text("register-and-create-club|invitation-link|join-club-button", comment: "Button to join the club after input of invitation link.")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
                    .disabled(self.buttonDisabled)
                    .padding(.horizontal)
            }.alert(String(localized: "register-and-create-club|invitation-link|not-found-alert|title", comment: "Title of the alert shown when no person is found with specified invitation link."), isPresented: self.$notFoundAlertShown) {
                Button(String(localized: "register-and-create-club|invitation-link|not-found-alert|button", comment: "Button of the alert shown when no person is found with specified invitation link.")) {
                    self.invitationLink = ""
                    self.buttonDisabled = true
                }
            }
            .sheet(item: self.$personToInvite) { person in
                Text(person.name.description) // TODO
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
            } catch {
                guard let error = error as? FirebaseFunctionError else {
                    return
                }
                if error.code == .notFound {
                    self.notFoundAlertShown = true
                }
            }
        }
    }
}
