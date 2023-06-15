//
//  SearchableModifier.swift
//  StrafenProject
//
//  Created by Steven on 13.06.23.
//

import SwiftUI

struct SearchableModifier<Prompt>: ViewModifier where Prompt: StringProtocol {
    private enum PromptType {
        case text(Text?)
        case localized(LocalizedStringKey)
        case string(Prompt)
    }
    
    private let text: Binding<String>
    
    private let isPresented: Binding<Bool>?
    
    private let placement: SearchFieldPlacement
    
    private let promptType: PromptType
    
    init(text: Binding<String>, placement: SearchFieldPlacement = .automatic, prompt: Prompt) {
        self.text = text
        self.isPresented = nil
        self.placement = placement
        self.promptType = .string(prompt)
    }
    
    @available(iOS 17.0, macOS 14.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    init(text: Binding<String>, isPresented: Binding<Bool>, placement: SearchFieldPlacement = .automatic, prompt: Prompt) {
        self.text = text
        self.isPresented = isPresented
        self.placement = placement
        self.promptType = .string(prompt)
    }
    
    func body(content: Content) -> some View {
        if let isPresented = self.isPresented, #available(iOS 17.0, macOS 14.0, *) {
            switch self.promptType {
            case .text(let text):
                content
                    .searchable(text: self.text, isPresented: isPresented, placement: self.placement, prompt: text)
            case .localized(let localizedStringKey):
                content
                    .searchable(text: self.text, isPresented: isPresented, placement: self.placement, prompt: localizedStringKey)
            case .string(let prompt):
                content
                    .searchable(text: self.text, isPresented: isPresented, placement: self.placement, prompt: prompt)
            }
        } else {
            switch self.promptType {
            case .text(let text):
                content
                    .searchable(text: self.text, placement: self.placement, prompt: text)
            case .localized(let localizedStringKey):
                content
                    .searchable(text: self.text, placement: self.placement, prompt: localizedStringKey)
            case .string(let prompt):
                content
                    .searchable(text: self.text, placement: self.placement, prompt: prompt)
            }
        }
    }
}

extension SearchableModifier where Prompt == String {
    init(text: Binding<String>, placement: SearchFieldPlacement = .automatic, prompt: Text? = nil) {
        self.text = text
        self.isPresented = nil
        self.placement = placement
        self.promptType = .text(prompt)
    }
    
    @available(iOS 17.0, macOS 14.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    init(text: Binding<String>, isPresented: Binding<Bool>, placement: SearchFieldPlacement = .automatic, prompt: Text? = nil) {
        self.text = text
        self.isPresented = isPresented
        self.placement = placement
        self.promptType = .text(prompt)
    }
    
    init(text: Binding<String>, placement: SearchFieldPlacement = .automatic, prompt: LocalizedStringKey) {
        self.text = text
        self.isPresented = nil
        self.placement = placement
        self.promptType = .localized(prompt)
    }
    
    @available(iOS 17.0, macOS 14.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    init(text: Binding<String>, isPresented: Binding<Bool>, placement: SearchFieldPlacement = .automatic, prompt: LocalizedStringKey) {
        self.text = text
        self.isPresented = isPresented
        self.placement = placement
        self.promptType = .localized(prompt)
    }
}
