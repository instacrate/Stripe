//
//  Webhooks.swift
//  Stripe
//
//  Created by Hakon Hanesand on 1/2/17.
//
//

import Foundation
import HTTP
import Routing
import Vapor

private func parseEvent(fromRequest request: Request) throws -> (EventResource, EventAction) {
    let json = try request.json()

    guard let eventType = json["type"]?.string else {
        throw Abort.custom(status: .badRequest, message: "Event type not found.")
    }

    let components = eventType.components(separatedBy: ".")

    let _resource = components[0..<components.count - 1].joined(separator: ".").lowercased()
    let _action = components[components.count - 1].lowercased()

    guard let resource = EventResource(rawValue: _resource), let action = EventAction(rawValue: _action) else {
        throw Abort.custom(status: .internalServerError, message: "Unsupported event type.")
    }

    return (resource, action)
}

public final class StripeWebhookManager: RouteCollection {

    public static let shared = StripeWebhookManager()

    public typealias Wrapped = HTTP.Responder

    fileprivate var webhookHandlers: [EventResource : [EventAction : (EventResource, EventAction, Request) throws -> (Response)]] = [:]

    public func registerHandler(forResource resource: EventResource, action: EventAction, handler: @escaping (EventResource, EventAction, Request) throws -> Response) {

        var resourceHanderGroup = webhookHandlers[resource] ?? [:]
        resourceHanderGroup[action] = handler
        webhookHandlers[resource] = resourceHanderGroup
    }

    public func build<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {

        builder.grouped("stripe").group("webhook") { webhook in

            webhook.post() { request in
                let (resource, action) = try parseEvent(fromRequest: request)

                guard let handler = self.webhookHandlers[resource]?[action] else {
                    return Response(status: .notImplemented)
                }

                return try handler(resource, action, request)
            }
        }
    }
}
