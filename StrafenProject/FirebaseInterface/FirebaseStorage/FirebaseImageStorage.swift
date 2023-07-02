//
//  FirebaseImageStorage.swift
//  StrafenProject
//
//  Created by Steven on 21.04.23.
//

import Foundation
import UIKit
import FirebaseStorage

@MainActor
class FirebaseImageStorage: ObservableObject {
    enum Error: Swift.Error {
        case invalidJpegData
    }
    
    static private let storageBucketUrl = "gs://strafen-project-images"
        
    @Published public private(set) var clubImage: UIImage?
    
    @Published public private(set) var personImages = FirebaseStorageCache<Person.ID, UIImage>(max: 50)
    
    private func saveCache(image: UIImage?, for imageType: FirebaseStorageImageType) {
        switch imageType {
        case .club(_):
            self.clubImage = image
        case .person(_, let personId):
            self.personImages[personId] = image
        }
    }
    
    private func getCache(for imageType: FirebaseStorageImageType) -> UIImage? {
        switch imageType {
        case .club(_):
            return self.clubImage
        case .person(_, let personId):
            return self.personImages[personId]
        }
    }
    
    func store(_ image: UIImage, for imageType: FirebaseStorageImageType) async throws {
        let compressionQuality: CGFloat = 0.85
        guard let image = self.resizedImage(image),
              let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            throw Error.invalidJpegData
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await Storage
            .storage(url: FirebaseImageStorage.storageBucketUrl)
            .reference(withPath: imageType.imageUrl.path())
            .putDataAsync(imageData, metadata: metadata)
        self.saveCache(image: image, for: imageType)
    }
    
    private func resizedImage(_ image: UIImage) -> UIImage? {
        let dimension: Double = 512
        let imageSize = image.size
        guard max(imageSize.width, imageSize.height) > dimension else {
            return image
        }
        let newSize = imageSize.width > imageSize.height ? CGSize(width: dimension, height: dimension * imageSize.height / imageSize.width) : CGSize(width: dimension * imageSize.width / imageSize.height, height: dimension)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer {
            UIGraphicsEndImageContext()
        }
        image.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func fetch(_ imageType: FirebaseStorageImageType, useCachedImage: Bool = true) async {
        guard !useCachedImage || self.getCache(for: imageType) == nil else {
            return
        }
        let maxSize: Int64 = 1024 * 1024 // 1MB
        do {
            let imageData = try await Storage
                .storage(url: FirebaseImageStorage.storageBucketUrl)
                .reference(withPath: imageType.imageUrl.path())
                .data(maxSize: maxSize)
            guard let image = UIImage(data: imageData) else {
                return
            }
            self.saveCache(image: image, for: imageType)
        } catch {}
    }
    
    func delete(_ imageType: FirebaseStorageImageType) async {
        do {
            try await Storage
                .storage(url: FirebaseImageStorage.storageBucketUrl)
                .reference(withPath: imageType.imageUrl.path())
                .delete()
            self.saveCache(image: nil, for: imageType)
        } catch {}
    }
    
    func clear() {
        self.clubImage = nil
        self.personImages.clear()
    }
}
