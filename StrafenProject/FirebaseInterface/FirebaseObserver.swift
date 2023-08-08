//
//  FirebaseObserver.swift
//  StrafenProject
//
//  Created by Steven on 05.08.23.
//

import FirebaseDatabase
import OSLog

protocol FirebaseGetSingleFunction: FirebaseFunction {
    
    associatedtype Element: Identifiable where Element.ID: RawRepresentable, Element.ID.RawValue == UUID
    
    associatedtype ReturnType = Element?
    
    init(clubId: ClubProperties.ID, id: Element.ID)
}

protocol ChangeObservable: Identifiable {
    
    associatedtype GetSingleFunction: FirebaseGetSingleFunction where GetSingleFunction.Element == Self
    
    static var changesKey: String { get }
}

struct FirebaseObserver {
    struct EventType: OptionSet {
        let rawValue: UInt
        
        init(rawValue: UInt) {
            self.rawValue = rawValue
        }
                
        static let childAdded = EventType(rawValue: 1 << 0)
        static let childRemoved = EventType(rawValue: 1 << 1)
        static let childChanged = EventType(rawValue: 1 << 2)
        static let childMoved = EventType(rawValue: 1 << 3)
        static let value = EventType(rawValue: 1 << 4)
        
        var eventTypes: [DataEventType] {
            var eventTypes = [DataEventType]()
            if self.contains(.childAdded) {
                eventTypes.append(.childAdded)
            }
            if self.contains(.childRemoved) {
                eventTypes.append(.childRemoved)
            }
            if self.contains(.childChanged) {
                eventTypes.append(.childChanged)
            }
            if self.contains(.childMoved) {
                eventTypes.append(.childMoved)
            }
            if self.contains(.value) {
                eventTypes.append(.value)
            }
            return eventTypes
        }
    }
    
    static let shared = FirebaseObserver()
    
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "StrafenProject", category: String(describing: FirebaseObserver.self))
    
    private init() {}
    
    func observe(events: EventType, path: String, handler: @escaping (DataSnapshot) -> Void) {
        let reference = Database.database(url: PrivateKeys.current.databaseUrl).reference(withPath: path)
        for eventType in events.eventTypes {
            reference.observe(eventType) { snapshot in
                handler(snapshot)
            }
        }
    }
    
    func observeChanges<Element>(clubId: ClubProperties.ID, type: Element.Type, handler: @escaping (Deletable<Element>) -> Void) where Element: ChangeObservable {
        FirebaseObserver.logger.log("Observe changes for \(Element.self)")
        self.observe(events: [.childAdded, .childChanged], path: "clubs/\(clubId.uuidString)/changes/\(Element.changesKey)") { snapshot in
            guard let rawId = UUID(uuidString: snapshot.key),
                  let id = Element.ID(rawValue: rawId) else {
                return
            }
            let getSingleFunction = Element.GetSingleFunction(clubId: clubId, id: id)
            Task {
                do {
                    if let element = try await FirebaseFunctionCaller.shared.call(getSingleFunction) as! Element? {
                        handler(.value(element))
                    } else {
                        handler(.deleted(id: id))
                    }
                } catch {}
            }
        }
    }
}
