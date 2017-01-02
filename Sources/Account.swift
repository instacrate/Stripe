//
//  Account.swift
//  Stripe
//
//  Created by Hakon Hanesand on 1/2/17.
//
//

import Foundation
import Node

final class DeclineChargeRules: NodeConvertible {

    public let avs_failure: Bool
    public let cvc_failure: Bool

}

public enum VerificationStatus: String, NodeConvertible {

    case unverified
    case pending
    case verified
}

public enum VerificationFailureReason: String, NodeConvertible {

    case scan_corrupt
    case scan_not_readable
    case scan_failed_greyscale
    case scan_not_uploaded
    case scan_id_type_not_supported
    case scan_id_country_not_supported
    case scan_name_mismatch
    case scan_failed_other
    case failed_keyed_identity
    case failed_other
}

public class Document: NodeConvertible {

    public let id: String
    public let created: Date
    public let size: Int

    public required init(node: Node, in context: Context = EmptyNode) throws {
        id = try node.extract("id")
        created = try node.extract("created")
        size = try node.extract("size")
    }

    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "id" : id,
            "created" : created,
            "size" : size
            ])
    }
}

public class IdentityVerification: NodeConvertible {

    public let status: VerificationStatus
    public let document: Document
    public let details: String
    public let details_code: VerificationFailureReason

    public required init(node: Node, in context: Context = EmptyNode) throws {
        status = try node.extract("status")
        document = try node.extract("document")
        details = try node.extract("details")
    }

    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "status" : status,
            "document" : document,
            "details" : details
            ])
    }
}


final class LegalEntity: NodeConvertible {

    public let address: String
    public let business_name: String
    public let business_tax_id_provided: String
    public let dob: String
    public let first_name: String
    public let last_name: String
    public let personal_address: String
    public let personal_id_number_provided: String
    public let ssn_last_4_provided: String
    public let type: String
    public let verification: String

    public required init(node: Node, in context: Context = EmptyNode) throws {
        address = try node.extract("address")
        business_name = try node.extract("business_name")
        business_tax_id_provided = try node.extract("business_tax_id_provided")
        dob = try node.extract("dob")
        first_name = try node.extract("first_name")
        last_name = try node.extract("last_name")
        personal_address = try node.extract("personal_address")
        personal_id_number_provided = try node.extract("personal_id_number_provided")
        ssn_last_4_provided = try node.extract("ssn_last_4_provided")
        type = try node.extract("type")
        verification = try node.extract("verification")
    }

    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "address" : address,
            "business_name" : business_name,
            "business_tax_id_provided" : business_tax_id_provided,
            "dob" : dob,
            "first_name" : first_name,
            "last_name" : last_name,
            "personal_address" : personal_address,
            "personal_id_number_provided" : personal_id_number_provided,
            "ssn_last_4_provided" : ssn_last_4_provided,
            "type" : type,
            "verification" : verification
        ])
    }
}

public final class DateOfBirth: NodeConvertible {

    public let day: Int
    public let month: Int
    public let year: Int

    public required init(node: Node, in context: Context) throws {
        day = try node.extract("day")
        month = try node.extract("month")
        year = try node.extract("year")
    }

    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "day" : day,
            "month" : month,
            "year" : year
        ])
    }
}

public final class TermsOfServiceAgreement: NodeConvertible {

    public let date: Date?
    public let ip: String?
    public let user_agent: String?

    public required init(node: Node, in context: Context) throws {
        date = try node.extract("date")
        ip = try node.extract("ip")
        user_agent = try node.extract("user_agent")
    }

    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "date" : date,
            "ip" : ip,
            "user_agent" : user_agent
        ])
    }
}

public final class TransferSchedule: NodeConvertible {

    public let delay_days: Int
    public let interval: Interval

    public required init(node: Node, in context: Context) throws {
        delay_days = try node.extract("delay_days")
        interval = try node.extract("interval")
    }

    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "delay_days" : delay_days,
            "interval" : interval
        ])
    }
}

final class Account: NodeConvertible {

}
