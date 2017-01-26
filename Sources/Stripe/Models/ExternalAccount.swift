//
//  ExternalAccount.swift
//  subber-api
//
//  Created by Hakon Hanesand on 1/20/17.
//
//

import Foundation
import Node

public enum ExternalAccountVerificationStatus: String, NodeConvertible {
    
    case new
    case validated
    case verified
    case verification_failed
    case errored
}

public final class ExternalAccount: NodeConvertible {
    
    static let type = "bank_account"
    
    public let id: String
    public let account: String
    public let account_holder_name: String?
    public let account_holder_type: String?
    public let bank_name: String
    public let country: String
    public let currency: Currency
    public let default_for_currency: Bool
    public let fingerprint: String
    public let last4: String
    public let metadata: Node
    public let routing_number: String
    public let status: ExternalAccountVerificationStatus
    
    public init(node: Node, in context: Context = EmptyNode) throws {
        
        guard try node.extract("object") == ExternalAccount.type else {
            throw NodeError.unableToConvert(node: node, expected: ExternalAccount.type)
        }
        
        id = try node.extract("id")
        account = try node.extract("account")
        account_holder_name = try node.extract("account_holder_name")
        account_holder_type = try node.extract("account_holder_type")
        bank_name = try node.extract("bank_name")
        country = try node.extract("country")
        currency = try node.extract("currency")
        default_for_currency = try node.extract("default_for_currency")
        fingerprint = try node.extract("fingerprint")
        last4 = try node.extract("last4")
        metadata = try node.extract("metadata")
        routing_number = try node.extract("routing_number")
        status = try node.extract("status")
    }
    
    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "id" : id,
            "account" : account,
            "account_holder_name" : account_holder_name,
            "account_holder_type" : account_holder_type,
            "bank_name" : bank_name,
            "country" : country,
            "currency" : currency,
            "default_for_currency" : default_for_currency,
            "fingerprint" : fingerprint,
            "last4" : last4,
            "metadata" : metadata,
            "routing_number" : routing_number,
            "status" : status
        ])
    }
    
    static func descriptionsForNeededFields(in country: CountryType) -> [String : String] {
        var descriptions: [String: String] = [:]
        
        switch country {
        case .us:
            descriptions["routing_number"] =  "The ACH routing number."
            fallthrough
        default:
            descriptions["account_number"] = "The account number for the bank account. Must be a checking account."
            descriptions["country"] = "The country the bank account is in."
            descriptions["currency"] = "The currency of the bank account."
        }
        
        return descriptions
    }
}