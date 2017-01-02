//
//  Charge.swift
//  Stripe
//
//  Created by Hakon Hanesand on 1/1/17.
//
//

import Foundation
import Node

public enum Action: String, NodeConvertible {
    case allow
    case block
    case manual_review
}

public final class Rule: NodeConvertible {

    public let action: Action
    public let predicate: String

    public required init(node: Node, in context: Context = EmptyNode) throws {

        action = try node.extract("action")
        predicate = try node.extract("predicate")
    }

    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node : [
            "action" : action,
            "predicate" : predicate
        ])
    }
}

public enum NetworkStatus: String, NodeConvertible {

    case approved_by_network
    case declined_by_network
    case not_sent_to_network
    case reversed_after_approval
}

public enum Type: String, NodeConvertible {

    case authorized
    case issuer_declined
    case blocked
    case invalid
}

public enum Risk: String, NodeConvertible {

    case normal
    case elevated
    case highest
}

public final class Outcome: NodeConvertible {

    public let network_status: NetworkStatus
    public let reason: String
    public let risk_level: String
    public let seller_message: String
    public let type: Type

    public required init(node: Node, in context: Context = EmptyNode) throws {

        network_status = try node.extract("network_status")
        reason = try node.extract("reason")
        risk_level = try node.extract("risk_level")
        seller_message = try node.extract("seller_message")
        type = try node.extract("type")
    }

    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node : [
            "network_status" : network_status,
            "reason" : reason,
            "risk_level" : risk_level,
            "seller_message" : seller_message,
            "type" : type
        ])
    }
}

public enum ErrorType: String, NodeConvertible {

    case api_connection_error
    case api_error
    case authentication_error
    case card_error
    case invalid_request_error
    case rate_limit_error
}

public final class Shipping: NodeConvertible {

    public let address: Address
    public let name: String
    public let tracking_number: String
    public let phone: String

    public required init(node: Node, in context: Context = EmptyNode) throws {

        address = try node.extract("address")
        name = try node.extract("name")
        tracking_number = try node.extract("tracking_number")
        phone = try node.extract("phone")
    }

    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node : [
            "address" : address,
            "name" : name,
            "tracking_number" : tracking_number,
            "phone" : phone
        ])
    }
}

public enum Status: String, NodeConvertible {

    case succeeded
    case pending
    case failed
}

public final class Charge: NodeConvertible {

    static let type = "charge"

    public let id: String
    public let amount: Int
    public let amount_refunded: Int
    public let application: String?
    public let application_fee: String?
    public let balance_transaction: String
    public let captured: Bool
    public let created: Date
    public let currency: Currency
    public let customer: String
    public let description: String?
    public let destination: String?
    public let dispute: Dispute?
    public let failure_code: ErrorType?
    public let failure_message: String?
    public let fraud_details: Node
    public let invoice: String
    public let livemode: Bool
    public let order: String?
    public let outcome: Outcome
    public let paid: Bool
    public let receipt_email: String?
    public let receipt_number: String?
    public let refunded: Bool
    public let refunds: Node
    public let review: String?
    public let shipping: Shipping?
    public let source: Card
    public let source_transfer: String?
    public let statement_descriptor: String?
    public let status: Status?
    public let transfer: String

    public required init(node: Node, in context: Context = EmptyNode) throws {

        guard try node.extract("object") == Charge.type else {
            throw NodeError.unableToConvert(node: node, expected: Token.type)
        }

        id = try node.extract("id")
        amount = try node.extract("amount")
        amount_refunded = try node.extract("amount_refunded")
        application = try node.extract("application")
        application_fee = try node.extract("application_fee")
        balance_transaction = try node.extract("balance_transaction")
        captured = try node.extract("captured")
        created = try node.extract("created")
        currency = try node.extract("currency")
        customer = try node.extract("customer")
        description = try node.extract("description")
        destination = try node.extract("destination")
        dispute = try node.extract("dispute")
        failure_code = try node.extract("failure_code")
        failure_message = try node.extract("failure_message")
        fraud_details = try node.extract("fraud_details")
        invoice = try node.extract("invoice")
        livemode = try node.extract("livemode")
        order = try node.extract("order")
        outcome = try node.extract("outcome")
        paid = try node.extract("paid")
        receipt_email = try node.extract("receipt_email")
        receipt_number = try node.extract("receipt_number")
        refunded = try node.extract("refunded")
        refunds = try node.extract("refunds")
        review = try node.extract("review")
        shipping = try node.extract("shipping")
        source = try node.extract("source")
        source_transfer = try node.extract("source_transfer")
        statement_descriptor = try node.extract("statement_descriptor")
        status = try node.extract("status")
        transfer = try node.extract("transfer")
    }

    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node : [
            "id" : id,
            "amount" : amount,
            "amount_refunded" : amount_refunded,
            "application" : application,
            "application_fee" : application_fee,
            "balance_transaction" : balance_transaction,
            "captured" : captured,
            "created" : created,
            "currency" : currency,
            "customer" : customer,
            "description" : description,
            "destination" : destination,
            "dispute" : dispute,
            "failure_code" : failure_code,
            "failure_message" : failure_message,
            "fraud_details" : fraud_details,
            "invoice" : invoice,
            "livemode" : livemode,
            "order" : order,
            "outcome" : outcome,
            "paid" : paid,
            "receipt_email" : receipt_email,
            "receipt_number" : receipt_number,
            "refunded" : refunded,
            "refunds" : refunds,
            "review" : review,
            "shipping" : shipping,
            "source" : source,
            "source_transfer" : source_transfer,
            "statement_descriptor" : statement_descriptor,
            "status" : status
        ])
    }
}