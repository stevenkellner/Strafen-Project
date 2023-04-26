//
//  PersonList.swift
//  StrafenProject
//
//  Created by Steven on 21.04.23.
//

import SwiftUI

struct PersonList: View {
    
    @Environment(\.redactionReasons) private var redactionReasons
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @EnvironmentObject private var imageStorge: FirebaseImageStorage
    
    @State private var searchText = ""
    
    @State private var isPersonAddSheetShown = false
    
    var body: some View {
        NavigationStack {
            List {
                let sortedPersons = self.appProperties.sortedPersons
                let  personsWithUnpayedFines = sortedPersons.personsWithUnpayedFines(searchText: self.searchText)
                if !personsWithUnpayedFines.isEmpty {
                    Section {
                        ForEach(personsWithUnpayedFines) { person in
                            self.personsListRow(person: person)
                        }
                    } header: {
                        Text("Offene Strafen")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                            .unredacted()
                    }
                }
                let  personsWithAllPayedFines = sortedPersons.personsWithAllPayedFines(searchText: self.searchText)
                if !personsWithAllPayedFines.isEmpty {
                    Section {
                        ForEach(personsWithAllPayedFines) { person in
                            self.personsListRow(person: person)
                        }
                    } header: {
                        Text("Bereits gezahlt")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                            .unredacted()
                    }
                }
            }.redacted(reason: self.redactionReasons)
                .navigationTitle("Personen")
                .if(self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder)) { view in
                    view.toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                self.isPersonAddSheetShown = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: self.$isPersonAddSheetShown) {
                        PersonAddAndEdit()
                    }
                }
        }.searchable(text: self.$searchText, prompt: "Person suchen")
            .unredacted()
    }
    
    @ViewBuilder private func personsListRow(person: Person) -> some View {
        NavigationLink {
            Text(person.name.formatted()) // TODO
        } label: {
            HStack {
                if let image = self.imageStorge.personImages[person.id] {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person")
                        .frame(width: 30, height: 30)
                        .unredacted()
                }
                Text(person.name.formatted())
                Spacer()
                let unpayedAmount = self.appProperties.fines(of: person).unpayedAmount
                if unpayedAmount != .zero {
                    Text(unpayedAmount.formatted)
                        .foregroundColor(.red)
                }
            }.task {
                guard !self.redactionReasons.contains(.placeholder) else {
                    return
                }
                await self.imageStorge.fetch(.person(clubId: self.appProperties.signedInPerson.club.id, personId: person.id))
            }
        }.disabled(self.redactionReasons.contains(.placeholder))
            .if(self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder)) { view in
                view.swipeActions {
                    Button(role: .destructive) {
                        // TODO
                    } label: {
                        Label("Löschen", systemImage: "trash")
                            .unredacted()
                    }
                }
            }
    }
}
