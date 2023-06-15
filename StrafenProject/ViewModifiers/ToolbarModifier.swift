//
//  ToolbarModifier.swift
//  StrafenProject
//
//  Created by Steven on 10.06.23.
//

import SwiftUI

struct ToolbarModifier<ViewContent, ToolbarContent, CustomizableToolbarContent>: ViewModifier where ViewContent: View, ToolbarContent: SwiftUI.ToolbarContent, CustomizableToolbarContent: SwiftUI.CustomizableToolbarContent {
    private enum ToolbarType {
        case view(content: ViewContent)
        case toolbar(content: ToolbarContent)
        case customizableToolbar(id: String, content: CustomizableToolbarContent)
    }
    
    private let toolbarType: ToolbarType
    
    func body(content: Content) -> some View {
        content
    }
}

extension ToolbarModifier where ToolbarContent == EmptyToolbarContent, CustomizableToolbarContent == EmptyCustomizableToolbarContent {
    init(@ViewBuilder content: () -> ViewContent) {
        self.toolbarType = .view(content: content())
    }
}

extension ToolbarModifier where ViewContent == EmptyView, CustomizableToolbarContent == EmptyCustomizableToolbarContent {
    init(@ToolbarContentBuilder content: () -> ToolbarContent) {
        self.toolbarType = .toolbar(content: content())
    }
    
    init(content: ToolbarContent) {
        self.toolbarType = .toolbar(content: content)
    }
}

extension ToolbarModifier where ViewContent == EmptyView, ToolbarContent == EmptyToolbarContent {
    init(id: String, @ToolbarContentBuilder content: () -> CustomizableToolbarContent) {
        self.toolbarType = .customizableToolbar(id: id, content: content())
    }
    
    init(id: String, content: CustomizableToolbarContent) {
        self.toolbarType = .customizableToolbar(id: id, content: content)
    }
}

struct EmptyToolbarContent: ToolbarContent {
    var body: Never {
        return fatalError()
    }
}

struct EmptyCustomizableToolbarContent: CustomizableToolbarContent {
    var body: Never {
        return fatalError()
    }
}
