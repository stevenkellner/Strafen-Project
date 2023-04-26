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
    
    private let personToEdit: Person?
        
    @State private var firstName = ""
    
    @State private var lastName = ""
    
    @State private var selectedPhotosPickerItem: PhotosPickerItem?
    
    @State private var selectedImage: UIImage?
    
    @State private var showUnknownErrorAlert = false
    
    init(person personToEdit: Person? = nil) {
        self.personToEdit = personToEdit
        if let personToEdit {
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
                            Text("Bild entfernen")
                        }
                    }
                    PhotosPicker(selection: self.$selectedPhotosPickerItem, matching: .images, photoLibrary: .shared()) {
                        Text("Bild auswählen")
                    }.onChange(of: self.selectedPhotosPickerItem, perform: self.getSelectedImage)
                }
                Section {
                    TextField("Vorname", text: self.$firstName)
                    TextField("Nachname (optional)", text: self.$lastName)
                }
            }.navigationTitle("Person")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(self.toolbar)
        }.task(self.fetchInitialPersonImage)
            .alert(self.personToEdit == nil ? "Person konnte nicht hinzugefügt werden." : "Person konnte nicht gespeichert werden.", isPresented: self.$showUnknownErrorAlert) {
                Button {} label: {
                    Text("Verstanden")
                }

            }
    }
    
    @ToolbarContentBuilder var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                self.dismiss()
            } label: {
                Text("Abbrechen")
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                Task {
                    await self.savePerson()
                }
            } label: {
                Text(self.personToEdit == nil ? "Hinzufügen" : "Speichern")
            }.disabled(self.firstName == "")
        }
    }
    
    @Sendable private func fetchInitialPersonImage() async  {
        if let personToEdit = self.personToEdit {
            await self.imageStorage.fetch(.person(clubId: self.appProperties.signedInPerson.club.id, personId: personToEdit.id))
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
    
    private func savePerson() async {
        do {
            let personId = self.personToEdit?.id ?? Person.ID()
            let personName = Person.PersonName(first: self.firstName, last: self.lastName == "" ? nil : self.lastName)
            let person = Person(id: personId, name: personName, fineIds: [], isInvited: false)
            let personEditFunction: PersonEditFunction
            if self.personToEdit == nil {
                personEditFunction = .add(clubId: self.appProperties.signedInPerson.club.id, person: person)
            } else {
                personEditFunction = .update(clubId: self.appProperties.signedInPerson.club.id, person: person)
            }
            try await FirebaseFunctionCaller.shared.call(personEditFunction)
            self.appProperties.persons[personId] = person
            if let image = self.selectedImage {
                try? await self.imageStorage.store(image, for: .person(clubId: self.appProperties.signedInPerson.club.id, personId: personId))
            }
            self.dismiss()
        } catch {
            self.showUnknownErrorAlert = true
        }
    }
}
