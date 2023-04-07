//
//  FirebaseFunctionParameterType.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

protocol FirebaseFunctionParameterType {
    associatedtype Parameter: FirebaseFunctionParameterType
    
    var parameter: Parameter { get }
    var internalParameter: FirebaseFunctionInternalParameterType { get }
}

extension FirebaseFunctionParameterType {
    var internalParameter: FirebaseFunctionInternalParameterType {
        return self.parameter.internalParameter
    }
}

extension Bool: FirebaseFunctionParameterType {
    var internalParameter: FirebaseFunctionInternalParameterType {
        return .bool(self)
    }
    
    var parameter: Bool {
        return self
    }
}

extension Int: FirebaseFunctionParameterType {
    var internalParameter: FirebaseFunctionInternalParameterType {
        return .int(self)
    }
    
    var parameter: Int {
        return self
    }
}

extension UInt: FirebaseFunctionParameterType {
    var internalParameter: FirebaseFunctionInternalParameterType {
        return .uint(self)
    }
    
    var parameter: UInt {
        return self
    }
}

extension Double: FirebaseFunctionParameterType {
    var internalParameter: FirebaseFunctionInternalParameterType {
        return .double(self)
    }
    
    var parameter: Double {
        return self
    }
}

extension Float: FirebaseFunctionParameterType {
    var internalParameter: FirebaseFunctionInternalParameterType {
        return .float(self)
    }
    
    var parameter: Float {
        return self
    }
}

extension String: FirebaseFunctionParameterType {
    var internalParameter: FirebaseFunctionInternalParameterType {
        return .string(self)
    }
    
    var parameter: String {
        return self
    }
}

extension Optional: FirebaseFunctionParameterType where Wrapped: FirebaseFunctionParameterType {
    var internalParameter: FirebaseFunctionInternalParameterType {
        return .optional(self.map(\.internalParameter))
    }
    
    var parameter: Wrapped? {
        return self
    }
}

extension Array: FirebaseFunctionParameterType where Element == any FirebaseFunctionParameterType {
    var internalParameter: FirebaseFunctionInternalParameterType {
        return .array(self.map(\.internalParameter))
    }
    
    var parameter: [any FirebaseFunctionParameterType] {
        return self
    }
}

extension Dictionary: FirebaseFunctionParameterType where Key == String, Value == any FirebaseFunctionParameterType {
    var internalParameter: FirebaseFunctionInternalParameterType {
        return .dictionary(self.mapValues(\.internalParameter))
    }
    
    var parameter: [String: any FirebaseFunctionParameterType] {
        return self
    }
}

extension UUID: FirebaseFunctionParameterType {
    var parameter: String {
        return self.uuidString
    }
}

extension Date: FirebaseFunctionParameterType {
    var parameter: String {
        self.ISO8601Format(.iso8601)
    }
}

extension Tagged: FirebaseFunctionParameterType where RawValue: FirebaseFunctionParameterType {
    var parameter: RawValue {
        return self.rawValue
    }
}
