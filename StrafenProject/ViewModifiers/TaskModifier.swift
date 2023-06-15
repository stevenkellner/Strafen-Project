//
//  TaskModifier.swift
//  StrafenProject
//
//  Created by Steven on 10.06.23.
//

import SwiftUI

struct TaskModifier<T>: ViewModifier where T: Equatable {
    private enum TaskType {
        case `default`(priority: TaskPriority, action: @Sendable () async -> Void)
        case identifable(value: T, priority: TaskPriority, action: @Sendable () async -> Void)
    }
    
    private let taskType: TaskType
    
    init(id value: T, priority: TaskPriority = .userInitiated, _ action: @escaping @Sendable () async -> Void) {
        self.taskType = .identifable(value: value, priority: priority, action: action)
    }
    
    func body(content: Content) -> some View {
        switch self.taskType {
        case .default(let priority, let action):
            content
                .task(priority: priority, action)
        case .identifable(let value, let priority, let action):
            content
                .task(id: value, priority: priority, action)
        }
    }
}

extension TaskModifier where T == Never {
    init(priority: TaskPriority = .userInitiated, _ action: @escaping @Sendable () async -> Void) {
        self.taskType = .default(priority: priority, action: action)
    }
}
