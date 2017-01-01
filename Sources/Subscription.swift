//
//  Subscription.swift
//  Stripe
//
//  Created by Hakon Hanesand on 12/2/16.
//
//

import Foundation
import Node

enum SubscriptionStatus: String, NodeConvertible {
    
    case trialing
    case active
    case pastDue = "past_due"
    case canceled
    case unpaid
}

final class Subscription: NodeConvertible {
    
    static let type = "subscription"
    
    let id: String
    let application_fee_percent: Double?
    let cancel_at_period_end: Bool
    let canceled_at: Date?
    let created: Date
    let current_period_end: Date
    let current_period_start: Date
    let customer: String
    let discount: String?
    let ended_at: Date?
    let livemode: Bool
    let plan: Plan
    let quantity: Int
    let start: Date
    let status: SubscriptionStatus
    let tax_percent: Double?
    let trial_end: Date?
    let trial_start: Date?
    
    init(node: Node, in context: Context = EmptyNode) throws {
        
        guard try node.extract("object") == Subscription.type else {
            throw NodeError.unableToConvert(node: node, expected: Customer.type)
        }
        
        id = try node.extract("id")
        application_fee_percent = try? node.extract("application_fee_percent")
        cancel_at_period_end = try node.extract("cancel_at_period_end")
        canceled_at = try? node.extract("canceled_at")
        created = try node.extract("created")
        current_period_end = try node.extract("current_period_end")
        current_period_start = try node.extract("current_period_start")
        customer = try node.extract("customer")
        discount = try? node.extract("discount")
        ended_at = try? node.extract("ended_at")
        livemode = try node.extract("livemode")
        plan = try node.extract("plan")
        quantity = try node.extract("quantity")
        start = try node.extract("start")
        status = try node.extract("status")
        tax_percent = try? node.extract("tax_percent")
        trial_end = try? node.extract("trial_end")
        trial_start = try? node.extract("trial_start")
    }
    
    func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "id" : .string(id),
            "cancel_at_period_end" : .bool(cancel_at_period_end),
            "created" : .number(.double(created.timeIntervalSince1970)),
            "current_period_end" : .number(.double(current_period_end.timeIntervalSince1970)),
            "current_period_start" : .number(.double(current_period_start.timeIntervalSince1970)),
            "customer" : .string(customer),
            "livemode" : .bool(livemode),
            "plan" : plan.makeNode(),
            "quantity" : .number(.int(quantity)),
            "start" : .number(.double(start.timeIntervalSince1970)),
            "status" : .string(status.rawValue),
        ] as [String : Node]).add(objects: ["canceled_at" : canceled_at,
                                            "ended_at" : ended_at,
                                            "tax_percent" : tax_percent,
                                            "trial_end" : trial_end,
                                            "trial_start" : trial_start,
                                            "application_fee_percent" : application_fee_percent,
                                            "discount" : discount])
    }
}
