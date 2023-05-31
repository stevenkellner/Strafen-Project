//
//  SmallWidgetView.swift
//  StrafenProject
//
//  Created by Steven on 04.05.23.
//

import SwiftUI

struct SmallWidgetView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let widgetProperties: WidgetProperties
    
    init(_ widgetProperties: WidgetProperties) {
        self.widgetProperties = widgetProperties
    }
    
    var body: some View {
        VStack {
            Spacer(minLength: 7.5)
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
            Spacer(minLength: 0)
            VStack(spacing: 7.5) {
                HStack {
                    Text("widget-view|open-fines-amount", comment: "Text before the total open fines amount.")
                        .lineLimit(1)
                        .unredacted()
                    Spacer(minLength: 5)
                    Text(self.widgetProperties.fines.unpayedAmount.formatted(.short))
                        .foregroundColor(.red)
                        .lineLimit(1)
                }.padding(.horizontal, 5)
                    .padding(.top, 7.5)
                Divider()
                    .padding(.leading)
                HStack {
                    Text("widget-view|total-amount", comment: "Text before the total amount.")
                        .lineLimit(1)
                        .unredacted()
                    Spacer(minLength: 5)
                    Text(self.widgetProperties.fines.totalAmount.formatted(.short))
                        .foregroundColor(.green)
                        .lineLimit(1)
                }.padding(.horizontal, 5)
                    .padding(.bottom, 7.5)
            }.background(self.colorScheme == .light ? Color.white : Color(uiColor: .systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 5)
                .padding(.bottom, 7.5)
        }.background(self.colorScheme == .light ? Color(uiColor: .systemGray6) : Color.black)
    }
}
