//
//  Token.swift
//  Stripe
//
//  Created by Hakon Hanesand on 12/23/16.
//
//

import Foundation
import Node

class Token: NodeConvertible {

    static let type = "token"

    let id: String
    let client_ip: String
    let created: Date
    let livemode: Bool
    let type: String
    let used: Bool
    let card: Card

    required init(node: Node, in context: Context = EmptyNode) throws {
        guard try node.extract("object") == Token.type else {
            throw NodeError.unableToConvert(node: node, expected: Token.type)
        }

        id = try node.extract("id")
        client_ip = try node.extract("client_ip")
        created = try node.extract("created")
        livemode = try node.extract("livemode")
        type = try node.extract("type")
        used = try node.extract("used")
        card = try node.extract("card")
    }

    func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node : [
            "id" : id,
            "client_ip" : client_ip,
            "created" : created,
            "livemode" : livemode,
            "type" : type,
            "used" : used,
            "card" : card.makeNode()
        ])
    }
}
