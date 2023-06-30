//
//  PersonListView.swift
//  StrafenProject
//
//  Created by Steven on 13.06.23.
//

import SwiftUI

struct PersonListView: View {
    
    @Environment(\.redactionReasons) private var redactionReasons
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @EnvironmentObject private var settingsManager: SettingsManager
    
    private let searchText: String
    
    init(search searchText: String) {
        self.searchText = searchText
    }
    
    var body: some View {        
        let sortedPersons = self.appProperties.sortedPersonsGroups(by: self.settingsManager.sorting.personSorting)
        self.listSection(
            persons: sortedPersons.searchableGroup(of: .withUnpayedFines, search: self.searchText),
            header: LocalizedStringResource("person-list|persons-with-open-fines", comment: "In person list a section title of persons with open fines.")
        )
        self.listSection(
            persons: sortedPersons.searchableGroup(of: .withPayedFines, search: self.searchText),
            header: LocalizedStringResource("person-list|persons-with-all-payed-fines", comment: "In person list a section title of persons with all payed fines.")
        )
    }
    
    @ViewBuilder private func listSection(persons: [Person], header: LocalizedStringResource) -> some View {
        if !persons.isEmpty {
            Section {
                ForEach(persons) { person in
                    NavigationLink {
                        PersonDetail(self.personBinding(of: person))
                    } label: {
                        PersonRow(person)
                            .deletable
                    }.disabled(self.redactionReasons.contains(.placeholder))
                }
            } header: {
                Text(header)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontWeight(.bold)
                    .unredacted()
            }
        }
    }
    
    private func personBinding(of person: Person) -> Binding<Person> {
        return Binding {
            return self.appProperties.persons[person.id] ?? person
        } set: { newPerson in
            self.appProperties.persons[person.id] = newPerson
        }
    }
    
    struct PersonRow: View {
        
        @Environment(\.redactionReasons) private var redactionReasons
        
        @EnvironmentObject private var appProperties: AppProperties
        
        @EnvironmentObject private var imageStorage: FirebaseImageStorage
        
        private let person: Person
        
        @State private var cannotDeletePersonAlertShown = false
        
        private var isDeletable = false
        
        private var isAmountShown = true
        
        init(_ person: Person) {
            self.person = person
        }
        
        var body: some View {
            HStack {
                if let image = self.imageStorage.personImages[self.person.id] {
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
                Text(self.person.name.formatted())
                if isAmountShown {
                    Spacer()
                    let unpayedAmount = self.appProperties.fines(of: self.person).unpayedAmount
                    if unpayedAmount != .zero {
                        Text(unpayedAmount.formatted(.short))
                            .foregroundColor(.red)
                    }
                }
            }.modifier(self.rootModifiers)
        }
        
        @ModifierBuilder private var rootModifiers: some ViewModifier {
            if self.isDeletable && self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder) {
                SwipeActionsModifier {
                    Button(role: .destructive) {
                        await self.deletePerson()
                    } label: {
                        Label(String(localized: "delete-button", comment: "Text of delete button."), systemImage: "trash")
                            .unredacted()
                    }
                }
            }
            TaskModifier {
                guard await !self.redactionReasons.contains(.placeholder) else {
                    return
                }
                await self.imageStorage.fetch(.person(clubId: self.appProperties.club.id, personId: self.person.id))
            }
            AlertModifier(String(localized: "person-list|cannot-delete-person-alert|title", comment: "Title of the cannot delete person alert in person list."), isPresented: self.$cannotDeletePersonAlertShown) {
                Button {} label: {
                    Text("got-it-button", comment: "Text of a 'got it' button.")
                }
            } message: {
                Text("person-list|cannot-delete-person-alert|message", comment: "Message of the cannot delete person alert in person list cause the person is already registered.")
            }
        }
        
        private func deletePerson() async {
            guard self.isDeletable else {
                return
            }
            do {
                let personDeleteFunction = PersonDeleteFunction(clubId: self.appProperties.club.id, personId: self.person.id)
                try await FirebaseFunctionCaller.shared.call(personDeleteFunction)
                self.appProperties.persons[self.person.id] = nil
            } catch let error as FirebaseFunctionError {
                if error.code == .unavailable {
                    self.cannotDeletePersonAlertShown = true
                }
            } catch {}
        }
        
        var deletable: PersonRow {
            var personRow = self
            personRow.isDeletable = true
            return personRow
        }
        
        var amountHidden: PersonRow {
            var personRow = self
            personRow.isAmountShown = false
            return personRow
        }
    }
}
