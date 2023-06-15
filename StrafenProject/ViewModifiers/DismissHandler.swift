//
//  DismissHandler.swift
//  StrafenProject
//
//  Created by Steven on 01.06.23.
//

import SwiftUI

class DismissHandler: ObservableObject {
    
    @Published private var action: DismissAction?
    
    func setHandler(_ action: DismissAction) {
        self.action = action
    }
    
    func dismiss() {
        self.action?()
    }
}

struct DismissHandlerModifier: ViewModifier {
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var dismissHandler: DismissHandler
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                self.dismissHandler.setHandler(self.dismiss)
            }
    }
}

extension View {
    @available(*, deprecated, message: "Use DismissHandlerModifier instead.")
    @ViewBuilder var dismissHandler: some View {
        ModifiedContent(content: self, modifier: DismissHandlerModifier())
    }
}
