//
//  IReasonTemplate.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

protocol IReasonTemplate {
    associatedtype ID: RawRepresentable where ID.RawValue == UUID
    associatedtype Amount: IAmount
    associatedtype Importance: IImportance
    
    var id: ID { get }
    var reasonMessage: String { get }
    var amount: Amount { get }
    var importance: Importance { get }
}

extension IReasonTemplate {
    var concrete: ReasonTemplate {
        return ReasonTemplate(self)
    }
}
