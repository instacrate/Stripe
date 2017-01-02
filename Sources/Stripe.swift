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

public enum StripeError: Error {

    case error(type: String, message: String)

    public var localizedDescription: String {
        switch self {
        case let .error(type, message):
            return "<StripeError> \(type) : \(message)"
        }
    }
}

extension Message {

    func json() throws -> JSON {
        if let existing = storage["json"] as? JSON {
            return existing
        }

        guard let type = headers["Content-Type"] else {
            throw Abort.custom(status: .badRequest, message: "Missing Content-Type header.")
        }

        guard type.contains("application/json") else {
            throw Abort.custom(status: .badRequest, message: "Missing application/json from Content-Type header.")
        }

        guard case let .data(body) = body else {
            throw Abort.custom(status: .badRequest, message: "Incorrect encoding of body contents.")
        }

        var json: JSON!

        do {
            json = try JSON(bytes: body)
        } catch {
            throw Abort.custom(status: .badRequest, message: "Error parsing JSON in body. Parsing error : \(error)")
        }

        storage["json"] = json
        return json
    }
}

public class HTTPClient {

    let baseURLString: String
    let client: Client<TCPClientStream, Serializer<Request>, Parser<Response>>.Type

    init(urlString: String) {
        baseURLString = urlString

        client = Client<TCPClientStream, Serializer<Request>, Parser<Response>>.self
    }

    func get<T: NodeConvertible>(_ resource: String, query: [String : CustomStringConvertible] = [:]) throws -> T {
        let response = try client.get(baseURLString + resource, headers: Stripe.authorizationHeader, query: query)

        guard let json = try? response.json() else {
            throw Abort.custom(status: .internalServerError, message: response.description)
        }

        try checkForStripeError(in: json)

        return try T.init(node: json.makeNode())
    }

    func get<T: NodeConvertible>(_ resource: String, query: [String : CustomStringConvertible] = [:]) throws -> [T] {
        let response = try client.get(baseURLString + resource, headers: Stripe.authorizationHeader, query: query)

        guard let json = try? response.json() else {
            throw Abort.custom(status: .internalServerError, message: response.description)
        }

        try checkForStripeError(in: json)

        guard let objects = json.node["data"]?.nodeArray else {
            throw Abort.custom(status: .internalServerError, message: "Unexpected response formatting. \(json)")
        }

        return try objects.map {
            return try T.init(node: $0)
        }
    }

    func post<T: NodeConvertible>(_ resource: String, query: [String : CustomStringConvertible] = [:]) throws -> T {
        let response = try client.post(baseURLString + resource, headers: Stripe.authorizationHeader, query: query)

        guard let json = try? response.json() else {
            throw Abort.custom(status: .internalServerError, message: response.description)
        }

        try checkForStripeError(in: json)

        return try T.init(node: json.makeNode())
    }

    func delete(_ resource: String, query: [String : CustomStringConvertible] = [:]) throws -> JSON {
        let response = try client.delete(baseURLString + resource, headers: Stripe.authorizationHeader, query: query)

        guard let json = try? response.json() else {
            throw Abort.custom(status: .internalServerError, message: response.description)
        }

        try checkForStripeError(in: json)
        
        return json
    }

    private func checkForStripeError(in json: JSON) throws {
        if let error = json.node["error"]?.nodeObject {

            guard let type = error["type"]?.string else {
                throw Abort.custom(status: .internalServerError, message: "Unknown error recieved from Stripe.")
            }

            guard let message = error["message"]?.string else {
                throw Abort.custom(status: .internalServerError, message: "Unknown error of type \(type) recieved from Stripe.")
            }

            throw StripeError.error(type: type, message: message)
        }
    }
}

public class Stripe: HTTPClient {

    public static let shared = Stripe()

    static let secretKey = "sk_test_6zSrUMIQfOCUorVvFMS2LEzn"
    static var encodedSecretKey: String {
        return secretKey.data(using: .utf8)!.base64EncodedString()
    }

    static let authorizationHeader: [HeaderKey : String] = ["Authorization" : "Basic \(Stripe.encodedSecretKey)"]

    fileprivate init() {
        super.init(urlString: "https://api.stripe.com/v1/")
    }

    public func createToken() throws -> Token {
        return try post("tokens", query: ["card[number]" : 4242424242424242, "card[exp_month]" : 12, "card[exp_year]" : 2017, "card[cvc]" : 123])
    }

    public func createNormalAccount(email: String, source: String) throws -> Customer {
        return try post("customers", query: ["source" : source])
    }

    public func createManagedAccount(email: String, source: String) throws -> Customer {
        return try post("accounts", query: ["managed" : true, "country" : "US", "email" : email])
    }

    public func associate(source: String, withStripe id: String) throws -> Card {
        return try post("customers/\(id)/sources", query: ["source" : source])
    }

    public func createPlan(with price: Double, name: String, interval: Interval) throws -> Plan {
        let parameters = ["id" : "\(UUID().uuidString)", "amount" : "\(Int(price * 100))", "currency" : "usd", "interval" : interval.rawValue, "name" : name]
        return try post("plans", query: parameters)
    }

    public func subscribe(user userId: String, to planId: String, with frequency: Interval = .month, oneTime: Bool) throws -> Subscription {
        let subscription: Subscription = try post("subscriptions", query: ["customer" : userId, "plan" : planId])

        if oneTime {
            let json = try delete("/subscriptions/\(subscription.id)", query: ["at_period_end" : true])

            guard json["cancel_at_period_end"]?.bool == true else {
                throw Abort.custom(status: .internalServerError, message: json.makeNode().nodeObject?.description ?? "Fuck.")
            }
        }

        return subscription
    }

    public func paymentInformation(for customer: String) throws -> [Card] {
        return try get("customers/\(customer)/sources", query: ["object" : "card"])
    }

    public func information(for customer: String) throws -> Customer {
        return try get("customers/\(customer)")
    }

    public func delete(payment: String, from customer: String) throws -> JSON {
        return try delete("customers/\(customer)/sources/\(payment)")
    }

    public func disputes() throws -> [Dispute] {
        return try get("disputes")
    }

    public func verificationRequiremnts(for country: CountryCode) throws -> Country {
        return try get("country_spec/\(country.rawValue)")
    }
}
