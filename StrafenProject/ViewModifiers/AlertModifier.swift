//
//  AlertModifier.swift
//  StrafenProject
//
//  Created by Steven on 13.06.23.
//

import SwiftUI

struct AlertModifier<Title, Actions, Message, Data, Error>: ViewModifier where Title: StringProtocol, Actions: View, Message: View, Error: LocalizedError {
    private enum TitleType {
        case localized(LocalizedStringKey)
        case string(Title)
        case text(Text)
    }
    
    private enum AlertType {
        case actions(actions: () -> Actions)
        case actionsAndMessage(actions: () -> Actions, message: () -> Message)
        case dataActions(data: Data?, actions: (Data) -> Actions)
        case dataActionsAndMessage(data: Data?, actions: (Data) -> Actions, message: (Data) -> Message)
        case errorActions(error: Error?, actions: () -> Actions)
        case errorActionsAndMessage(error: Error?, actions: (Error) -> Actions, message: (Error) -> Message)
    }
    
    private let isPresented: Binding<Bool>
    
    private let titleType: TitleType
    
    private let alertType: AlertType
    
    func body(content: Content) -> some View {
        switch self.alertType {
        case .actions(let actions):
            switch self.titleType {
            case .localized(let localizedStringKey):
                content
                    .alert(localizedStringKey, isPresented: self.isPresented, actions: actions)
            case .string(let title):
                content
                    .alert(title, isPresented: self.isPresented, actions: actions)
            case .text(let text):
                content
                    .alert(text, isPresented: self.isPresented, actions: actions)
            }
        case .actionsAndMessage(let actions, let message):
            switch self.titleType {
            case .localized(let localizedStringKey):
                content
                    .alert(localizedStringKey, isPresented: self.isPresented, actions: actions, message: message)
            case .string(let title):
                content
                    .alert(title, isPresented: self.isPresented, actions: actions, message: message)
            case .text(let text):
                content
                    .alert(text, isPresented: self.isPresented, actions: actions, message: message)
            }
        case .dataActions(let data, let actions):
            switch self.titleType {
            case .localized(let localizedStringKey):
                content
                    .alert(localizedStringKey, isPresented: self.isPresented, presenting: data, actions: actions)
            case .string(let title):
                content
                    .alert(title, isPresented: self.isPresented, presenting: data, actions: actions)
            case .text(let text):
                content
                    .alert(text, isPresented: self.isPresented, presenting: data, actions: actions)
            }
        case .dataActionsAndMessage(let data, let actions, let message):
            switch self.titleType {
            case .localized(let localizedStringKey):
                content
                    .alert(localizedStringKey, isPresented: self.isPresented, presenting: data, actions: actions, message: message)
            case .string(let title):
                content
                    .alert(title, isPresented: self.isPresented, presenting: data, actions: actions, message: message)
            case .text(let text):
                content
                    .alert(text, isPresented: self.isPresented, presenting: data, actions: actions, message: message)
            }
        case .errorActions(let error, let actions):
            content
                .alert(isPresented: self.isPresented, error: error, actions: actions)
        case .errorActionsAndMessage(let error, let actions, let message):
            content
                .alert(isPresented: self.isPresented, error: error, actions: actions, message: message)
        }
    }
}

extension AlertModifier where Title == String, Message == EmptyView, Data == Never, Error == Never {
    
    init(_ titleKey: LocalizedStringKey, isPresented: Binding<Bool>, @ViewBuilder actions: @escaping () -> Actions) {
        self.isPresented = isPresented
        self.titleType = .localized(titleKey)
        self.alertType = .actions(actions: actions)
    }
    
    init(_ title: Text, isPresented: Binding<Bool>, @ViewBuilder actions: @escaping () -> Actions)  {
        self.isPresented = isPresented
        self.titleType = .text(title)
        self.alertType = .actions(actions: actions)
    }
}

extension AlertModifier where Message == EmptyView, Data == Never, Error == Never {
    
    init(_ title: Title, isPresented: Binding<Bool>, @ViewBuilder actions: @escaping () -> Actions) {
        self.isPresented = isPresented
        self.titleType = .string(title)
        self.alertType = .actions(actions: actions)
    }
}

