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

extension Date {

    public init(ISO8601String: String) throws {
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        guard let date = dateFormatter.date(from: ISO8601String) else {
            throw Abort.custom(status: .internalServerError, message: "Error parsing date string : \(ISO8601String)")
        }

        self = date
    }

    public var ISO8601String: String {
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        return dateFormatter.string(from: self)
    }
}

extension Date: NodeConvertible {
    
    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return .string(self.ISO8601String)
    }
    
    public init(node: Node, in context: Context) throws {

        if case let .number(numberNode) = node {
            self = Date(timeIntervalSince1970: numberNode.double)
        } else if case let .string(value) = node {
            self = try Date(ISO8601String: value)
        } else {
            throw NodeError.unableToConvert(node: node, expected: "UNIX timestamp or ISO string.")
        }
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

public final class Customer: NodeConvertible {
    
    static let type = "customer"
    
    public let id: String
    public let account_balance: Int
    public let created: Date
    public let currency: Currency?
    public let default_source: String
    public let delinquent: Bool
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
        currency = try? node.extract("currency")
        default_source = try node.extract("default_source")
        delinquent = try node.extract("delinquent")
        description = try? node.extract("description")
        discount = try node.extract("discount")
        email = try? node.extract("email")
        livemode = try node.extract("livemode")
        sources = try node.extractList("sources")
        subscriptions = try node.extractList("subscriptions")
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
            "subscriptions" : .array(subscriptions.map { try $0.makeNode() })
            ] as [String : Node]).add(objects: ["discount" : discount,
                                                "currency" : currency,
                                                "description" : description,
                                                "email" : email])
    }
}
