//
//  Toolbar.swift
//  StrafenProject
//
//  Created by Steven on 19.04.23.
//

import SwiftUI

struct BottomBar {
    enum Item {
        case profile
        case personList
        case reasonTemplateList
        case addNewFine
        case settings
    }
}

struct BottomBarModifier: ViewModifier {
    
    @StateObject private var settingsManager = SettingsManager()
    
    private var bottomBarItem: Binding<BottomBar.Item>
    
    init(active bottomBarItem: Binding<BottomBar.Item>) {
        self.bottomBarItem = bottomBarItem
    }
    
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                        bottomBarItem.wrappedValue = .profile
                    } label: {
                        Label(String(localized: "bottom-bar|profile", comment: "Bottom bar profile label."), systemImage: "person")
                            .labelStyle(.verticalIconAndTitle)
                            .foregroundColor(bottomBarItem.wrappedValue == .profile ? .secondary : nil)
                    }
                    Button {
                        bottomBarItem.wrappedValue = .personList
                    } label: {
                        Label(String(localized: "bottom-bar|person-list", comment: "Bottom bar person list label."), systemImage: "person.2")
                            .labelStyle(.verticalIconAndTitle)
                            .foregroundColor(bottomBarItem.wrappedValue == .personList ? .secondary : nil)
                    }
                    Button {
                        bottomBarItem.wrappedValue = .reasonTemplateList
                    } label: {
                        Label(String(localized: "bottom-bar|reason-list", comment: "Bottom bar reason list label."), systemImage: "list.dash")
                            .labelStyle(.verticalIconAndTitle)
                            .foregroundColor(bottomBarItem.wrappedValue == .reasonTemplateList ? .secondary : nil)
                    }
                    if FirebaseAuthenticator.shared.user != nil,
                       let signedInPerson = self.settingsManager.signedInPerson,
                       signedInPerson.isAdmin {
                        Button {
                            bottomBarItem.wrappedValue = .addNewFine
                        } label: {
                            Label(String(localized: "bottom-bar|add-new-fine", comment: "Bottom bar add new fine label."), systemImage: "plus")
                                .labelStyle(.verticalIconAndTitle)
                                .foregroundColor(bottomBarItem.wrappedValue == .addNewFine ? .secondary : nil)
                        }
                    }
                    Button {
                        bottomBarItem.wrappedValue = .settings
                    } label: {
                        Label(String(localized: "bottom-bar|settings", comment: "Bottom bar settings label."), systemImage: "gear")
                            .labelStyle(.verticalIconAndTitle)
                            .foregroundColor(bottomBarItem.wrappedValue == .settings ? .secondary : nil)
                    }
                }
            }
        }
    }
}

extension View {
    func bottomBar(active bottomBarItem: Binding<BottomBar.Item>) -> some View {
        return self.modifier(BottomBarModifier(active: bottomBarItem))
    }
}

struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
                .frame(height: 20)
            configuration.title
                .font(.caption2)
                .fontWeight(.light)
        }
    }
}

extension LabelStyle where Self == VerticalLabelStyle {
    static var verticalIconAndTitle: VerticalLabelStyle {
        return VerticalLabelStyle()
    }
}
