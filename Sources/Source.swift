//
//  Source.swift
//  Stripe
//
//  Created by Hakon Hanesand on 12/2/16.
//
//

import Foundation
import Node

public final class Address: NodeConvertible {
    
    public let city: String
    public let country: String
    public let line1: String
    public let line2: String
    public let postal_code: String
    public let state: String
    
    public init(node: Node, in context: Context = EmptyNode) throws {
        city = try node.extract("city")
        country = try node.extract("country")
        line1 = try node.extract("line1")
        line2 = try node.extract("line2")
        postal_code = try node.extract("postal_code")
        state = try node.extract("state")
    }
    
    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "city" : .string(city),
            "country" : .string(country),
            "line1" : .string(line1),
            "line2" : .string(line2),
            "postal_code" : .string(postal_code),
            "state" : .string(state)
        ] as [String : Node])
    }
}

public final class Owner: NodeConvertible {
    
    public let address: Address
    public let email: String
    public let name: String
    public let phone: String
    public let verified_address: Address
    public let verified_email: String
    public let verified_name: String
    public let verified_phone: String
    
    public init(node: Node, in context: Context) throws {
        address = try node.extract("address")
        email = try node.extract("email")
        name = try node.extract("name")
        phone = try node.extract("phone")
        verified_address = try node.extract("verified_address")
        verified_email = try node.extract("verified_email")
        verified_name = try node.extract("verified_name")
        verified_phone = try node.extract("verified_phone")
    }
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "address" : address.makeNode(),
            "email" : .string(email),
            "name" : .string(name),
            "phone" : .string(phone),
            "verified_address" : verified_address.makeNode(),
            "verified_email" : .string(verified_email),
            "verified_name" : .string(verified_name),
            "verified_phone" : .string(verified_phone)
        ] as [String : Node])
    }
}

public final class Reciever: NodeConvertible {
    
    public let address: String
    public let amount_charged: String
    public let amount_received: String
    public let amount_returned: String
    public let refund_attributes_method: String?
    public let refund_attributes_status: String?
    
    public init(node: Node, in context: Context) throws {
        address = try node.extract("address")
        amount_charged = try node.extract("amount_charged")
        amount_received = try node.extract("amount_received")
        amount_returned = try node.extract("amount_returned")
        refund_attributes_method = try node.extract("refund_attributes_method")
        refund_attributes_status = try node.extract("refund_attributes_status")
    }
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "address" : .string(address),
            "amount_charged" : .string(amount_charged),
            "amount_received" : .string(amount_received),
            "amount_returned" : .string(amount_returned)
        ] as [String : Node]).add(objects: ["refund_attributes_method" : refund_attributes_method,
                                             "refund_attributes_status" : refund_attributes_status])
    }
}

public enum Usage: String, NodeConvertible {
    case reusable
    case singleUse = "single-use"
}


public enum SourceStatus: String, NodeConvertible {
    case pending
    case chargeable
    case consumed
    case canceled
}

public enum PaymentFlow: String, NodeConvertible {
    case redirect
    case receiver
    case verification
    case none
}

public final class VerificationInformation: NodeConvertible {
    
    public let attempts_remaining: Int
    public let status: SourceStatus
    
    public init(node: Node, in context: Context = EmptyNode) throws {
        attempts_remaining = try node.extract("attempts_remaining")
        status = try node.extract("status")
    }
    
    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "attempts_remaining" : .number(.int(attempts_remaining)),
            "status" : .string(status.rawValue)
        ] as [String : Node])
    }
}

public final class Source: NodeConvertible {
    
    static let type = "source"
    
    public let id: String
    public let amount: Int
    public let client_secret: String
    public let created: Date
    public let currency: Currency
    public let flow: PaymentFlow
    public let livemode: Bool
    public let owner: Owner
    public let receiver: Reciever?
    public let status: SourceStatus
    public let type: String
    public let usage: Usage
    
    public init(node: Node, in context: Context) throws {
        
        guard try node.extract("object") == Source.type else {
            throw NodeError.unableToConvert(node: node, expected: Source.type)
        }
        
        id = try node.extract("id")
        amount = try node.extract("amount")
        client_secret = try node.extract("client_secret")
        created = try node.extract("created")
        currency = try node.extract("currency")
        flow = try node.extract("flow")
        livemode = try node.extract("livemode")
        owner = try node.extract("owner")
        receiver = try node.extract("receiver")
        status = try node.extract("status")
        type = try node.extract("type")
        usage = try node.extract("usage")
    }
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id" : .string(id),
            "amount" : .number(.int(amount)),
            "client_secret" : .string(client_secret),
            "created" : .number(.double(created.timeIntervalSince1970)),
            "currency" : .string(currency.rawValue),
            "flow" : .string(flow.rawValue),
            "livemode" : .bool(livemode),
            "owner" : owner.makeNode(),
            
            "status" : .string(status.rawValue),
            "type" : .string(type),
            "usage" : .string(usage.rawValue)
        ] as [String : Node]).add(name: "receiver", node: receiver?.makeNode())
    }
}
