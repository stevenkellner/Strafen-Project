//
//  WidgetEntry.swift
//  StrafenProject
//
//  Created by Steven on 02.05.23.
//

import WidgetKit

struct WidgetEntry: TimelineEntry {
    enum Style {
        case `default`
        case placeholder
    }
    
    enum Error: Swift.Error {
        case unknown
        case nobodySignedIn
    }
    
    let date: Date
    let style: Style
    let widgetProperties: Result<WidgetProperties, Error>
}
