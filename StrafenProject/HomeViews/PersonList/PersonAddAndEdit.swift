//
//  PersonAddAndEdit.swift
//  StrafenProject
//
//  Created by Steven on 26.04.23.
//

import SwiftUI
import PhotosUI

struct PersonAddAndEdit: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var imageStorage: FirebaseImageStorage
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @Binding private var personToEdit: Person?
        
    @State private var firstName = ""
    
    @State private var lastName = ""
    
    @State private var selectedPhotosPickerItem: PhotosPickerItem?
    
    @State private var selectedImage: UIImage?
    
    @State private var showUnknownErrorAlert = false
    
    @State private var isMakePersonAdminAlertShown = false
    
    @State private var isMakePersonAdminButtonLoading = false
    
    @State private var isAddAndEditButtonLoading = false
    
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
                Section {
                    if let image = self.selectedImage {
                        HStack {
                            Spacer()
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            Spacer()
                        }
                        Button {
                            self.selectedImage = nil
                        } label: {
                            Text("person-add-and-edit|remove-image", comment: "Remove image button in person add and edit.")
                        }
                    }
                    PhotosPicker(selection: self.$selectedPhotosPickerItem, matching: .images, photoLibrary: .shared()) {
                        Text("person-add-and-edit|select-image", comment: "Select image button in person add and edit.")
                    }.onChange(of: self.selectedPhotosPickerItem, perform: self.getSelectedImage)
                }
                Section {
                    TextField(String(localized: "person-add-and-edit|first-name-textfield", comment: "First name textfield placeholder in person add and edit."), text: self.$firstName)
                    TextField(String(localized: "person-add-and-edit|optional-last-name-textfield", comment: "Optional last name textfield placeholder in person add and edit."), text: self.$lastName)
                }
            }.navigationTitle(String(localized: "person-add-and-edit|title", comment: "Navigation title of person add and edit."))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(self.toolbar)
        }.task(self.fetchInitialPersonImage)
            .alert(self.unknownErrorAlertTitle, isPresented: self.$showUnknownErrorAlert) {
                Button {} label: {
                    Text("got-it-button", comment: "Text of a 'got it' button.")
                }
            }.alert("\(self.personToEdit?.name.formatted() ?? "") zum Admin machen.", isPresented: self.$isMakePersonAdminAlertShown) {
                Button {
                    Task {
                        await self.makePersonAdmin()
                    }
                } label: {
                    Text("Zum Admin machen")
                }
                Button(role: .cancel) {} label: {
                    Text("cancel-button", comment: "Text of cancel button.")
                }
            } message: {
                Text("Diese Person hat dann die selben Recht wie du. Es kann nicht mehr rückgängig gemacht werden.")
            }
    }
    
    @ToolbarContentBuilder var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                self.dismiss()
            } label: {
                Text("cancel-button", comment: "Text of cancel button.")
            }
        }
        if let signInData = self.personToEdit?.signInData, !signInData.authentication.contains(.clubManager) {
            ToolbarItem(placement: .navigationBarTrailing) {
                if self.isAddAndEditButtonLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    Button {
                        self.isMakePersonAdminAlertShown = true
                    } label: {
                        Text("Admin")
                    }
                }
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            if self.isAddAndEditButtonLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Button {
                    Task {
                        await self.savePerson()
                    }
                } label: {
                    Text(self.personToEdit == nil ? String(localized: "person-add-and-edit|add-button", comment: "Add person button in person add and edit.") : String(localized: "person-add-and-edit|save-button", comment: "Save person button in person add and edit."))
                }.disabled(self.firstName == "")
            }
        }
    }
    
    private var unknownErrorAlertTitle: String {
        if self.personToEdit == nil {
            return String(localized: "person-add-and-edit|unknown-error-alert|cannot-add-title", comment: "Cannot add person alert title in person add and edit.")
        }
        return String(localized: "person-add-and-edit|unknown-error-alert|cannot-save-title", comment: "Cannot save person alert title in person add and edit.")
    }
    
    @Sendable private func fetchInitialPersonImage() async  {
        if let personToEdit = self.personToEdit {
            await self.imageStorage.fetch(.person(clubId: self.appProperties.club.id, personId: personToEdit.id))
            if self.selectedImage == nil {
                self.selectedImage = self.imageStorage.personImages[personToEdit.id]
            }
        }
    }
    
    private func getSelectedImage(_ photosPickerItem: PhotosPickerItem?) {
        guard let photosPickerItem else {
            return
        }
        Task {
            guard let imageData = try await photosPickerItem.loadTransferable(type: Data.self),
                  let image = UIImage(data: imageData) else {
                return
            }
            self.selectedImage = image
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
        do {
            let personId = self.personToEdit?.id ?? Person.ID()
            let personName = PersonName(first: self.firstName, last: self.lastName == "" ? nil : self.lastName)
            let person = Person(id: personId, name: personName, fineIds: [], isInvited: false)
            let personEditFunction: PersonEditFunction
            if self.personToEdit == nil {
                personEditFunction = .add(clubId: self.appProperties.club.id, person: person)
            } else {
                personEditFunction = .update(clubId: self.appProperties.club.id, person: person)
            }
            try await FirebaseFunctionCaller.shared.call(personEditFunction)
            self.appProperties.persons[personId] = person
            if let image = self.selectedImage {
                try? await self.imageStorage.store(image, for: .person(clubId: self.appProperties.club.id, personId: personId))
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
        self.selectedPhotosPickerItem = nil
        self.selectedImage = nil
    }
}
