//
//  LargeWidgetView.swift
//  StrafenProject
//
//  Created by Steven on 04.05.23.
//

import SwiftUI

struct LargeWidgetView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let widgetProperties: WidgetProperties
    
    init(_ widgetProperties: WidgetProperties) {
        self.widgetProperties = widgetProperties
    }
    
    var body: some View {
        VStack {
            HStack {
                if let image = self.widgetProperties.personImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 25, height: 25)
                        .clipShape(Circle())
                }
                Text(self.widgetProperties.signedInPerson.name.formatted())
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.padding(.horizontal, 5)
                .padding(.top)
            HStack {
                HStack {
                    Text("widget-view|open-fines-amount", comment: "Text before the total open fines amount.")
                        .lineLimit(1)
                        .unredacted()
                    Spacer(minLength: 5)
                    Text(self.widgetProperties.fines.unpayedAmount.formatted)
                        .foregroundColor(.red)
                        .lineLimit(1)
                }.padding(.horizontal, 5)
                    .padding(.vertical, 7.5)
                    .background(self.colorScheme == .light ? Color.white : Color(uiColor: .systemGray6))
                    .cornerRadius(10)
                HStack {
                    Text("widget-view|total-amount", comment: "Text before the total amount.")
                        .lineLimit(1)
                        .unredacted()
                    Spacer(minLength: 5)
                    Text(self.widgetProperties.fines.totalAmount.formatted)
                        .foregroundColor(.green)
                        .lineLimit(1)
                }.padding(.horizontal, 5)
                    .padding(.vertical, 7.5)
                    .background(self.colorScheme == .light ? Color.white : Color(uiColor: .systemGray6))
                    .cornerRadius(10)
            }.padding(.horizontal, 5)
            Divider()
                .padding(.horizontal)
                .padding(.top, 5)
            let sortedFines = self.widgetProperties.sortedFinesGroups
            let unpayedFines = sortedFines.sortedList(of: .unpayed)
            let payedFines = sortedFines.sortedList(of: .unpayed)
            if !unpayedFines.isEmpty {
                self.fineList(title: String(localized: "widget-view|unpayed-fines", comment: "Fine list title of unpayed fines."), fines: unpayedFines)
            } else if !payedFines.isEmpty {
                self.fineList(title: String(localized: "widget-view|payed-fines", comment: "Fine list title of payed fines."), fines: payedFines)
            } else {
                Spacer()
                Text("widget-view|no-fines", comment: "In fine list, no fines.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .unredacted()
            }
            Spacer()
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
                ForEach(1..<5) { index in
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
        }
    }
    
    @ViewBuilder private func fineRow(_ fine: Fine) -> some View {
        HStack {
            Text(fine.reasonMessage)
                .lineLimit(1)
            Spacer()
            Text(fine.amount.formatted)
                .lineLimit(1)
                .foregroundColor(fine.payedState == .payed ? .green : .red)
        }.padding(.horizontal, 5)
    }
}
