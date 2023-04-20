//
//  Toolbar.swift
//  StrafenProject
//
//  Created by Steven on 19.04.23.
//

import SwiftUI

extension View {
    @ViewBuilder func toolbar(active toolbarItem: Binding<Toolbar.Item>) -> some View {
        self.toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                        toolbarItem.wrappedValue = .profile
                    } label: {
                        Label(String(localized: "bottom-bar|profile", comment: "Bottom bar profile label."), systemImage: "person")
                            .labelStyle(.verticalIconAndTitle)
                    }
                    Button {
                        toolbarItem.wrappedValue = .personList
                    } label: {
                        Label(String(localized: "bottom-bar|person-list", comment: "Bottom bar person list label."), systemImage: "person.2")
                            .labelStyle(.verticalIconAndTitle)
                    }
                    Button {
                        toolbarItem.wrappedValue = .reasonList
                    } label: {
                        Label(String(localized: "bottom-bar|reason-list", comment: "Bottom bar reason list label."), systemImage: "list.dash")
                            .labelStyle(.verticalIconAndTitle)
                    }
                    Button {
                        toolbarItem.wrappedValue = .addNewFine
                    } label: {
                        Label(String(localized: "bottom-bar|add-new-fine", comment: "Bottom bar add new fine label."), systemImage: "plus")
                            .labelStyle(.verticalIconAndTitle)
                    }
                    Button {
                        toolbarItem.wrappedValue = .settings
                    } label: {
                        Label(String(localized: "bottom-bar|settings", comment: "Bottom bar settings label."), systemImage: "gear")
                            .labelStyle(.verticalIconAndTitle)
                    }
                }
            }
        }
    }
}

struct Toolbar {
    enum Item {
        case profile
        case personList
        case reasonList
        case addNewFine
        case settings
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
