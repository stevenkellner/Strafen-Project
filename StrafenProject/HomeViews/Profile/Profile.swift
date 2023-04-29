//
//  Profile.swift
//  StrafenProject
//
//  Created by Steven on 28.04.23.
//

import SwiftUI

struct Profile: View {
    
    @Environment(\.redactionReasons) private var redactionReasons
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @EnvironmentObject private var imageStorage: FirebaseImageStorage
    
    @State private var isChangeProfileImageSheetShown = false
    
    var body: some View {
        NavigationStack {
            List {
                if let person = self.appProperties.persons[self.appProperties.signedInPerson.id] {
                    Section {
                        if let image = self.imageStorage.personImages[self.appProperties.signedInPerson.id] {
                            HStack {
                                Spacer()
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                Spacer()
                            }
                        }
                        HStack {
                            Text("person-detail|still-open-amount", comment: "Text for the fine amount of the person that is still open.")
                                .unredacted()
                            Spacer()
                            Text(self.appProperties.fines(of: person).unpayedAmount.formatted)
                                .foregroundColor(.red)
                        }
                        HStack {
                            Text("person-detail|total-amount", comment: "Text for the total fine amount of the person.")
                                .unredacted()
                            Spacer()
                            Text(self.appProperties.fines(of: person).totalAmount.formatted)
                                .foregroundColor(.green)
                        }
                    }
                    let sortedFines = self.appProperties.sortedFinesGroups(of: person)
                    let unpayedFines = sortedFines.sortedList(of: .unpayed)
                    if !unpayedFines.isEmpty {
                        Section {
                            ForEach(unpayedFines) { fine in
                                PersonDetail.FineRow(fine, person: person)
                            }
                        } header: {
                            Text("person-detail|open-fines", comment: "Section text of still open fines.")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .fontWeight(.bold)
                                .unredacted()
                        }
                    }
                    let payedFines = sortedFines.sortedList(of: .payed)
                    if !payedFines.isEmpty {
                        Section {
                            ForEach(payedFines) { fine in
                                PersonDetail.FineRow(fine, person: person)
                            }
                        } header: {
                            Text("person-detail|payed-fines", comment: "Section text of already payed fines.")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .fontWeight(.bold)
                                .unredacted()
                        }
                    }
                } else {
                    Text("profile|person-not-found", comment: "Signed in person not found for profile detail.")
                        .foregroundColor(.secondary)
                }
            }.navigationTitle(self.appProperties.signedInPerson.name.formatted())
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.isChangeProfileImageSheetShown = true
                        } label: {
                            Text("profile|change-profile-image-button", comment: "Change profile image button in profile detail.")
                                .unredacted()
                        }.disabled(self.redactionReasons.contains(.placeholder))
                    }
                }
                .sheet(isPresented: self.$isChangeProfileImageSheetShown) {
                    ProfileChangeImage()
                }
        }.task {
            await self.imageStorage.fetch(.person(clubId: self.appProperties.club.id, personId: self.appProperties.signedInPerson.id))
        }
    }
}
