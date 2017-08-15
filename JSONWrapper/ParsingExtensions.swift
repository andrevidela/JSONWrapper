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
    static func parse(value: JSONValue) -> ParsedValue?
}

extension String: JSONValueParsable {
    public static func parse(value: JSONValue) -> String? {
        return value.asString
    }
}

extension Int: JSONValueParsable {
    public static func parse(value: JSONValue) -> Int? {
        return value.asInt
    }
}

extension Float: JSONValueParsable {
    public static func parse(value: JSONValue) -> Float? {
        return value.asFloat
    }
}

extension Bool: JSONValueParsable {
    public static func parse(value: JSONValue) -> Bool? {
        return value.asBool
    }
}

public protocol JSONObjectParsable: JSONValueParsable {
    associatedtype ParsedValue
    static func parse(object: JSONObject) -> ParsedValue?
}

extension JSONObjectParsable {
    public static func parse(dictionary: [String: JSONValue]) -> ParsedValue? {
        return Self.parse(object: .object(dictionary))
    }

    public static func parse(array: [JSONValue]) -> ParsedValue? {
        return Self.parse(object: .array(array))
    }

    public static func parse(value: JSONValue) -> ParsedValue? {
        switch value {
        case .object(let obj): return Self.parse(object: .object(obj))
        case .array(let arr): return Self.parse(object: .array(arr))
        case _: return nil
        }
    }
}

public enum ArrayOf<E: JSONValueParsable> {
    public static func parse(object: JSONObject) -> [E.ParsedValue]? {
        switch object {
        case .array(let arr): return arr.flatMap(E.parse)
        default: return nil
        }
    }

    public static func parse(value: JSONValue) -> [E.ParsedValue]? {
        switch value {
        case .array(let arr): return arr.flatMap(E.parse(value: ))
        default: return nil
        }
    }

    public static func toJSON<E: JSONValueConvertible>(_ array: [E]) -> JSONObject {
        return .array(array.map(E.toJSON))
    }
}

extension Dictionary {
    public static func parse<E: JSONValueParsable>(object: JSONObject) -> [String: E.ParsedValue]? {
        switch object {
        case .object(let d):
            return d.flatMapValues(E.parse(value:))
        default: return nil
        }
    }

    public static func toJSON<E: JSONValueConvertible>(_ dict: [String: E]) -> JSONObject {
        let fn: (E) -> JSONValue? = { e in e.asJSON }
        return .object(dict.flatMapValues(fn))
    }
}
