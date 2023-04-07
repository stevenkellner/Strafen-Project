//
//  IAmount.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

protocol IAmount {
    var value: UInt { get }
    var subUnitValue: UInt { get }
}

extension IAmount {
    var concrete: Amount {
        return Amount(self)
    }
}
