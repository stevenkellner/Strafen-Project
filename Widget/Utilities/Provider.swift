//
//  Provider.swift
//  StrafenProject
//
//  Created by Steven on 02.05.23.
//

import WidgetKit

struct Provider: TimelineProvider {
    
    static private let timeIntervalToUpdate: TimeInterval = 600 // 10min
    
    static private let timeIntervalToUpdateAfterNobodySignedIn: TimeInterval = 120 // 2min
    
    static private let timeIntervalToUpdateAfterError: TimeInterval = 30 // 30sec
    
    func placeholder(in context: Context) -> WidgetEntry {
        let widgetProperties = WidgetProperties.randomPlaceholder
        return WidgetEntry(date: Date(), style: .placeholder, widgetProperties: .success(widgetProperties))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        let widgetProperties = WidgetProperties.randomPlaceholder
        let widgetEntry = WidgetEntry(date: Date(), style: .default, widgetProperties: .success(widgetProperties))
        completion(widgetEntry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        Task {
            await MainActor.run {
                _ = FirebaseConfigurator.shared.configure()
            }
            let settingsManager = SettingsManager()
            let widgetEntry: WidgetEntry
            if let signedInPerson = settingsManager.signedInPerson {
                do {
                    let widgetProperties = try await WidgetProperties.fetch(with: signedInPerson, sorting: settingsManager.sorting)
                    widgetEntry = WidgetEntry(date: Date(timeIntervalSinceNow: Provider.timeIntervalToUpdate), style: .default, widgetProperties: .success(widgetProperties))
                } catch {
                    widgetEntry = WidgetEntry(date: Date(timeIntervalSinceNow: Provider.timeIntervalToUpdateAfterError), style: .default, widgetProperties: .failure(.unknown))
                }
            } else {
                widgetEntry = WidgetEntry(date: Date(timeIntervalSinceNow: Provider.timeIntervalToUpdateAfterNobodySignedIn), style: .default, widgetProperties: .failure(.nobodySignedIn))
            }
            let widgetEntryNow = WidgetEntry(date: Date(), style: widgetEntry.style, widgetProperties: widgetEntry.widgetProperties)
            return completion(Timeline(entries: [widgetEntryNow, widgetEntry], policy: .atEnd))
        }
    }
}
