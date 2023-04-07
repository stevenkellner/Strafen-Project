//
//  IFineReason.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

protocol IFineReason {
    associatedtype Amount: IAmount
    associatedtype Importance: IImportance
    
    var reasonMessage: String { get }
    var amount: Amount { get }
    var importance: Importance { get }
}

extension IFineReason {
    var concrete: FineReason {
        return FineReason(self)
    }
}
