//
//  Widget.swift
//  Widget
//
//  Created by Steven on 02.05.23.
//

import WidgetKit
import SwiftUI

@main
struct Widget: SwiftUI.Widget {
    
    private let kind: String = "StrafenWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetView(entry: entry)
        }.configurationDisplayName(String(localized: "widget-display-name", comment: "Displayed name of the widget in widget selector."))
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
