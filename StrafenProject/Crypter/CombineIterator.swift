//
//  CombineIterator.swift
//  StrafenProject
//
//  Created by Steven on 06.04.23.
//

import Foundation

struct CombineIterator<LhsIterator, RhsIterator, T>: IteratorProtocol where LhsIterator: IteratorProtocol, RhsIterator: IteratorProtocol {
    
    private var lhsIterator: LhsIterator
    
    private var rhsIterator: RhsIterator
    
    private let combineElement: (LhsIterator.Element, RhsIterator.Element) -> T
    
    init(lhs lhsIterator: LhsIterator, rhs rhsIterator: RhsIterator, combine combineElement: @escaping (LhsIterator.Element, RhsIterator.Element) -> T) {
        self.lhsIterator = lhsIterator
        self.rhsIterator = rhsIterator
        self.combineElement = combineElement
    }
    
    mutating func next() -> T? {
        guard let lhsElement = self.lhsIterator.next(),
              let rhsElement = self.rhsIterator.next() else {
            return nil
        }
        return self.combineElement(lhsElement, rhsElement)
    }
}
