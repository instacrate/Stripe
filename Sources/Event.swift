//
//  File.swift
//  subber-api
//
//  Created by Hakon Hanesand on 1/18/17.
//
//

import Foundation
import Node

final class Event: NodeConvertible {
    
    public let id: String
    public let api_version: String
    public let created: Date
    public let data: Node
    public let livemode: Bool
    public let pending_webhooks: Int
    public let request: String?
    public let type: String

    public init(node: Node, in context: Context = EmptyNode) throws {
        id = try node.extract("id")
        api_version = try node.extract("api_version")
        created = try node.extract("created")
        data = try node.extract("data")
        livemode = try node.extract("livemode")
        pending_webhooks = try node.extract("pending_webhooks")
        request = try node.extract("request")
        type = try node.extract("type")
    }
    
    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "id" : id,
            "api_version" : api_version,
            "created" : created,
            "data" : data,
            "livemode" : livemode,
            "pending_webhooks" : pending_webhooks,
            "request" : request,
            "type" : type
        ])
    }
}
