//
//  DataToBitIterator.swift
//  StrafenProject
//
//  Created by Steven on 06.04.23.
//

import Foundation

struct DataToBitIterator: IteratorProtocol {
    
    private var dataIterator: Data.Iterator
    
    private var currentBitsIterator: IndexingIterator<[Bit]>?
    
    init(_ data: Data) {
        self.dataIterator = data.makeIterator()
        self.currentBitsIterator = self.dataIterator.next()?.bits.makeIterator()
    }
    
    init(_ bytes: [UInt8]) {
        self.init(Data(bytes))
    }
    
    mutating func next() -> Bit? {
        guard self.currentBitsIterator != nil else {
            return nil
        }
        guard let bit = self.currentBitsIterator!.next() else {
            self.currentBitsIterator = self.dataIterator.next()?.bits.makeIterator()
            return self.next()
        }
        return bit
    }
}

extension IteratorProtocol<Bit> {
    var data: Data {
        var data = Data()
        var iterator = self
        var currentByte: UInt8 = 0
        var index = 0
        while let bit = iterator.next() {
            currentByte += UInt8(bit.value * (1 << (7 - index)))
            index += 1
            if index == 8 {
                data.append(currentByte)
                currentByte = 0
                index = 0
            }
        }
        return data
    }
}
