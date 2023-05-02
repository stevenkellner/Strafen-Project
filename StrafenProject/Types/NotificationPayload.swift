//
//  NotificationPayload.swift
//  StrafenProject
//
//  Created by Steven on 01.05.23.
//

import Foundation

struct NotificationPayload {
    public private(set) var title: String
    public private(set) var body: String
}

extension NotificationPayload: Equatable {}

extension NotificationPayload: Codable {}

extension NotificationPayload: Sendable {}

extension NotificationPayload: Hashable {}

extension NotificationPayload: FirebaseFunctionParameterType {
    @FirebaseFunctionParametersBuilder var parameter: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.title, for: "title")
        FirebaseFunctionParameter(self.body, for: "body")
    }
}
