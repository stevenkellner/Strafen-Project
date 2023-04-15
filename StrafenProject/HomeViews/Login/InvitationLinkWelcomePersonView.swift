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
                Text("Herzlich Willkommen, \(self.person.name.description)")
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)
                Text("Du wurdest in den Verein \(self.person.club.name) eingeladen.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Button {
                    self.dismiss()
                    self.isSignInNavigationActive.wrappedValue = true
                } label: {
                    Text("Registrierung abschließen")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
                    .padding(.bottom)
                Text("Das bist nicht du?")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 1)
                Text("Bitte deinen Kassier, dir einen neuen Einladungslink zu erstellen.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }.padding()
                .navigationTitle("Willkommen")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button {
                        self.dismiss()
                    } label: {
                        Text("Schließen")
                    }
                }
        }
    }
}
