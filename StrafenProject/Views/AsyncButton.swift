//
//  AsyncButton.swift
//  StrafenProject
//
//  Created by Steven on 02.07.23.
//

import SwiftUI

struct AsyncButton<Label>: View where Label: View {
    
    private let role: ButtonRole?
    
    private let action: () async -> Void
    
    private let label: () -> Label
    
    @State private var isPerformingTask = false
    
    init(role: ButtonRole? = nil, action: @escaping () async -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.role = role
        self.action = action
        self.label = label
    }
    
    var body: some View {
        Button(role: self.role) {
            self.isPerformingTask = true
            Task {
                await self.action()
                self.isPerformingTask = false
            }
        } label: {
            ZStack {
                self.label()
                    .opacity(self.isPerformingTask ? 0 : 1)
                if self.isPerformingTask {
                    ProgressView()
                }
            }
        }.disabled(self.isPerformingTask)
    }
}

extension AsyncButton where Label == Text {
    init(role: ButtonRole? = nil, _ label: String, action: @escaping () async -> Void) {
        self.init(role: role, action: action) {
            Text(label)
        }
    }
}

extension AsyncButton where Label == Image {
    init(role: ButtonRole? = nil, systemImageName: String, action: @escaping () async -> Void) {
        self.init(role: role, action: action) {
            Image(systemName: systemImageName)
        }
    }
}
