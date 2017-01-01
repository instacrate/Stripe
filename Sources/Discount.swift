//
//  Discount.swift
//  Stripe
//
//  Created by Hakon Hanesand on 12/2/16.
//
//

import Foundation
import Node

public final class Discount: NodeConvertible {
    
    static let type = "discount"
    
    let coupon: Cupon
    let customer: String
    let end: Date
    let start: Date
    let subscription: String
    
    public init(node: Node, in context: Context = EmptyNode) throws {
        
        guard try node.extract("object") == Discount.type else {
            throw NodeError.unableToConvert(node: node, expected: Discount.type)
        }
        
        coupon = try node.extract("cupon")
        customer = try node.extract("customer")
        end = try node.extract("end")
        start = try node.extract("start")
        subscription = try node.extract("subscription")
    }
    
    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "cupon" : coupon.makeNode(),
            "customer" : .string(customer),
            "end" : .number(.double(end.timeIntervalSince1970)),
            "start" : .number(.double(start.timeIntervalSince1970)),
            "subscription" : .string(subscription)
        ] as [String : Node])
    }
}
