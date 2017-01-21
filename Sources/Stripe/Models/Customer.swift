//
//  Customer.swift
//  Stripe
//
//  Created by Hakon Hanesand on 12/2/16.
//
//

import Foundation
import Node
import Vapor

public final class Customer: NodeConvertible {
    
    static let type = "customer"
    
    public let id: String
    public let account_balance: Int
    public let created: Date
    public let currency: Currency?
    public let default_source: String
    public let delinquent: Bool
    public let metadata: Node
    public let description: String?
    public let discount: Discount?
    public let email: String?
    public let livemode: Bool
    public let sources: [Card]
    public let subscriptions: [Subscription]
    
    public init(node: Node, in context: Context = EmptyNode) throws {
        
        guard try node.extract("object") == Customer.type else {
            throw NodeError.unableToConvert(node: node, expected: Customer.type)
        }
        
        id = try node.extract("id")
        account_balance = try node.extract("account_balance")
        created = try node.extract("created")
        currency = try node.extract("currency")
        default_source = try node.extract("default_source")
        delinquent = try node.extract("delinquent")
        description = try node.extract("description")
        discount = try node.extract("discount")
        email = try node.extract("email")
        livemode = try node.extract("livemode")
        sources = try node.extractList("sources")
        subscriptions = try node.extractList("subscriptions")
        metadata = node["metadata"] ?? EmptyNode
    }
    
    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "id" : .string(id),
            "account_balance" : .number(.int(account_balance)),
            "created" : .number(.double(created.timeIntervalSince1970)),
            "default_source" : .string(default_source),
            "delinquent" : .bool(delinquent),
            "livemode" : .bool(livemode),
            "sources" :  .array(sources.map { try $0.makeNode() }),
            "subscriptions" : .array(subscriptions.map { try $0.makeNode() }),
            "metadata" : metadata
        ] as [String : Node]).add(objects: [
            "discount" : discount,
            "currency" : currency,
            "description" : description,
            "email" : email
        ])
    }
}
