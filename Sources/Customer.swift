//
//  Customer.swift
//  Stripe
//
//  Created by Hakon Hanesand on 12/2/16.
//
//

import Foundation
import Node

extension Date: NodeConvertible {
    
    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return .number(.double(self.timeIntervalSince1970))
    }
    
    public init(node: Node, in context: Context) throws {
        guard let double = node.double else {
            throw NodeError.unableToConvert(node: node, expected: "UNIX timestamp")
        }
        
        self = Date(timeIntervalSince1970: double)
    }
}

extension Node {
    
    func extractList<T: NodeInitializable>(_ path: PathIndex...) throws -> [T] {
        guard let node = self[path] else {
            throw NodeError.unableToConvert(node: self, expected: "path at \(path)")
        }
        
        guard node["object"]?.string == "list" else {
            throw NodeError.unableToConvert(node: node, expected: "object key with list value")
        }
        
        guard let data = node["data"] else {
            throw NodeError.unableToConvert(node: node, expected: "data key with list values")
        }
        
        return try [T](node: data)
    }
}

final class Customer: NodeConvertible {
    
    static let type = "customer"
    
    let id: String
    let account_balance: Int
    let created: Date
    let currency: String
    let default_source: String
    let delinquent: Bool
    let description: String
    let discount: Discount?
    let email: String
    let livemode: Bool
    let sources: [Source]
    let subscriptions: [Subscription]
    
    init(node: Node, in context: Context = EmptyNode) throws {
        
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
    }
    
    func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "id" : .string(id),
            "account_balance" : .number(.int(account_balance)),
            "created" : .number(.double(created.timeIntervalSince1970)),
            "currency" : .string(currency),
            "default_source" : .string(default_source),
            "delinquent" : .bool(delinquent),
            "description" : .string(description),
            "email" : .string(email),
            "livemode" : .bool(livemode),
            "sources" :  .array(sources.map { try $0.makeNode() }),
            "subscriptions" : .array(subscriptions.map { try $0.makeNode() })
        ] as [String : Node]).add(name: "discount", node: discount?.makeNode())
    }
}
