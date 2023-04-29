//
//  CreateClubView.swift
//  StrafenProject
//
//  Created by Steven on 18.04.23.
//

import SwiftUI
import FirebaseAuth

struct CreateClubView: View {
    
    @EnvironmentObject private var settingsManager: SettingsManager
    
    private let hashedUserId: String
        
    @State private var firstName: String = ""
    
    @State private var lastName: String = ""
    
    @State private var clubName: String = ""
    
    @State private var isCreateClubButtonDisabled = true
    
    init(user signedInUser: User) {
        self.hashedUserId = Crypter.sha512(signedInUser.uid)
        if let fullName = signedInUser.displayName,
              let personNameComponents = try? PersonNameComponents(fullName) {
            self._firstName = State(initialValue: personNameComponents.givenName ?? "")
            self._lastName = State(initialValue: personNameComponents.familyName ?? "")
        }
    }
    
    var body: some View {
        VStack {
            self.personNameInput
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.secondary)
                Text("create-club|and", comment: "And text between person name input and club name input.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                Rectangle()
                    .foregroundColor(.secondary)
                    .frame(height: 1)
            }.padding(.horizontal)
                .padding(.vertical, 30)
            self.clubNameInputAndCreateButton
        }.navigationTitle(String(localized: "create-club|navigation-title", comment: "Title of the create club view."))
            .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder private var personNameInput: some View {
        Section {
            VStack {
                TextField(String(localized: "create-club|person-name-input|first-name-placeholder", comment: "Placeholder of the first name input."), text: self.$firstName)
                    .font(.title3)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .padding(5)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(5)
                    .onChange(of: self.firstName) { _ in
                        self.checkCreateClubButtonDisabled()
                    }
                TextField(String(localized: "create-club|person-name-input|optional-last-name-placeholder", comment: "Placeholder of the optionally last name input."), text: self.$lastName)
                    .font(.title3)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .padding(5)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(5)
                    .onChange(of: self.lastName) { _ in
                        self.checkCreateClubButtonDisabled()
                    }
            }
        } header: {
            Text("create-club|person-name-input|complete-profile-header", comment: "Header of the person name input to complete your profile.")
                .foregroundColor(.secondary)
                .fontWeight(.light)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }.padding(.horizontal)
    }
    
    @ViewBuilder private var clubNameInputAndCreateButton: some View {
        Section {
            TextField(String(localized: "create-club|club-name-input|placeholder", comment: "Placeholder of the club name input."), text: self.$clubName)
                .font(.title3)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(5)
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(5)
                .onChange(of: self.clubName) { _ in
                    self.checkCreateClubButtonDisabled()
                }
        } header: {
            Text("create-club|club-name-input|header", comment: "Header of the club name input.")
                .foregroundColor(.secondary)
                .fontWeight(.light)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }.padding(.horizontal)
        Button {
            Task {
                await self.createClub()
            }
        } label: {
            Text("create-club|create-club-button", comment: "Button to create a new club.")
                .font(.title2)
                .frame(maxWidth: .infinity)
        }.buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.top, 30)
            .disabled(self.isCreateClubButtonDisabled)
    }
    
    private func checkCreateClubButtonDisabled() {
        if self.personName == nil {
            self.isCreateClubButtonDisabled = true
        } else if self.clubName == "" {
            self.isCreateClubButtonDisabled = true
        } else {
            self.isCreateClubButtonDisabled = false
        }
    }
    
    private var personName: PersonName? {
        guard self.firstName != "" else {
            return nil
        }
        let lastName = self.lastName == "" ? nil : self.lastName
        return PersonName(first: self.firstName, last: lastName)
    }
    
    private func createClub() async {
        self.isCreateClubButtonDisabled = true
        defer {
            self.isCreateClubButtonDisabled = false
        }
        guard let personName = self.personName else {
            return
        }
        let clubProperties = ClubProperties(id: ClubProperties.ID(), name: self.clubName)
        let personId = Person.ID()
        let clubNewFunction = ClubNewFunction(clubProperties: clubProperties, personId: personId, personName: personName)
        do {
            try await FirebaseFunctionCaller.shared.call(clubNewFunction)
            try self.settingsManager.save(Settings.SignedInPerson(id: personId, name: personName, isAdmin: true, hashedUserId: self.hashedUserId, club: clubProperties), at: \.signedInPerson)
        } catch {}
    }
}
