//
//  StrafenProjectApp.swift
//  StrafenProject
//
//  Created by Steven on 06.04.23.
//

import SwiftUI

@main
struct StrafenProjectApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseConfigurator.shared.configure()
        return true
    }
}
