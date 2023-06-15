//
//  NavigationTitleModifier.swift
//  StrafenProject
//
//  Created by Steven on 10.06.23.
//

import SwiftUI

struct NavigationTitleModifier: ViewModifier {
    
    private let title: String
    
    private let displayMode: NavigationBarItem.TitleDisplayMode
    
    init(_ title: String, displayMode: NavigationBarItem.TitleDisplayMode = .automatic) {
        self.title = title
        self.displayMode = displayMode
    }
    
    init(localized title: LocalizedStringResource, displayMode: NavigationBarItem.TitleDisplayMode = .automatic) {
        self.title = String(localized: title)
        self.displayMode = displayMode
    }
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(self.title)
            .navigationBarTitleDisplayMode(self.displayMode)
    }
}
