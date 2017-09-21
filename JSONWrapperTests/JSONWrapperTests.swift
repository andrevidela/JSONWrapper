//
//  JSONWrapperTests.swift
//  JSONWrapperTests
//
//  Created by zephyz on 22.06.17.
//  Copyright © 2017 zephyz. All rights reserved.
//

import XCTest
@testable import JSONWrapper

struct Person {
    let name: String
    let age: Int
}

extension Person: JSONObjectParsable {
    static func parse(object: JSONObject) -> Person.ParsedValue? {
        guard case .object(let dictionary) = object else { return nil }
        if case let .string(n)? = dictionary["name"],
            case let .float(a)? = dictionary["age"] {
            return Person(name: n, age: Int(a))
        } else { return nil }
    }

    typealias ParsedValue = Person

}

extension Person: JSONObjectConvertible {

    var asJSON: JSONObject {
        return JSONObject.object(["name": name.asJSON, "age": age.asJSON])
    }
}


extension Person: Equatable {
    static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.age == rhs.age && lhs.name == rhs.name
    }
}

struct UserInfo {
    let person: Person
    let address: Address
}

extension UserInfo: Equatable {
    static func == (lhs: UserInfo, rhs: UserInfo) -> Bool {
        return lhs.person == rhs.person && lhs.address == rhs.address
    }
}

extension UserInfo: JSONObjectParsable {
    typealias ParsedValue = UserInfo
    
    static func parse(object: JSONObject) -> UserInfo? {
        guard case .object(let dictionary) = object else { return nil }

        if let p = dictionary["person"],
            let a = dictionary["address"],
            let person = p.asObject.flatMap(Person.parse(dictionary: )),
            let address = a.asObject.flatMap(Address.parse(dictionary: )) {
            return UserInfo(person: person, address: address(person.name))
        } else { return nil }
    }
}

extension UserInfo: JSONObjectConvertible {
    var asJSON: JSONObject {
        return JSONObject.object(["person": person.asJSON, "address": address.asJSON])
    }
}

struct Address {
    let owner: String
    let street: String
    let coordinates: Coordinates
}

extension Address: Equatable {
    static func == (lhs: Address, rhs: Address) -> Bool {
        return lhs.owner == rhs.owner && rhs.street == lhs.street && lhs.coordinates == rhs.coordinates
    }
}

extension Address : JSONObjectParsable {
    static func parse(object: JSONObject) -> ((String) -> Address)? {
        guard case .object(let dictionary) = object else { return nil }
        if let street = dictionary["street"]?.asString,
            let coordinates = dictionary["coordinates"]?.asObject.flatMap(Coordinates.parse(dictionary: )) {
            return { (owner: String) -> Address in
                Address(owner: owner, street: street, coordinates: coordinates)
            }
        } else { return nil }
    }
}

extension Address: JSONObjectConvertible {
    var asJSON: JSONObject {
        return JSONObject.object(["street": street.asJSON, "coordinates": coordinates.asJSON])
    }
}

struct Coordinates {
    let latitude: Float
    let longitude: Float
}

extension Coordinates: Equatable {
    static func == (lhs: Coordinates, rhs: Coordinates) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension Coordinates: JSONObjectParsable {
    static func parse(object: JSONObject) -> Coordinates? {
        guard case .object(let dictionary) = object else { return nil }
        if let lat = dictionary["latitude"]?.asFloat,
            let lon = dictionary["longitude"]?.asFloat {
            return Coordinates(latitude: lat, longitude: lon)
        } else { return nil }
    }
}

extension Coordinates: JSONObjectConvertible {
    var asJSON: JSONObject {
        return JSONObject.object(["latitude": latitude.asJSON, "longitude": longitude.asJSON])
    }
}

class JSONWrapperTests: XCTestCase {


    func parseDataJSON() {
        let json = "{\"age\": 18, \"key\": \"value\", \"bool\": false}"
        let data = Data.init(base64Encoded: json)
        let parsed = data.flatMap(JSONObject.parse(fromData: ))
        guard let success = parsed else { XCTFail(); return }
        XCTAssertEqual(JSONObject.object(["age": JSONValue.float(18), "key": JSONValue.string("value"), "bool": JSONValue.bool(false)]), success)
    }

    func testParseEmptyArray() {
        let p = JSONObject.parse(fromString: "[]")
        XCTAssertNotNil(p)
        if case .array(let a)? = p, a.isEmpty {
            // all good
        } else {
            XCTFail()
        }
    }
    func testParseEmptyObject() {
        let p = JSONObject.parse(fromString: "{}")
        XCTAssertNotNil(p)
        if case .object(let o)? = p, o.isEmpty {
            // all good
        } else {
            XCTFail("Could not parse object")
        }
    }

    func testParsePopulatedObject() {
        let p = JSONObject.parse(fromString: "{\"key\": \"value\"}")
        XCTAssertNotNil(p)
        if case .object(let o)? = p {
            XCTAssertNotNil(o["key"])
            XCTAssertEqual(o["key"]!, .string("value"))
        } else {
            XCTFail("Could not parse object")
        }
    }

    func testMismatchedBraces() {
        let p = JSONObject.parse(fromString: "{}}")
        XCTAssertNil(p)
    }

    func testHeterogenousArray() {
        let p = JSONObject.parse(fromString: "[true, false, 0, \"nothing\", {}, {\"key\": \"value\"}]")
        XCTAssertNotNil(p)
        let ref: [JSONValue] = [.bool(true), .bool(false), .float(0), .string("nothing"), .object([:]), .object(["key": .string("value")])]
        if case .array(let a)? = p {
            XCTAssertEqual(a, ref)
        } else {
            XCTFail(p!.description)
        }
    }

    func testArrayGetter() {
        let p = JSONObject.parse(fromString: "[true, false]")
        XCTAssertNotNil(p)
        XCTAssertNotNil(p!.asArray)
        XCTAssertEqual(p!.asArray!.first!, .bool(true))
    }

    func testObjectGetter() {
        let p = JSONObject.parse(fromString: "{\"age\": 18}")
        XCTAssertNotNil(p)
        XCTAssertNotNil(p!.asObject)
        XCTAssertEqual(p!.asObject!["age"]!, .float(18))
    }

    func testFloatJSON() {
        let p = JSONObject.parse(fromString: "{\"age\": 17.9}")
        XCTAssertNotNil(p)
        XCTAssertNotNil(p!.asObject)
        XCTAssertEqual(p!.asObject!["age"]!, .float(17.9))
    }
    let complexObject = UserInfo(person: Person(name: "me", age: 123), address: Address(owner: "me", street: "there", coordinates: Coordinates(latitude: 0.0, longitude: 1.0)))

    func testComplexObject() {
        XCTAssertEqual(complexObject, UserInfo.parse(object: complexObject.asJSON))
    }

    func testSimpleObject() {

        let simple = Person(name: "abaca", age: 12345)
        XCTAssertEqual(simple, Person.parse(object: simple.asJSON)!)
    }

    func testPrinting() {
        let json = ArrayOf<UserInfo>.toJSON([complexObject, complexObject])
        let toprint = prettyPrint(json: json)
        print(toprint)
        let parsed = JSONObject.parse(fromString: toprint).flatMap(ArrayOf<UserInfo>.parse(object: )).flatMap(ArrayOf<UserInfo>.toJSON)
        XCTAssertEqual(parsed!, json)
    }
}


