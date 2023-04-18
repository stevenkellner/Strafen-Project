//
//  StartPageView.swift
//  StrafenProject
//
//  Created by Steven on 11.04.23.
//

import SwiftUI

struct StartPageView: View {
    
    @State private var isTermsAndPrivacySheetShown = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                self.backgroundImage
                    .ignoresSafeArea(edges: .top)
                VStack {
                    Spacer()
                    self.startAndLoginButtons
                        .padding(.bottom, 25)
                    self.termsAndPrivacy
                }
            }
        }
    }
    
    @ViewBuilder var backgroundImage: some View {
        VStack {
            Image("startPage-background")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer()
        }
    }
    
    @ViewBuilder var startAndLoginButtons: some View {
        VStack {
            NavigationLink(destination: InvitationLinkAndCreateClubView()) {
                Text("start-page|buttons|start-register-create-club", comment: "Start button on start page to get to register / create club page.")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .frame(height: 35)
            }.buttonStyle(.borderedProminent)
            
            NavigationLink(destination: LoginView(referrer: .login, afterSignIn: { _ in
                await self.loginUser()
                return nil
            })) {
                Text("start-page|buttons|login", comment: "Login button on start page to get to login page.")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .frame(height: 35)
            }.buttonStyle(.bordered)
        }.padding(.horizontal)
    }
    
    @ViewBuilder var termsAndPrivacy: some View {
        VStack {
            Text("agree-terms-privacy-by-continue|by-continue-agree", comment: "Starting part of 'By continuing you agree to Terms, Conditions and Privacy Policy', i.e. 'By continuing you agree to'. Don't add trailing space as it's splitted between two lines.")
                .foregroundColor(.secondary)
            Button(role: .none) {
                self.isTermsAndPrivacySheetShown = true
            } label: {
                Text("agree-terms-privacy-by-continue|terms-and-privacy", comment: "Starting part of 'By continuing you agree to Terms, Conditions and Privacy Policy', i.e. 'Terms, Conditions and Privacy Policy'.")
            }.buttonStyle(.borderless)
        }.sheet(isPresented: self.$isTermsAndPrivacySheetShown) {
            NavigationView {
                TermsAndPrivacyView()
                    .toolbar {
                        ToolbarItem {
                            Button {
                                self.isTermsAndPrivacySheetShown = false
                            } label: {
                                Text("dismiss-sheet", comment: "Dismiss button on a sheet.")
                            }.buttonStyle(.borderless)
                        }
                    }
            }
        }
    }
    
    private func loginUser() async {
        let personGetCurrentFunction = PersonGetCurrentFunction()
        guard let currentPerson = try? await FirebaseFunctionCaller.shared.call(personGetCurrentFunction) else {
            return
        }
        try? SettingsManager.shared.save(currentPerson.settingsPerson, at: \.signedInPerson)
    }
}
