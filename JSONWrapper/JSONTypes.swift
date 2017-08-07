//
//  JSONTypes.swift
//  JSONWrapper
//
//  Created by zephyz on 22.06.17.
//  Copyright © 2017 zephyz. All rights reserved.
//

import Foundation

extension Dictionary {
    fileprivate func flatMapValues<T>(_ f: (Value) -> T?) -> [Key: T] {
        var d: [Key: T] = [:]
        for (k, v) in self {
            if let newV = f(v) {
                d[k] = newV
            }
        }
        return d
    }
}

private enum Helper {
    static func lift<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
        return { $0.map(f) }
    }

    static func bind<A, B>(_ f: @escaping (A) -> B?) -> (A?) -> B? {
        return { $0.flatMap(f) }
    }
}

public enum JSONObject {
    case object([String: JSONValue])
    case array([JSONValue])

    public static func parse(fromString json: String, using encoding: String.Encoding = .ascii) -> JSONObject? {
        return Helper.bind(JSONObject.parse(fromData: ))(json.data(using: encoding))
    }
    public static func parse(fromData json: Data) -> JSONObject? {
        let any = try? JSONSerialization.jsonObject(with: json, options: [])
        return Helper.bind(JSONObject.parse(fromAny: ))(any)    }

    public static func parse(fromAny json: Any) -> JSONObject? {
        switch json {
        case let obj as [String: Any]: return .object(obj.flatMapValues(JSONValue.parse(fromAny: )))
        case let arr as [Any]: return .array(arr.flatMap(JSONValue.parse(fromAny: )))
        case _: return nil
        }
    }
}

extension JSONObject {
    public var asObject: [String: JSONValue]? {
        switch self {
        case .object(let o): return o
        case _: return nil
        }
    }

    public var asArray: [JSONValue]? {
        switch self {
        case .array(let a): return a
        case _: return nil
        }
    }
}

extension JSONObject: Equatable {
    public static func == (lhs: JSONObject, rhs: JSONObject) -> Bool {
        switch (lhs, rhs) {
        case let (.object(o1), .object(o2)): return o1 == o2
        case let (.array(a1), .array(a2)): return a1 == a2
        case _: return false
        }
    }
}

extension JSONObject: CustomStringConvertible {
    public var description: String {
        switch self {
        case .object(let d): return d.description
        case .array(let a): return a.description
        }
    }
}

public enum JSONValue {
    case bool(Bool)
    case float(Float)
    case string(String)
    case object([String: JSONValue])
    case array([JSONValue])

    public static func parse(fromString json: String, using encoding: String.Encoding = .ascii) -> JSONValue? {
        return Helper.bind(parse(fromData: ))(json.data(using: encoding))
    }

    public static func parse(fromData json: Data) -> JSONValue? {
        let any = try? JSONSerialization.jsonObject(with: json, options: [])
        return Helper.bind(parse(fromAny: ))(any)
    }

    public static func parse(fromAny json: Any) -> JSONValue? {
        switch json {
        case let float as Float: return .float(float)
        case let str as String: return .string(str)
        case let obj as [String: Any]: return .object(obj.flatMapValues(JSONValue.parse(fromAny: )))
        case let arr as [Any]: return .array(arr.flatMap(JSONValue.parse(fromAny: )))
        case let bool as Bool: return .bool(bool)
        case _: return nil
        }
    }
}

extension JSONValue {
    public var asBool: Bool? {
        switch self {
        case .bool(let b): return b
        case _: return nil
        }
    }

    public var asInt: Int? {
        switch self {
        case .float(let f): return Int(f)
        case _: return nil
        }
    }

    public var asFloat: Float? {
        switch self {
        case .float(let f): return f
        case _: return nil
        }
    }

    public var asString: String? {
        switch self {
        case .string(let s): return s
        case _: return nil
        }
    }

    public var asObject: [String: JSONValue]? {
        switch self {
        case .object(let o): return o
        case _: return nil
        }
    }

    public var asArray: [JSONValue]? {
        switch self {
        case .array(let a): return a
        case _: return nil
        }
    }
}

extension JSONValue: Equatable {
    public static func == (lhs: JSONValue, rhs: JSONValue) -> Bool {
        switch (lhs, rhs) {
        case let (.bool(b1), .bool(b2)): return b1 == b2
        case let (.float(f1), .float(f2)): return f1 == f2
        case let (.string(s1), .string(s2)): return s1 == s2
        case let (.array(a1), .array(a2)): return a1 == a2
        case let (.object(o1), .object(o2)): return o1 == o2
        case _: return false
        }
    }
}
