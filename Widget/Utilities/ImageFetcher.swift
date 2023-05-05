//
//  ImageFetcher.swift
//  StrafenProject
//
//  Created by Steven on 04.05.23.
//

import UIKit.UIImage
import FirebaseStorage

struct ImageFetcher {
    
    static let shared = ImageFetcher()
    
    private init() {}
    
    func fetch(clubId: ClubProperties.ID, personId: Person.ID) async -> UIImage? {
        let url = URL(string: DatabaseType.current.rawValue)!
            .appending(component: clubId.uuidString.uppercased())
            .appending(path: personId.uuidString.uppercased())
            .appendingPathExtension("jpeg")
        let maxSize: Int64 = 64 * 1024 * 1024 // 64 MB
        let imageData = try? await Storage
            .storage(url: "gs://strafen-project-images")
            .reference(withPath: url.path())
            .data(maxSize: maxSize)
        guard let imageData else {
            return nil
        }
        guard let image = UIImage(data: imageData) else {
            return nil
        }
        return self.resizeImage(image, size: CGSize(width: 128, height: 128))
    }
    
    private func resizeImage(_ image: UIImage, size targetSize: CGSize) -> UIImage? {
        let widthRatio = targetSize.width / image.size.width
        let heightRatio = targetSize.height / image.size.height
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: image.size.width * heightRatio, height: image.size.height * heightRatio)
        } else {
            newSize = CGSize(width: image.size.width * widthRatio,  height: image.size.height * widthRatio)
        }
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
