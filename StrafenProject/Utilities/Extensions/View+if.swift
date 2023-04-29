//
//  View+if.swift
//  StrafenProject
//
//  Created by Steven on 21.04.23.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<Content>(_ condition: Bool, transform: (Self) -> Content) -> some View where Content: View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
