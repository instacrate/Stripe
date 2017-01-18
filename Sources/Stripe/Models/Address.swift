//
//  Address.swift
//  Stripe
//
//  Created by Hakon Hanesand on 1/18/17.
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
