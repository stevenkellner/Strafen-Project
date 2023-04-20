//
//  Text+describing.swift
//  StrafenProject
//
//  Created by Steven on 19.04.23.
//

import SwiftUI

extension Text {
    init<Subject>(describing instance: Subject) {
        self.init(String(describing: instance))
    }
    
    init<Subject>(describing instance: Subject) where Subject: CustomStringConvertible {
        self.init(String(describing: instance))
    }
    
    init<Subject>(describing instance: Subject) where Subject: TextOutputStreamable {
        self.init(String(describing: instance))
    }
    
    init<Subject>(describing instance: Subject) where Subject: CustomStringConvertible, Subject: TextOutputStreamable {
        self.init(String(describing: instance))
    }
    
    init<Subject>(reflecting subject: Subject) {
        self.init(String(reflecting: subject))
    }
}
