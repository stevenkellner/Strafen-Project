//
//  IFine.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

protocol IFine {
    associatedtype ID: RawRepresentable where ID.RawValue == UUID
    associatedtype PersonID: RawRepresentable where PersonID.RawValue == UUID
    associatedtype PayedState: IPayedState
    associatedtype FineReason: IFineReason

    var id: ID { get }
    var personId: PersonID { get }
    var payedState: PayedState { get }
    var number: UInt { get }
    var date: Date { get }
    var fineReason: FineReason { get }
}

extension IFine {
    var concrete: Fine {
        return Fine(self)
    }
}
