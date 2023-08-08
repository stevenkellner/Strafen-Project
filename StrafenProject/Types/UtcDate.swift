//
//  UtcDate.swift
//  StrafenProject
//
//  Created by Steven on 05.08.23.
//

import Foundation

struct UtcDate {
    let year: Int
    let month: Int
    let day: Int
    let hour: Int
    let minute: Int
    
    init(year: Int, month: Int, day: Int, hour: Int, minute: Int) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
    }
    
    init(_ date: Date) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        self.init(
            year: dateComponents.year ?? 0,
            month: dateComponents.month ?? 0,
            day: dateComponents.day ?? 0,
            hour: dateComponents.hour ?? 0,
            minute: dateComponents.minute ?? 0
        )
    }
    
    init() {
        self.init(Date())
    }
    
    var date: Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        return calendar.date(from: DateComponents(year: self.year, month: self.month, day: self.day, hour: self.hour, minute: self.minute)) ?? Date()
    }
    
    func formatted(date dateFormat: Date.FormatStyle.DateStyle, time timeFormat: Date.FormatStyle.TimeStyle) -> String {
        return self.date.formatted(date: dateFormat, time: timeFormat)
    }
    
    func setted(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil) -> UtcDate {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let date = calendar.date(from: DateComponents(year: year ?? self.year, month: month ?? self.month, day: day ?? self.day, hour: hour ?? self.hour, minute: minute ?? self.minute)) ?? Date()
        return UtcDate(date)
    }
    
    func advanced(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil) -> UtcDate {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let date = calendar.date(from: DateComponents(year: self.year + (year ?? 0), month: self.month + (month ?? 0), day: self.day + (day ?? 0), hour: self.hour + (hour ?? 0), minute: self.minute + (minute ?? 0))) ?? Date()
        return UtcDate(date)
    }
}

extension UtcDate: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        let regex = #/^(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})-(?<hour>\d{2})-(?<minute>\d{2})$/#
        guard let match = try regex.wholeMatch(in: value) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Couldn't get a regex match for the value."))
        }
        guard let year = Int(match.output.year), year >= 0,
              let month = Int(match.output.month), month >= 0,
              let day = Int(match.output.day), day >= 0,
              let hour = Int(match.output.hour), hour >= 0,
              let minute = Int(match.output.minute), minute >= 0 else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid date components."))
        }
        self.init(year: year, month: month, day: day, hour: hour, minute: minute)
    }
    
    var encoded: String {
        let year = self.year <= 9 ? "000\(self.year)" : self.year <= 99 ? "00\(self.year)" : self.year <= 999 ? "0\(self.year)" : String(describing: self.year)
        let month = self.month <= 9 ? "0\(self.month)" : String(describing: self.month)
        let day = self.day <= 9 ? "0\(self.day)" : String(describing: self.day)
        let hour = self.hour <= 9 ? "0\(self.hour)" : String(describing: self.hour)
        let minute = self.minute <= 9 ? "0\(self.minute)" : String(describing: self.minute)
        return "\(year)-\(month)-\(day)-\(hour)-\(minute)"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.encoded)
    }
}

extension UtcDate: Sendable {}

extension UtcDate: Hashable {}

extension UtcDate: Equatable {}

extension UtcDate: Comparable {
    static func < (lhs: UtcDate, rhs: UtcDate) -> Bool {
        if (lhs.year < rhs.year) {
            return true
        } else if (lhs.year > rhs.year) {
            return false
        }
        if (lhs.month < rhs.month) {
            return true
        } else if (lhs.month > rhs.month) {
            return false
        }
        if (lhs.day < rhs.day) {
            return true
        } else if (lhs.day > rhs.day) {
            return false
        }
        if (lhs.hour < rhs.hour) {
            return true
        } else if (lhs.hour > rhs.hour) {
            return false
        }
        if (lhs.minute < rhs.minute) {
            return true
        } else if (lhs.minute > rhs.minute) {
            return false
        }
        return false
    }
}

#if !NOTIFICATION_SERVICE_EXTENSION
extension UtcDate: FirebaseFunctionParameterType {
    var parameter: String {
        return self.encoded
    }
}

extension UtcDate: RandomPlaceholder {
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> UtcDate {
        return UtcDate(Date(timeIntervalSinceNow: TimeInterval.random(in: -31536000..<0, using: &generator)))
    }
}
#endif
