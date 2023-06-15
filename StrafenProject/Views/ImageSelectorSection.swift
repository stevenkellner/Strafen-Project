//
//  ImageSelectorSection.swift
//  StrafenProject
//
//  Created by Steven on 13.06.23.
//

import SwiftUI
import PhotosUI

struct ImageSelectorSection: View {
    
    @State private var selectedPhotosPickerItem: PhotosPickerItem?
    
    @Binding private var selectedImage: UIImage?
    
    init(_ image: Binding<UIImage?>) {
        self._selectedImage = image
    }
    
    var body: some View {
        Section {
            if let image = self.selectedImage {
                self.imageRow(image)
                Button {
                    self.selectedImage = nil
                } label: {
                    Text("image-selector|remove-image", comment: "Remove image button in person add and edit.")
                }
            }
            PhotosPicker(selection: self.$selectedPhotosPickerItem, matching: .images, photoLibrary: .shared()) {
                Text("image-selector|select-image", comment: "Select image button in person add and edit.")
            }.onChange(of: self.selectedPhotosPickerItem, perform: self.getSelectedImage)
        }
    }
    
    @ViewBuilder private func imageRow(_ image: UIImage) -> some View {
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
}