extension AlertModifier where Title == String, Data == Never, Error == Never {
    
    init(_ titleKey: LocalizedStringKey, isPresented: Binding<Bool>, @ViewBuilder actions: @escaping () -> Actions, @ViewBuilder message: @escaping () -> Message) {
        self.isPresented = isPresented
        self.titleType = .localized(titleKey)
        self.alertType = .actionsAndMessage(actions: actions, message: message)
    }
        
    init(_ title: Text, isPresented: Binding<Bool>, @ViewBuilder actions: @escaping () -> Actions, @ViewBuilder message: @escaping () -> Message) {
        self.isPresented = isPresented
        self.titleType = .text(title)
        self.alertType = .actionsAndMessage(actions: actions, message: message)
    }
}

extension AlertModifier where Data == Never, Error == Never {
    
    init(_ title: Title, isPresented: Binding<Bool>, @ViewBuilder actions: @escaping () -> Actions, @ViewBuilder message: @escaping () -> Message) {
        self.isPresented = isPresented
        self.titleType = .string(title)
        self.alertType = .actionsAndMessage(actions: actions, message: message)
    }
}

extension AlertModifier where Title == String, Message == EmptyView, Error == Never {
    
    init(_ titleKey: LocalizedStringKey, isPresented: Binding<Bool>, presenting data: Data?, @ViewBuilder actions: @escaping (Data) -> Actions) {
        self.isPresented = isPresented
        self.titleType = .localized(titleKey)
        self.alertType = .dataActions(data: data, actions: actions)
    }
        
    init(_ title: Text, isPresented: Binding<Bool>, presenting data: Data?, @ViewBuilder actions: @escaping (Data) -> Actions) {
        self.isPresented = isPresented
        self.titleType = .text(title)
        self.alertType = .dataActions(data: data, actions: actions)
    }
}

extension AlertModifier where Message == EmptyView, Error == Never {
    
    init(_ title: Title, isPresented: Binding<Bool>, presenting data: Data?, @ViewBuilder actions: @escaping (Data) -> Actions) {
        self.isPresented = isPresented
        self.titleType = .string(title)
        self.alertType = .dataActions(data: data, actions: actions)
    }
}
extension AlertModifier where Title == String, Error == Never {
    
    init(_ titleKey: LocalizedStringKey, isPresented: Binding<Bool>, presenting data: Data?, @ViewBuilder actions: @escaping (Data) -> Actions, @ViewBuilder message: @escaping (Data) -> Message) {
        self.isPresented = isPresented
        self.titleType = .localized(titleKey)
        self.alertType = .dataActionsAndMessage(data: data, actions: actions, message: message)
    }
    
    init(_ title: Text, isPresented: Binding<Bool>, presenting data: Data?, @ViewBuilder actions: @escaping (Data) -> Actions, @ViewBuilder message: @escaping (Data) -> Message) {
        self.isPresented = isPresented
        self.titleType = .text(title)
        self.alertType = .dataActionsAndMessage(data: data, actions: actions, message: message)
    }
}

extension AlertModifier where Error == Never {
    
    init(_ title: Title, isPresented: Binding<Bool>, presenting data: Data?, @ViewBuilder actions: @escaping (Data) -> Actions, @ViewBuilder message: @escaping (Data) -> Message) {
        self.isPresented = isPresented
        self.titleType = .string(title)
        self.alertType = .dataActionsAndMessage(data: data, actions: actions, message: message)
    }
}

extension AlertModifier where Title == String, Message == EmptyView, Data == Never {
    
    init(isPresented: Binding<Bool>, error: Error?, @ViewBuilder actions: @escaping () -> Actions) {
        self.isPresented = isPresented
        self.titleType = .string("")
        self.alertType = .errorActions(error: error, actions: actions)
    }
}

extension AlertModifier where Title == String, Data == Never {
    
    init(isPresented: Binding<Bool>, error: Error?, @ViewBuilder actions: @escaping (Error) -> Actions, @ViewBuilder message: @escaping (Error) -> Message) {
        self.isPresented = isPresented
        self.titleType = .string("")
        self.alertType = .errorActionsAndMessage(error: error, actions: actions, message: message)
    }
}

extension Never: LocalizedError {}
