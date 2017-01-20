//
//  Stripe.swift
//  Stripe
//
//  Created by Hakon Hanesand on 12/23/16.
//
//

import Foundation
import JSON
import HTTP
import Transport
import Vapor

fileprivate func merge(query _query: [String: CustomStringConvertible], with metadata: [String: CustomStringConvertible]) -> [String: CustomStringConvertible] {
    let arguments = metadata.map { ("metadata[\($0)]", $1) }
    
    var query = _query
    arguments.forEach { query[$0] = $1 }
    
    return query
}

public final class Stripe {

    public static let shared = Stripe()

    static var encodedSecretKey = "sk_test_6zSrUMIQfOCUorVvFMS2LEzn".data(using: .utf8)!.base64EncodedString()
    static let authorizationHeader: [HeaderKey : String] = ["Authorization" : "Basic \(Stripe.encodedSecretKey)"]
    
    fileprivate let base = HTTPClient(urlString: "https://api.stripe.com/v1/")
    fileprivate let uploads = HTTPClient(urlString: "https://uploads.stripe.com/v1/")

    public func createToken() throws -> Token {
        return try base.post("tokens", query: ["card[number]" : 4242424242424242, "card[exp_month]" : 12, "card[exp_year]" : 2017, "card[cvc]" : 123])
    }

    public func createNormalAccount(email: String, source: String, local_id: Int?) throws -> Customer {
        let defaultQuery = ["source" : source]
        let query = local_id.flatMap { merge(query: defaultQuery, with: ["id" : "\($0)"]) } ?? defaultQuery

        return try base.post("customers", query: query)
    }

    public func createManagedAccount(email: String, source: String, local_id: Int?) throws -> Account {
        let defaultQuery: [String: CustomStringConvertible] = ["managed" : true, "country" : "US", "email" : email]
        let query = local_id.flatMap { merge(query: defaultQuery, with: ["id" : "\($0)"]) } ?? defaultQuery
        
        return try base.post("accounts", query: query)
    }

    public func associate(source: String, withStripe id: String) throws -> Card {
        return try base.post("customers/\(id)/sources", query: ["source" : source])
    }

    public func createPlan(with price: Double, name: String, interval: Interval) throws -> Plan {
        let parameters = ["id" : "\(UUID().uuidString)", "amount" : "\(Int(price * 100))", "currency" : "usd", "interval" : interval.rawValue, "name" : name]
        return try base.post("plans", query: parameters)
    }

    public func subscribe(user userId: String, to planId: String, with frequency: Interval = .month, oneTime: Bool, metadata: [String : CustomStringConvertible]) throws -> Subscription {
        let subscription: Subscription = try base.post("subscriptions", query: merge(query: ["customer" : userId, "plan" : planId], with: metadata))

        if oneTime {
            let json = try base.delete("/subscriptions/\(subscription.id)", query: ["at_period_end" : true])

            guard json["cancel_at_period_end"]?.bool == true else {
                throw Abort.custom(status: .internalServerError, message: json.makeNode().nodeObject?.description ?? "Fuck.")
            }
        }

        return subscription
    }

    public func paymentInformation(for customer: String) throws -> [Card] {
        return try base.get("customers/\(customer)/sources", query: ["object" : "card"])
    }

    public func information(for customer: String) throws -> Customer {
        return try base.get("customers/\(customer)")
    }

    public func delete(payment: String, from customer: String) throws -> JSON {
        return try base.delete("customers/\(customer)/sources/\(payment)")
    }

    public func disputes() throws -> [Dispute] {
        return try base.get("disputes")
    }

    public func verificationRequiremnts(for country: CountryCode) throws -> Country {
        return try base.get("country_specs/\(country.rawValue.uppercased())")
    }

    public func acceptedTermsOfService(for user: String, ip: String) throws -> Account {
        return try base.post("accounts/\(user)", query: ["tos_acceptance[date]" : "\(Date().timeIntervalSince1970)", "tos_acceptance[ip]" : ip])
    }

    public func updateInvoiceMetadata(for id: Int, invoice_id: String) throws -> Invoice {
        return try base.post("invoices/\(invoice_id)", query: ["metadata[orders]" : "\(id)"])
    }
    
    public func updateAccount(id: String, parameters: [String : String]) throws -> Account {
        return try base.post("accounts/\(id)", query: parameters)
    }
    
    public func upload(file bytes: Bytes, with reason: UploadReason, type: FileType) throws -> FileUpload {
        let file = Multipart.File(name: "file", type: type.rawValue, data: bytes)
        return try uploads.upload("files", multipart: Multipart.file(file))
    }
}
