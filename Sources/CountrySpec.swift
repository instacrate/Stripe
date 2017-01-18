//
//  CountrySpec.swift
//  Stripe
//
//  Created by Hakon Hanesand on 1/18/17.
//
//

import Foundation
import Node

public final class Country: NodeConvertible {
    
    static let type = "country_spec"
    
    public let id: String
    public let default_currency: String
    public let supported_bank_account_currencies: Node
    public let supported_payment_currencies: [Currency]
    public let supported_payment_methods: [String]
    public let verification_fields: CountryVerificationFields
    
    public init(node: Node, in context: Context = EmptyNode) throws {
        
        guard try node.extract("object") == Country.type else {
            throw NodeError.unableToConvert(node: node, expected: Country.type)
        }
        
        id = try node.extract("id")
        default_currency = try node.extract("default_currency")
        supported_bank_account_currencies = try node.extract("supported_bank_account_currencies")
        supported_payment_currencies = try node.extract("supported_payment_currencies")
        supported_payment_methods = try node.extract("supported_payment_methods")
        verification_fields = try node.extract("verification_fields")
    }
    
    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "id" : .string(id),
            "default_currency" : .string(default_currency),
            "supported_bank_account_currencies" : supported_bank_account_currencies,
            "supported_payment_currencies" : .array(supported_payment_currencies.map { Node.string($0.rawValue) } ),
            "supported_payment_methods" : .array(supported_payment_methods.map { Node.string($0) } ),
            "verification_fields" : verification_fields.makeNode()
            ] as [String : Node])
    }
}
