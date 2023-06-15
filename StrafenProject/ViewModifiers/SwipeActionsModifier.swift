//
//  SwipeActionsModifier.swift
//  StrafenProject
//
//  Created by Steven on 13.06.23.
//

import SwiftUI

struct SwipeActionsModifier<T>: ViewModifier where T: View {
    
    private let edge: HorizontalEdge
    
    private let allowsFullSwipe: Bool
    
    private let content: T
    
    init(edge: HorizontalEdge = .trailing, allowsFullSwipe: Bool = true, @ViewBuilder content: () -> T) {
        self.edge = edge
        self.allowsFullSwipe = allowsFullSwipe
        self.content = content()
    }
    
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: self.edge, allowsFullSwipe: self.allowsFullSwipe) {
                self.content
            }
    }
}
