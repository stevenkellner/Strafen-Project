//
//  View+toolbar.swift
//  StrafenProject
//
//  Created by Steven on 26.04.23.
//

import SwiftUI

extension View {
    @ViewBuilder func toolbar(_ content: some ToolbarContent) -> some View {
        self.toolbar {
            content
        }
    }
}
