//
//  ProfileChangeImage.swift
//  StrafenProject
//
//  Created by Steven on 29.04.23.
//

import SwiftUI
import PhotosUI

struct ProfileChangeImage: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @EnvironmentObject private var imageStorage: FirebaseImageStorage
    
    @State private var selectedPhotosPickerItem: PhotosPickerItem?
    
    @State private var selectedImage: UIImage?
    
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
            }.navigationTitle(String(localized: "profile-change-image|title", comment: "Title of change profile image."))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            self.dismiss()
                        } label: {
                            Text("cancel-button", comment: "Text of cancel button.")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            Task {
                                await self.saveImage()
                            }
                        } label: {
                            Text("profile-change-image|save-button", comment: "Save profile image button in profile change image.")
                        }
                    }
                }
        }.task {
            await self.imageStorage.fetch(.person(clubId: self.appProperties.club.id, personId: self.appProperties.signedInPerson.id))
            self.selectedImage = self.imageStorage.personImages[self.appProperties.signedInPerson.id]
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
    
    private func saveImage() async {
        if let image = self.selectedImage {
            try? await self.imageStorage.store(image, for: .person(clubId: self.appProperties.club.id, personId: self.appProperties.signedInPerson.id))
        } else {
            await self.imageStorage.delete(.person(clubId: self.appProperties.club.id, personId: self.appProperties.signedInPerson.id))
        }
        self.dismiss()
    }
}
