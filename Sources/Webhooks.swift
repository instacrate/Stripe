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

enum WebhookAction: String {

    case updated
    case deleted
    case created
}

enum WebhookResource: String {

    case account
}

private func parseEvent(fromRequest request: Request) throws -> (WebhookResource, WebhookAction) {
    let json = try request.json()

    guard let eventType = json["type"]?.string else {
        throw Abort.custom(status: .badRequest, message: "Event type not found.")
    }

    let components = eventType.components(separatedBy: ".")

    let _resource = components[0..<components.count - 1].joined(separator: ".").lowercased()
    let _action = components[components.count - 1].lowercased()

    guard let resource = WebhookResource(rawValue: _resource), let action = WebhookAction(rawValue: _action) else {
        throw Abort.custom(status: .noContent, message: "Unsupported event type.")
    }

    return (resource, action)
}

public class StripeWebhookManager: RouteCollection {

    public static let shared = StripeWebhookManager()

    public typealias Wrapped = HTTP.Responder

    fileprivate var webhookHandlers: [WebhookResource : [WebhookAction : [(WebhookResource, WebhookAction, Request) throws -> (Response)]]] = [:]

    func registerHandler(forResource resource: WebhookResource, action: WebhookAction, handler: @escaping (WebhookResource, WebhookAction, Request) throws -> Response) {

        var resourceHanderGroup = webhookHandlers[resource] ?? [:]
        var actionHandlerGroup = resourceHanderGroup[action] ?? []

        actionHandlerGroup.append(handler)

        resourceHanderGroup[action] = actionHandlerGroup
        webhookHandlers[resource] = resourceHanderGroup
    }

    public func build<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {

        builder.grouped("stripe").group("webhook") { webhook in

            webhook.post() { request in
                let (resource, action) = try parseEvent(fromRequest: request)

                guard let handlers = self.webhookHandlers[resource]?[action] else {
                    return Response(status: .noContent)
                }

                let responses = try handlers.map { try $0(resource, action, request) }
                let failingResponses = responses.filter { !(200..<300 ~= $0.status.statusCode) }

                return failingResponses.count > 0 ? failingResponses.first! : Response(status: .noContent)
            }
        }
    }
}
