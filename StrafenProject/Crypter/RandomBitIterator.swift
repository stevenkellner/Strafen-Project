//
//  RandomBitIterator.swift
//  StrafenProject
//
//  Created by Steven on 06.04.23.
//

import Foundation

struct RandomBitIterator: IteratorProtocol {
    
    private var pseudoRandom: PseudoRandom
    
    private var dataToBitIterator: DataToBitIterator
    
    init(seed: [UInt8]) {
        self.pseudoRandom = PseudoRandom(seed: seed)
        self.dataToBitIterator = DataToBitIterator([self.pseudoRandom.randomByte()])
    }
    
    mutating func next() -> Bit? {
        guard let bit = self.dataToBitIterator.next() else {
            self.dataToBitIterator = DataToBitIterator([self.pseudoRandom.randomByte()])
            return self.next()
        }
        return bit
    }
}
