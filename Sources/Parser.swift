//
//  Parser.swift
//  Stripe
//
//  Created by Hakon Hanesand on 12/3/16.
//
//

import Foundation
import JSON

final class StripeObjectParser {
    
    static let typeLookup = ["card" : Card.self, "customer" : Customer.self, "subscription" : Subscription.self, "plan" : Plan.self, "country_spec" : County.self, "discount" : Discount.self, "coupn" : Cupon.self, "source" : Source.self] as [String : NodeConvertible.Type]
    
    func parse(json: JSON) throws -> NodeConvertible {
        let node = json.node
        
        guard let string = node["object"]?.string else {
            throw NodeError.unableToConvert(node: node, expected: "string at object")
        }
        
        guard let type = StripeObjectParser.typeLookup[string] else {
            throw NodeError.unableToConvert(node: node, expected: "invalid object type")
        }
        
        return try type.init(node: node)
    }
}
