//
//  RefreshableModifier.swift
//  StrafenProject
//
//  Created by Steven on 10.06.23.
//

import SwiftUI

struct RefreshableModifier: ViewModifier {
    
    private let action: @Sendable () async -> Void
    
    init(action: @escaping @Sendable () async -> Void) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .refreshable(action: self.action)
    }
}
