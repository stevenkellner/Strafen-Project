//
//  WidgetView.swift
//  StrafenProject
//
//  Created by Steven on 02.05.23.
//

import SwiftUI

struct WidgetView: View {
    
    @Environment(\.widgetFamily) private var widgetFamily
    
    var entry: WidgetEntry
    
    var body: some View {
        switch entry.widgetProperties {
        case .success(let widgetProperties):
            Group {
                if self.widgetFamily == .systemLarge {
                    LargeWidgetView(widgetProperties)
                } else if self.widgetFamily == .systemMedium {
                    MediumWidgetView(widgetProperties)
                } else if self.widgetFamily == .systemSmall {
                    SmallWidgetView(widgetProperties)
                }
            }.redacted(reason: entry.style == .placeholder ? .placeholder : [])
        case .failure(let error):
            switch error {
            case .unknown:
                Text("widget-view|unknown-error", comment: "Title if an unknown error is occurred.")
                    .font(self.widgetFamily == .systemSmall ? .title3 : .title2)
                    .multilineTextAlignment(.center)
                    .padding(.all)
                if self.widgetFamily == .systemMedium || self.widgetFamily == .systemLarge {
                    Text("widget-view|unknown-error-message", comment: "Message if an unknown error is occurred.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding([.horizontal, .bottom])
                }
            case .nobodySignedIn:
                Text("widget-view|nobody-signed-in", comment: "Title if nobody is signed in.")
                    .font(self.widgetFamily == .systemSmall ? .title3 : .title2)
                    .multilineTextAlignment(.center)
                    .padding(.all)
                if self.widgetFamily == .systemMedium || self.widgetFamily == .systemLarge {
                    Text("widget-view|nobody-signed-in-message", comment: "Message if nobody is signed in.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding([.horizontal, .bottom])
                }
            }
        }
    }
}
