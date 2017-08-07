//
//  JSONWrapperTests.swift
//  JSONWrapperTests
//
//  Created by zephyz on 22.06.17.
//  Copyright © 2017 zephyz. All rights reserved.
//

import XCTest
@testable import JSONWrapper

class JSONWrapperTests: XCTestCase {


    func parseDataJSON() {
        let json = "{\"age\": 18, \"key\": \"value\", \"bool\": false}"
        let data = Data.init(base64Encoded: json)
        let parsed = data.flatMap(JSONObject.parse(fromData: ))
        guard let success = parsed else { XCTFail(); return }
        XCTAssertEqual(JSONObject.object(["age": JSONValue.int(18), "key": JSONValue.string("value"), "bool": JSONValue.bool(false)]), success)
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
        let ref: [JSONValue] = [.bool(true), .bool(false), .int(0), .string("nothing"), .object([:]), .object(["key": .string("value")])]
        if case .array(let a)? = p,
            a == ref {
            // ok
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
        XCTAssertEqual(p!.asObject!["age"]!, .int(18))
    }
}


