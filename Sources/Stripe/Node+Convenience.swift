//
//  Node+Convenience.swift
//  Stripe
//
//  Created by Hakon Hanesand on 1/18/17.
//
//

import Foundation
import Node
import Vapor

public extension Node {
    
    func add(name: String, node: Node?) throws -> Node {
        if let node = node {
            return try add(name: name, node: node)
        }
        
        return self
    }
    
    func add(name: String, node: Node) throws -> Node {
        guard var object = self.nodeObject else { throw NodeError.unableToConvert(node: self, expected: "[String: Node].self") }
        object[name] = node
        return try Node(node: object)
    }
    
    func add(objects: [String : NodeConvertible?]) throws -> Node {
        guard var nodeObject = self.nodeObject else { throw NodeError.unableToConvert(node: self, expected: "[String: Node].self") }
        
        for (name, object) in objects {
            if let node = try object?.makeNode() {
                nodeObject[name] = node
            }
        }
        
        return try Node(node: nodeObject)
    }
}

public extension RawRepresentable where Self: NodeConvertible, RawValue == String {
    
    public init(node: Node, in context: Context = EmptyNode) throws {
        
        guard let string = node.string else {
            throw NodeError.unableToConvert(node: node, expected: "\(String.self)")
        }
        
        guard let value = Self.init(rawValue: string) else {
            throw NodeError.unableToConvert(node: nil, expected: "todo")
        }
        
        self = value
    }
    
    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return Node.string(self.rawValue)
    }
}

public extension RawRepresentable where Self: NodeConvertible, RawValue == String {
    
    public init?(from string: String) throws {
        guard let value = Self.init(rawValue: string) else {
            throw Abort.custom(status: .badRequest, message: "\(string) is not a valid value for for \(Self.self)")
        }
        
        self = value
    }
}

public extension Date {
    
    public init(ISO8601String: String) throws {
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        guard let date = dateFormatter.date(from: ISO8601String) else {
            throw Abort.custom(status: .internalServerError, message: "Error parsing date string : \(ISO8601String)")
        }
        
        self = date
    }
    
    public var ISO8601String: String {
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        return dateFormatter.string(from: self)
    }
}

extension Date: NodeConvertible {
    
    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return .string(self.ISO8601String)
    }
    
    public init(node: Node, in context: Context) throws {
        
        if case let .number(numberNode) = node {
            self = Date(timeIntervalSince1970: numberNode.double)
        } else if case let .string(value) = node {
            self = try Date(ISO8601String: value)
        } else {
            throw NodeError.unableToConvert(node: node, expected: "UNIX timestamp or ISO string.")
        }
    }
}

public extension Node {
    
    func extractList<T: NodeInitializable>(_ path: PathIndex...) throws -> [T] {
        guard let node = self[path] else {
            throw NodeError.unableToConvert(node: self, expected: "path at \(path)")
        }
        
        guard node["object"]?.string == "list" else {
            throw NodeError.unableToConvert(node: node, expected: "object key with list value")
        }
        
        guard let data = node["data"] else {
            throw NodeError.unableToConvert(node: node, expected: "data key with list values")
        }
        
        return try [T](node: data)
    }
}
