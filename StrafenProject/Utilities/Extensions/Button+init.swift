//
//  Button+init.swift
//  StrafenProject
//
//  Created by Steven on 13.06.23.
//

import SwiftUI

extension Button {
    
    init(action: @escaping @Sendable () async -> Void, @ViewBuilder label: () -> Label) {
        self.init(action: { Task(operation: action) }, label: label)
    }
    
    init(role: ButtonRole?, action: @escaping @Sendable () async -> Void, @ViewBuilder label: () -> Label) {
        self.init(role: role, action: { Task(operation: action) }, label: label)
    }
}

extension Button where Label == Text {
    
    init(_ titleKey: LocalizedStringKey, action: @escaping @Sendable () async -> Void) {
        self.init(titleKey, action: { Task(operation: action) })
    }
    
    init<S>(_ title: S, action: @escaping @Sendable () async -> Void) where S: StringProtocol {
        self.init(title, action: { Task(operation: action) })
    }
    
    init(_ titleKey: LocalizedStringKey, role: ButtonRole?, action: @escaping @Sendable () async -> Void) {
        self.init(titleKey, role: role, action: { Task(operation: action) })
    }
    
    init<S>(_ title: S, role: ButtonRole?, action: @escaping @Sendable () async -> Void) where S: StringProtocol {
        self.init(title, role: role, action: { Task(operation: action) })
    }
}
