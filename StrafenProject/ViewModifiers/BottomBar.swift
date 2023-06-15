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
    
    @EnvironmentObject private var dismissHandler: DismissHandler
    
    @StateObject private var settingsManager = SettingsManager()
    
    private var bottomBarItem: Binding<BottomBar.Item>
    
    init(active bottomBarItem: Binding<BottomBar.Item>) {
        self.bottomBarItem = bottomBarItem
    }
    
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    self.barButton(item: .profile, image: "person", label: String(localized: "bottom-bar|profile", comment: "Bottom bar profile label."))
                    self.barButton(item: .personList, image: "person.2", label: String(localized: "bottom-bar|person-list", comment: "Bottom bar person list label."))
                    self.barButton(item: .reasonTemplateList, image: "list.dash", label: String(localized: "bottom-bar|reason-list", comment: "Bottom bar reason list label."))
                    if FirebaseAuthenticator.shared.user != nil,
                       let signedInPerson = self.settingsManager.signedInPerson,
                       signedInPerson.isAdmin {
                        self.barButton(item: .addNewFine, image: "plus", label: String(localized: "bottom-bar|add-new-fine", comment: "Bottom bar add new fine label."))
                    }
                    self.barButton(item: .settings, image: "gear", label: String(localized: "bottom-bar|settings", comment: "Bottom bar settings label."))
                }
            }
        }
    }
    
    @ViewBuilder private func barButton(item bottomBarItem: BottomBar.Item, image systemName: String, label: String) -> some View {
        Button {
            self.dismissHandler.dismiss()
            self.bottomBarItem.wrappedValue = bottomBarItem
        } label: {
            Label(label, systemImage: systemName)
                .labelStyle(.verticalIconAndTitle)
                .foregroundColor(self.bottomBarItem.wrappedValue == bottomBarItem ? .secondary : nil)
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
