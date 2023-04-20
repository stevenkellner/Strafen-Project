//
//  InvitationLinkWelcomePersonView.swift
//  StrafenProject
//
//  Created by Steven on 15.04.23.
//

import SwiftUI

struct InvitationLinkWelcomePersonView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private let person: InvitationLinkGetPersonFunction.ReturnType
    
    private var isSignInNavigationActive: Binding<Bool>
        
    init(_ person: InvitationLinkGetPersonFunction.ReturnType, isSignInNavigationActive: Binding<Bool>) {
        self.person = person
        self.isSignInNavigationActive = isSignInNavigationActive
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // TODO person image
                Text("invitation-link-welcome-person|welcom-person?person=\(self.person.name.formatted())", comment: "Welcome person text in the welcome person page after invitation link input.")
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)
                Text("invitation-link-welcome-person|invitation-in-club?club=\(self.person.club.name)", comment: "Invitation to club text in the welcome person page after invitation link input.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Button {
                    self.dismiss()
                    self.isSignInNavigationActive.wrappedValue = true
                } label: {
                    Text("invitation-link-welcome-person|complete-registration-button", comment: "Complete registration button in the welcome person page after invitation link input.")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
                    .padding(.bottom)
                Text("invitation-link-welcome-person|not-you", comment: "Person are not you in the welcome person page after invitation link input.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 1)
                Text("invitation-link-welcome-person|not-you-ask-cashier-for-new-link", comment: "Ask cashier for a new invitation link if person are not you in the welcome person page after invitation link input.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }.padding()
                .navigationTitle(String(localized: "invitation-link-welcome-person|title", comment: "Title of the welcome person page after invitation link input."))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            self.dismiss()
                        } label: {
                            Text("dismiss-sheet", comment: "Dismiss button on a sheet.")
                        }
                    }
                }
        }
    }
}
