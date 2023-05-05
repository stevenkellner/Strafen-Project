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
    
    @EnvironmentObject private var imageStorage: FirebaseImageStorage
    
    @State private var searchText = ""
    
    @State private var isPersonAddSheetShown = false
    
    @State private var cannotDeletePersonAlertShown = false
    
    var body: some View {
        NavigationStack {
            List {
                let sortedPersons = self.appProperties.sortedPersonsGroups
                let personsWithUnpayedFines = sortedPersons.sortedSearchableList(of: .withUnpayedFines, search: self.searchText)
                if !personsWithUnpayedFines.isEmpty {
                    Section {
                        ForEach(personsWithUnpayedFines) { person in
                            self.personsListRow(person: person)
                        }
                    } header: {
                        Text("person-list|persons-with-open-fines", comment: "In person list a section title of persons with open fines.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                            .unredacted()
                    }
                }
                let personsWithAllPayedFines = sortedPersons.sortedSearchableList(of: .withPayedFines, search: self.searchText)
                if !personsWithAllPayedFines.isEmpty {
                    Section {
                        ForEach(personsWithAllPayedFines) { person in
                            self.personsListRow(person: person)
                        }
                    } header: {
                        Text("person-list|persons-with-all-payed-fines", comment: "In person list a section of persons with all payed fines.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                            .unredacted()
                    }
                }
            }.redacted(reason: self.redactionReasons)
                .refreshable {
                    await self.appProperties.refresh()
                }
                .navigationTitle(String(localized: "person-list|title", comment: "Navigation title of the person list."))
                .alert(String(localized: "person-list|cannot-delete-person-alert|title", comment: "Title of the cannot delete person alert in person list."), isPresented: self.$cannotDeletePersonAlertShown) {
                    Button {} label: {
                        Text("got-it-button", comment: "Text of a 'got it' button.")
                    }
                } message: {
                    Text("person-list|cannot-delete-person-alert|message", comment: "Message of the cannot delete person alert in person list cause the person is already registered.")
                }
                .if(self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder)) { view in
                    view.toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            ShareLink(item: "", message: Text(self.appProperties.shareText), preview: SharePreview(String(localized: "person-list|share-title", comment: "Title of share preview when sharing persons."))) // Offene Strafen
                        }
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
        }.searchable(text: self.$searchText, prompt: String(localized: "person-list|search-person", comment: "Search person placeholder of search bar in person list."))
            .unredacted()
    }
    
    @ViewBuilder private func personsListRow(person: Person) -> some View {
        NavigationLink {
            let personBinding = Binding {
                return person
            } set: { newPerson in
                self.appProperties.persons[person.id] = newPerson
            }
            PersonDetail(personBinding)
        } label: {
            HStack {
                if let image = self.imageStorage.personImages[person.id] {
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
                await self.imageStorage.fetch(.person(clubId: self.appProperties.club.id, personId: person.id))
            }
        }.disabled(self.redactionReasons.contains(.placeholder))
            .if(self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder)) { view in
                view.swipeActions {
                    Button(role: .destructive) {
                        Task {
                            await self.deletePerson(person)
                        }
                    } label: {
                        Label(String(localized: "delete-button", comment: "Text of delete button."), systemImage: "trash")
                            .unredacted()
                    }
                }
            }
    }
    
    private func deletePerson(_ person: Person) async {
        do {
            let personEditFunction = PersonEditFunction.delete(clubId: self.appProperties.club.id, personId: person.id)
            try await FirebaseFunctionCaller.shared.call(personEditFunction)
            self.appProperties.persons[person.id] = nil
        } catch let error as FirebaseFunctionError {
            if error.code == .unavailable {
                self.cannotDeletePersonAlertShown = true
            }
        } catch {}
    }
}
