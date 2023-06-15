//
//  SheetModifier.swift
//  StrafenProject
//
//  Created by Steven on 10.06.23.
//

import SwiftUI

struct SheetModifier<Item, SheetContent>: ViewModifier where Item: Identifiable, SheetContent: View {
    private enum SheetType {
        case bool(isPresented: Binding<Bool>, onDismiss: (() -> Void)?, content: () -> SheetContent)
        case item(item: Binding<Item?>, onDismiss: (() -> Void)?, content: (Item) -> SheetContent)
    }
    
    private let sheetType: SheetType
    
    init(item: Binding<Item?>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping (Item) -> SheetContent) {
        self.sheetType = .item(item: item, onDismiss: onDismiss, content: content)
    }
    
    func body(content: Content) -> some View {
        switch self.sheetType {
        case .bool(let isPresented, let onDismiss, let sheetContent):
            content
                .sheet(isPresented: isPresented, onDismiss: onDismiss, content: sheetContent)
        case .item(let item, let onDismiss, let sheetContent):
            content
                .sheet(item: item, onDismiss: onDismiss, content: sheetContent)
        }
    }
}

extension SheetModifier where Item == Never {
    init(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> SheetContent) {
        self.sheetType = .bool(isPresented: isPresented, onDismiss: onDismiss, content: content)
    }
}
