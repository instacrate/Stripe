//
//  County.swift
//  Stripe
//
//  Created by Hakon Hanesand on 12/2/16.
//
//

import Foundation
import Node

final class IdentityVerification: NodeConvertible {
    
    let minimum: [String]
    let additional: [String]
    
    init(node: Node, in context: Context = EmptyNode) throws {
        minimum = try node.extract("minimum")
        additional = try node.extract("additional")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "minimum" : .array(minimum.map { Node.string($0) } ),
            "additional" : .array(minimum.map { Node.string($0) } )
        ] as [String : Node])
    }
}

final class County: NodeConvertible {
    
    static let type = "country_spec"
    
    let id: String
    let default_currency: String
    let string: String
    let supported_bank_account_currencies: [String]
    let supported_payment_currencies: [String]
    let supported_payment_methods: [String]
    let verification_fields: IdentityVerification
    
    init(node: Node, in context: Context = EmptyNode) throws {
        
        guard try node.extract("object") == County.type else {
            throw NodeError.unableToConvert(node: node, expected: County.type)
        }
        
        id = try node.extract("id")
        default_currency = try node.extract("default_currency")
        string = try node.extract("string")
        supported_bank_account_currencies = try node.extract("supported_bank_account_currencies")
        supported_payment_currencies = try node.extract("supported_payment_currencies")
        supported_payment_methods = try node.extract("supported_payment_methods")
        verification_fields = try node.extract("verification_fields")
    }
    
    func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "id" : .string(id),
            "default_currency" : .string(default_currency),
            "string" : .string(string),
            "supported_bank_account_currencies" : .array(supported_bank_account_currencies.map { Node.string($0) } ),
            "supported_payment_currencies" : .array(supported_payment_currencies.map { Node.string($0) } ),
            "supported_payment_methods" : .array(supported_payment_methods.map { Node.string($0) } ),
            "verification_fields" : verification_fields.makeNode()
        ])
    }
}
