//
//  UIApplication+rootViewController.swift
//  StrafenProject
//
//  Created by Steven on 15.04.23.
//

import UIKit

extension UIApplication {
    var rootViewController: UIViewController? {
        return self.connectedScenes
            .lazy
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first?.rootViewController
    }
}
