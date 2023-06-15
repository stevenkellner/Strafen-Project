//
//  ToolbarButton.swift
//  StrafenProject
//
//  Created by Steven on 10.06.23.
//

import SwiftUI

struct ToolbarButton: ToolbarContent {
    private enum LabelType {
        case text(value: String)
        case image(systemName: String)
    }
    
    private let id: String?
    
    private let placement: ToolbarItemPlacement
    
    private let labelType: LabelType
    
    private let action: () -> Void
    
    private var isDisabled = false
    
    private var isUnredacted = false
    
    private var isLoading = false
    
    init(id: String? = nil, placement: ToolbarItemPlacement = .automatic, localized label: LocalizedStringResource, action: @escaping () -> Void) {
        self.id = id
        self.placement = placement
        self.labelType = .text(value: String(localized: label))
        self.action = action
    }
    
    init(id: String? = nil, placement: ToolbarItemPlacement = .automatic, localized label: LocalizedStringResource, action: @escaping @Sendable () async -> Void) {
        self.id = id
        self.placement = placement
        self.labelType = .text(value: String(localized: label))
        self.action = {
            Task(operation: action)
        }
    }
    
    init(id: String? = nil, placement: ToolbarItemPlacement = .automatic, label: String, action: @escaping () -> Void) {
        self.id = id
        self.placement = placement
        self.labelType = .text(value: label)
        self.action = action
    }
    
    init(id: String? = nil, placement: ToolbarItemPlacement = .automatic, label: String, action: @escaping @Sendable () async -> Void) {
        self.id = id
        self.placement = placement
        self.labelType = .text(value: label)
        self.action = {
            Task(operation: action)
        }
    }
    
    init(id: String? = nil, placement: ToolbarItemPlacement = .automatic, systemImage: String, action: @escaping () -> Void) {
        self.id = id
        self.placement = placement
        self.labelType = .image(systemName: systemImage)
        self.action = action
    }
    
    init(id: String? = nil, placement: ToolbarItemPlacement = .automatic, systemImage: String, action: @escaping @Sendable () async -> Void) {
        self.id = id
        self.placement = placement
        self.labelType = .image(systemName: systemImage)
        self.action = {
            Task(operation: action)
        }
    }
    
    var body: some ToolbarContent {
        if let id = self.id {
            ToolbarItem(id: id, placement: self.placement) {
                self.toolbarItemContent
            }
        } else {
            ToolbarItem(placement: self.placement) {
                self.toolbarItemContent
            }
        }
    }
    
    @ViewBuilder private var toolbarItemContent: some View {
        if self.isLoading {
            ProgressView()
                .progressViewStyle(.circular)
        } else {
            Button(action: action) {
                switch self.labelType {
                case .text(let value):
                    Text(value)
                case .image(let systemName):
                    Image(systemName: systemName)
                }
            }.disabled(self.isDisabled)
                .if(self.isUnredacted) { content in
                    content.unredacted()
                }
        }
    }
    
    func disabled(_ isDisabled:  Bool) -> ToolbarButton {
        var toolbarButton = self
        toolbarButton.isDisabled = isDisabled
        return toolbarButton
    }
    
    var unredacted: ToolbarButton {
        var toolbarButton = self
        toolbarButton.isUnredacted = true
        return toolbarButton
    }
    
    func loading(_ isLoading: Bool) -> ToolbarButton {
        var toolbarButton = self
        toolbarButton.isLoading = isLoading
        return toolbarButton
    }
}
