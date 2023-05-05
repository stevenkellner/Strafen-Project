//
//  MediumWidgetView.swift
//  StrafenProject
//
//  Created by Steven on 04.05.23.
//

import SwiftUI

struct MediumWidgetView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let widgetProperties: WidgetProperties
    
    init(_ widgetProperties: WidgetProperties) {
        self.widgetProperties = widgetProperties
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                SmallWidgetView(self.widgetProperties)
                    .frame(width: geometry.size.width / 2)
                HStack {
                    let sortedFines = self.widgetProperties.sortedFinesGroups
                    let unpayedFines = sortedFines.sortedList(of: .unpayed)
                    let payedFines = sortedFines.sortedList(of: .unpayed)
                    if !unpayedFines.isEmpty {
                        self.fineList(title: String(localized: "widget-view|unpayed-fines", comment: "Fine list title of unpayed fines."), fines: unpayedFines)
                    } else if !payedFines.isEmpty {
                        self.fineList(title: String(localized: "widget-view|payed-fines", comment: "Fine list title of payed fines."), fines: payedFines)
                    } else {
                        Text("widget-view|no-fines", comment: "In fine list, no fines.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                            .unredacted()
                    }
                }.frame(width: geometry.size.width / 2)
            }
        }.background(self.colorScheme == .light ? Color(uiColor: .systemGray6) : Color.black)
    }
    
    @ViewBuilder private func fineList(title: String, fines: [Fine]) -> some View {
        VStack {
            Text(title)
                .font(.callout)
                .foregroundColor(.secondary)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .unredacted()
                .padding(.horizontal, 5)
            VStack(spacing: 7.5) {
                if fines.endIndex > 0 {
                    self.fineRow(fines[0])
                }
                ForEach(1..<3) { index in
                    if index < fines.endIndex {
                        Divider()
                            .padding(.leading)
                        self.fineRow(fines[1])
                    }
                }
            }.padding(.vertical, 7.5)
                .background(self.colorScheme == .light ? Color.white : Color(uiColor: .systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 5)
        }.padding(.vertical, 7.5)
    }
    
    @ViewBuilder private func fineRow(_ fine: Fine) -> some View {
        Text(fine.reasonMessage)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 5)
    }
}
