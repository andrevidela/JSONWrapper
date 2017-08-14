//
//  AutoParsing.swift
//  JSONWrapper
//
//  Created by avidela on 14.08.17.
//  Copyright © 2017 André Videla. All rights reserved.
//

import Foundation

public protocol JSONValueConvertible {
    var asJSON: JSONValue { get }
    static func toJSON(_ value: Self) -> JSONValue
}

public extension JSONValueConvertible {
    static func toJSON(_ value: Self) -> JSONValue {
        return value.asJSON
    }
}

extension String: JSONValueConvertible {
    public var asJSON: JSONValue {
        return .string(self)
    }
}

extension Bool: JSONValueConvertible {
    public var asJSON: JSONValue {
        return .bool(self)
    }
}

extension Int: JSONValueConvertible {
    public var asJSON: JSONValue {
        return .float(Float(self))
    }
}

extension Float: JSONValueConvertible {
    public var asJSON: JSONValue {
        return .float(self)
    }
}

public protocol JSONObjectConvertible: JSONValueConvertible {
    var asJSON: JSONObject { get }
}

extension JSONObjectConvertible {
    var asJSON: JSONValue {
        let obj: JSONObject = self.asJSON
        switch obj {
        case .array(let a): return JSONValue.array(a)
        case .object(let d): return JSONValue.object(d)
        }
    }
}

public protocol JSONValueParsable {
    associatedtype ParsedValue
    static func parse(json: JSONValue) -> ParsedValue?
}

extension String: JSONValueParsable {
    public static func parse(json: JSONValue) -> String? {
        return json.asString
    }
}

extension Int: JSONValueParsable {
    public static func parse(json: JSONValue) -> Int? {
        return json.asInt
    }
}

extension Float: JSONValueParsable {
    public static func parse(json: JSONValue) -> Float? {
        return json.asFloat
    }
}

extension Bool: JSONValueParsable {
    public static func parse(json: JSONValue) -> Bool? {
        return json.asBool
    }
}

public protocol JSONObjectParsable {
    associatedtype ParsedValue
    static func parse(json: [String: JSONValue]) -> ParsedValue?
    static func parse(json: JSONObject) -> ParsedValue?
}

extension JSONObjectParsable {
    static func parse(json: JSONObject) -> ParsedValue? {
        switch json {
        case .object(let d): return Self.parse(json: d)
        default: return nil
        }
    }
}

extension Array {
    static func parse<E: JSONValueParsable>(json: JSONObject) -> [E.ParsedValue]? {
        switch json {
        case .array(let arr): return arr.flatMap(E.parse)
        default: return nil
        }
    }
}

extension Dictionary {
    static func parse<E: JSONValueParsable>(json: JSONObject) -> [String: E.ParsedValue]? {
        switch json {
        case .object(let d):
            return d.flatMapValues(E.parse(json:))
        default: return nil
        }
    }
}
