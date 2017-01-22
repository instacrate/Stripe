//
//  LegalEntityVerification.swift
//  Stripe
//
//  Created by Hakon Hanesand on 1/18/17.
//
//

import Foundation
import Node

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

public final class LegalEntityIdentityVerification: NodeConvertible {
    
    public let status: LegalEntityVerificationStatus
    public let document: Document?
    public let details: String?
    public let details_code: LegalEntityVerificationFailureReason?
    
    public required init(node: Node, in context: Context = EmptyNode) throws {
        status = try node.extract("status")
        document = try node.extract("document")
        details = try node.extract("details")
        details_code = try node.extract("details_code")
    }
    
    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "status" : try status.makeNode(),
        ] as [String : Node]).add(objects: [
            "details" : details,
            "document" : document,
            "details_code" : details_code
        ])
    }
}

public enum LegalEntityType: String, NodeConvertible {
    
    case individual
    case company
}

public final class LegalEntity: NodeConvertible {
    
    public let address: Address
    public let business_name: String?
    public let business_tax_id_provided: Bool
    public let dob: DateOfBirth
    public let first_name: String?
    public let last_name: String?
    public let personal_address: Address
    public let personal_id_number_provided: Bool
    public let ssn_last_4_provided: Bool
    public let type: String?
    public let verification: LegalEntityIdentityVerification
    
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
            "address" : try address.makeNode(),
            "business_tax_id_provided" : .bool(business_tax_id_provided),
            "dob" : try dob.makeNode(),
            "personal_address" : try personal_address.makeNode(),
            "personal_id_number_provided" : .bool(personal_id_number_provided),
            "ssn_last_4_provided" : .bool(ssn_last_4_provided),
            "verification" : try verification.makeNode()
        ] as [String : Node]).add(objects: [
            "business_name" : business_name,
            "first_name" : first_name,
            "last_name" : last_name,
            "type" : type
        ])
    }
    
    static func descriptionForNeededFields(in country: CountryType, for field: String) -> String {
        switch field {
        case "legal_entity.business_name":
            return "The publicly visible name of your business"
        case "legal_entity.business_tax_id":
            return "The tax ID number of your business."
            
        case let field where field.hasPrefix("legal_entity.address"):
            return "The primary address of the legal entity."
            
        case let field where field.hasPrefix("legal_entity.dob"):
            return "The date of birth for your company representative."
            
        case "legal_entity.first_name":
            return "The first name of your company representative."
        case "legal_entity.last_name":
            return "The last name of your company representative."
            
        case "legal_entity.ssn_last_4":
            return "The last four digits of the compnay representative's SSN."
        case "legal_entity.type":
            return "Always company."

        default:
            return field
        }
    }
}
