//
//  Account.swift
//  Stripe
//
//  Created by Hakon Hanesand on 1/2/17.
//
//

import Foundation
import Node

public final class DeclineChargeRules: NodeConvertible {

    public let avs_failure: Bool
    public let cvc_failure: Bool

    public required init(node: Node, in context: Context = EmptyNode) throws {
        avs_failure = try node.extract("avs_failure")
        cvc_failure = try node.extract("cvc_failure")
    }

    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "avs_failure" : avs_failure,
            "cvc_failure" : cvc_failure
        ])
    }
}

public enum LegalEntityVerificationStatus: String, NodeConvertible {

    case unverified
    case pending
    case verified
}

public enum LegalEntityVerificationFailureReason: String, NodeConvertible {

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

public class LegalEntityIdentityVerification: NodeConvertible {

    public let status: LegalEntityVerificationStatus
    public let document: Document
    public let details: String
    public let details_code: LegalEntityVerificationFailureReason

    public required init(node: Node, in context: Context = EmptyNode) throws {
        status = try node.extract("status")
        document = try node.extract("document")
        details = try node.extract("details")
        details_code = try node.extract("details_code")
    }

    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "status" : status,
            "document" : document,
            "details" : details,
            "details_code" : details_code
        ])
    }
}

public final class LegalEntity: NodeConvertible {

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

public enum IdentityVerificationFailureReason: String, NodeConvertible {

    case fraud = "rejected.fraud"
    case tos = "rejected.terms_of_service"
    case rejected_listed = "rejected.listed"
    case rejected_other = "rejected.other"
    case fields_needed
    case listed
    case other
}

public class IdentityVerification: NodeConvertible {

    public let disabled_reason: IdentityVerificationFailureReason
    public let due_by: Date?
    public let fields_needed: [String]

    public required init(node: Node, in context: Context = EmptyNode) throws {
        disabled_reason = try node.extract("disabled_reason")
        due_by = try node.extract("due_by")
        fields_needed = try node.extract("fields_needed")
    }

    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "disabled_reason" : disabled_reason.makeNode(),
            "fields_needed" : .array(fields_needed.map { Node.string($0) } ),
        ] as [String : Node]).add(objects: ["due_by" : due_by])
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

public final class Account: NodeConvertible {
    
    static let type = "account"

    public let id: String
    public let business_logo: String?
    public let business_name: String?
    public let business_url: String?
    public let charges_enabled: Bool
    public let country: CountryCode
    public let debit_negative_balances: Bool
    public let decline_charge_on: DeclineChargeRules
    public let default_currency: Currency
    public let details_submitted: Bool
    public let display_name: String
    public let email: String
    public let external_accounts: Node
    public let legal_entity: LegalEntity
    public let managed: Bool
    public let product_description: String?
    public let statement_descriptor: String?
    public let support_email: String?
    public let support_phone: String?
    public let timezone: String
    public let tos_acceptance: TermsOfServiceAgreement
    public let transfer_schedule: TransferSchedule
    public let transfer_statement_descriptor: String?
    public let transfers_enabled: Bool
    public let verification: IdentityVerification
    public let keys: String

    public required init(node: Node, in context: Context) throws {
        
        guard try node.extract("object") == Account.type else {
            throw NodeError.unableToConvert(node: node, expected: Account.type)
        }
        
        id = try node.extract("id")
        business_logo = try? node.extract("business_logo")
        business_name = try? node.extract("business_name")
        business_url = try? node.extract("business_url")
        charges_enabled = try node.extract("charges_enabled")
        country = try node.extract("country")
        debit_negative_balances = try node.extract("debit_negative_balances")
        decline_charge_on = try node.extract("decline_charge_on")
        default_currency = try node.extract("default_currency")
        details_submitted = try node.extract("details_submitted")
        display_name = try node.extract("display_name")
        email = try node.extract("email")
        external_accounts = try node.extract("external_accounts")
        legal_entity = try node.extract("legal_entity")
        managed = try node.extract("managed")
        product_description = try node.extract("product_description")
        statement_descriptor = try node.extract("statement_descriptor")
        support_email = try node.extract("support_email")
        support_phone = try node.extract("support_phone")
        timezone = try node.extract("timezone")
        tos_acceptance = try node.extract("tos_acceptance")
        transfer_schedule = try node.extract("transfer_schedule")
        transfer_statement_descriptor = try node.extract("transfer_statement_descriptor")
        transfers_enabled = try node.extract("transfers_enabled")
        verification = try node.extract("verification")
        keys = try node.extract("keys")
    }

    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "id" : id,
            "business_logo" : business_logo,
            "business_name" : business_name,
            "business_url" : business_url,
            "charges_enabled" : charges_enabled,
            "country" : country,
            "debit_negative_balances" : debit_negative_balances,
            "decline_charge_on" : decline_charge_on,
            "default_currency" : default_currency,
            "details_submitted" : details_submitted,
            "display_name" : display_name,
            "email" : email,
            "external_accounts" : external_accounts,
            "legal_entity" : legal_entity,
            "managed" : managed,
            "product_description" : product_description,
            "statement_descriptor" : statement_descriptor,
            "support_email" : support_email,
            "support_phone" : support_phone,
            "timezone" : timezone,
            "tos_acceptance" : tos_acceptance,
            "transfer_schedule" : transfer_schedule,
            "transfer_statement_descriptor" : transfer_statement_descriptor,
            "transfers_enabled" : transfers_enabled,
            "verification" : verification,
            "keys" : keys
        ])
    }

}
