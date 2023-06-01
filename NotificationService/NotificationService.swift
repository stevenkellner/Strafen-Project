//
//  NotificationService.swift
//  NotificationService
//
//  Created by Steven on 01.05.23.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        guard let requestPersonIdString = request.content.userInfo["personId"] as? String,
              let requestPersonId = Person.ID(uuidString: requestPersonIdString) else {
            return
        }
        let settingsManager = SettingsManager()
        guard let signedInPersonId = settingsManager.signedInPerson?.id else {
            return
        }
        guard requestPersonId == signedInPersonId else {
            return
        }
        contentHandler(request.content)
    }
}
