//
//  PersonAddAndEdit.swift
//  StrafenProject
//
//  Created by Steven on 26.04.23.
//

import SwiftUI

struct PersonAddAndEdit: View {
    private enum InputFocus {
        case firstName
        case lastName
    }
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var imageStorage: FirebaseImageStorage
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @Binding private var personToEdit: Person?
        
    @State private var firstName = ""
    
    @State private var lastName = ""
        
    @State private var selectedImage: UIImage?
    
    @State private var showUnknownErrorAlert = false
    
    @State private var isMakePersonAdminAlertShown = false
    
    @State private var isMakePersonAdminButtonLoading = false
    
    @State private var isAddAndEditButtonLoading = false
    
    @FocusState private var inputFocus: InputFocus?
    
    init(person personToEdit: Binding<Person?> = .constant(nil)) {
        self._personToEdit = personToEdit
        if let personToEdit = personToEdit.wrappedValue {
            self._firstName = State(initialValue: personToEdit.name.first)
            self._lastName = State(initialValue: personToEdit.name.last ?? "")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                ImageSelectorSection(self.$selectedImage)
                Section {
                    TextField(String(localized: "person-add-and-edit|first-name-textfield", comment: "First name textfield placeholder in person add and edit."), text: self.$firstName)
                        .focused(self.$inputFocus, equals: .firstName)
                    TextField(String(localized: "person-add-and-edit|optional-last-name-textfield", comment: "Optional last name textfield placeholder in person add and edit."), text: self.$lastName)
                        .focused(self.$inputFocus, equals: .lastName)
                }.onChange(of: self.inputFocus) { _ in
                    self.firstName = self.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.lastName = self.lastName.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }.modifier(self.rootModifiers)
        }
    }
    
    @ModifierBuilder private var rootModifiers: some ViewModifier {
        NavigationTitleModifier(localized: LocalizedStringResource("person-add-and-edit|title", comment: "Navigation title of person add and edit."), displayMode: .inline)
        ToolbarModifier(content: self.toolbar)
        TaskModifier(self.fetchInitialPersonImage)
        let unknownErrorAlertTitle = self.personToEdit == nil ?
            String(localized: "person-add-and-edit|unknown-error-alert|cannot-add-title", comment: "Cannot add person alert title in person add and edit.") :
            String(localized: "person-add-and-edit|unknown-error-alert|cannot-save-title", comment: "Cannot save person alert title in person add and edit.")
        AlertModifier(unknownErrorAlertTitle, isPresented: self.$showUnknownErrorAlert) {
            Button {} label: {
                Text("got-it-button", comment: "Text of a 'got it' button.")
            }
        }
        let makePersonAdminAlertTitle = String(localized: "person-add-and-edit|admin-alert|title?name=\(self.personToEdit?.name.formatted() ?? "")", comment: "Title of make person admin alert in person add and edit. 'name' parameter is name of the person to make admin.")
        AlertModifier(makePersonAdminAlertTitle, isPresented: self.$isMakePersonAdminAlertShown) {
            Button {
                await self.makePersonAdmin()
            } label: {
                Text("person-add-and-edit|admin-alert|make-admin-button", comment: "Make person admin button of alert in person add and edit.")
            }
            Button(role: .cancel) {} label: {
                Text("cancel-button", comment: "Text of cancel button.")
            }
        } message: {
            Text("person-add-and-edit|admin-alert|message", comment: "Message of make person admin alert in person add and edit.")
        }
    }
    
    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarButton(placement: .topBarLeading, localized: LocalizedStringResource("cancel-button", comment: "Text of cancel button.")) {
            self.dismiss()
        }
        if let signInData = self.personToEdit?.signInData, !signInData.authentication.contains(.clubManager) {
            ToolbarButton(placement: .topBarTrailing, localized: LocalizedStringResource("person-add-and-edit|admin-button", comment: "Make person to admin button in person add and edit.")) {
                self.isMakePersonAdminAlertShown = true
            }.loading(self.isAddAndEditButtonLoading)
        }
        ToolbarButton(placement: .topBarLeading, localized: self.personToEdit == nil ? LocalizedStringResource("person-add-and-edit|add-button", comment: "Add person button in person add and edit.") : LocalizedStringResource("person-add-and-edit|save-button", comment: "Save person button in person add and edit.")) {
            await self.savePerson()
        }.loading(self.isAddAndEditButtonLoading)
            .disabled(self.firstName == "")
    }
        
    @Sendable private func fetchInitialPersonImage() async  {
        if let personToEdit = self.personToEdit {
            await self.imageStorage.fetch(.person(clubId: self.appProperties.club.id, personId: personToEdit.id))
            if self.selectedImage == nil {
                self.selectedImage = self.imageStorage.personImages[personToEdit.id]
            }
        }
    }
        
    private func makePersonAdmin() async {
        self.isMakePersonAdminButtonLoading = true
        defer {
            self.isMakePersonAdminButtonLoading = false
        }
        guard let person = self.personToEdit else {
            return
        }
        do {
            let personMakeManagerFunction = PersonMakeManagerFunction(clubId: self.appProperties.club.id, personId: person.id)
            try await FirebaseFunctionCaller.shared.call(personMakeManagerFunction)
            if let containsClubMananger = self.appProperties.persons[person.id]?.signInData?.authentication.contains(.clubManager), !containsClubMananger {
                self.appProperties.persons[person.id]?.signInData?.authentication.append(.clubManager)
            }
        } catch {}
    }
    
    private func savePerson() async {
        self.isAddAndEditButtonLoading = true
        defer {
            self.isAddAndEditButtonLoading = false
        }
        self.firstName = self.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.lastName = self.lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let personId = self.personToEdit?.id ?? Person.ID()
            let personName = PersonName(first: self.firstName, last: self.lastName == "" ? nil : self.lastName)
            let person = Person(id: personId, name: personName, fineIds: [], isInvited: false)
            if self.personToEdit == nil {
                let personAddFunction = PersonAddFunction(clubId: self.appProperties.club.id, person: person)
                try await FirebaseFunctionCaller.shared.call(personAddFunction)
            } else {
                let personUpdateFunction = PersonUpdateFunction(clubId: self.appProperties.club.id, person: person)
                try await FirebaseFunctionCaller.shared.call(personUpdateFunction)
            }
            self.appProperties.persons[personId] = person
            if let image = self.selectedImage {
                try? await self.imageStorage.store(image, for: .person(clubId: self.appProperties.club.id, personId: personId))
            } else {
                await self.imageStorage.delete(.person(clubId: self.appProperties.club.id, personId: personId))
            }
            self.reset()
            self.dismiss()
        } catch {
            self.showUnknownErrorAlert = true
        }
    }
    
    private func reset() {
        self.firstName = ""
        self.lastName = ""
        self.selectedImage = nil
    }
}
