//
//  ProfileChangeImage.swift
//  StrafenProject
//
//  Created by Steven on 29.04.23.
//

import SwiftUI

struct ProfileChangeImage: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @EnvironmentObject private var imageStorage: FirebaseImageStorage
    
    @State private var selectedImage: UIImage?
    
    @State private var isSaveImageButtonLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                ImageSelectorSection(self.$selectedImage)
            }.modifier(self.rootModifiers)
        }
    }
    
    
    @ModifierBuilder private var rootModifiers: some ViewModifier {
        NavigationTitleModifier(localized: LocalizedStringResource("profile-change-image|title", comment: "Title of change profile image."))
        TaskModifier { @MainActor in
                await self.imageStorage.fetch(.person(clubId: self.appProperties.club.id, personId: self.appProperties.signedInPerson.id))
                self.selectedImage = self.imageStorage.personImages[self.appProperties.signedInPerson.id]
        }
        ToolbarModifier {
            ToolbarButton(placement: .topBarLeading, localized: LocalizedStringResource("cancel-button", comment: "Text of cancel button.")) {
                self.dismiss()
            }
            ToolbarButton(placement: .topBarTrailing, localized: LocalizedStringResource("profile-change-image|save-button", comment: "Save profile image button in profile change image.")) {
                await self.saveImage()
            }.loading(self.isSaveImageButtonLoading)
        }
    }
        
    private func saveImage() async {
        self.isSaveImageButtonLoading = true
        defer {
            self.isSaveImageButtonLoading = false
        }
        if let image = self.selectedImage {
            try? await self.imageStorage.store(image, for: .person(clubId: self.appProperties.club.id, personId: self.appProperties.signedInPerson.id))
        } else {
            await self.imageStorage.delete(.person(clubId: self.appProperties.club.id, personId: self.appProperties.signedInPerson.id))
        }
        self.dismiss()
    }
}
