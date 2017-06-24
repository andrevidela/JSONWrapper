# JSONWrapper
A small wrapper around JSONSerialization

## Carthage

add `github andrevidela/JSONWrapper` to your cartfile and download the library as a dependency. Then add the relevant `.framework` file into your project

## Usage

JSONWrapper has two enums which accuractly represent the JSON format:

The JSONObject enum which represent a top level JSON object
```
public enum JSONObject {
    case object([String: JSONValue])
    case array([JSONValue])
}
```

And the JSONValue enum which represent the different values that an array or an object can contain.

```
public enum JSONValue {
    case bool(Bool)
    case int(Int)
    case string(String)
    case object([String: JSONValue])
    case array([JSONValue])
}
```

You can use the static method of JSONObject `JSONObject.parse(fromString: String) -> JSONObject?` to parse a JSON string into a JSONObject. 
If the string is not valid JSON the result will be nil.

Alternatively, if you already have a parsed JSON object as a value of type `Any` (for example comming from another library). 
You can use the method `JSONObject.parse(fromAny: Any) -> JSONObject?` to convert the `Any` value into a JSONObject.

## Motivation & tradeoffs

We are all eagerly waiting for Swift 4 and it's JSON decoder and encoder. But in the meantime JSON serialization is still done
with `NSJSONSerialization` which does not provide a very ergonomic or safe API to interact with JSON.

This library also focuses on accurately representing the JSON format by distinguishing between top level json objects and 
nested json values.

Converting from a very flexible format such as JSON into a rigid type system comes with some translation costs and possibly
unexpected tradeoffs:

- Instead of having a unified interface for all JSON values, we have two representations, one for top level objects and one for
nested objects. This might introduce an additional level of complexity but accurately represents the official JSON format. One
decision to aleviate this effect was to have `.array([JSONValue])` and `.object([String: JSONValue])` values as member of `JSONValue`
instead of using `.object(JSONObject)`. This removes a level of unwrapping when manipulating nested structures even though it adds
some (small) amount of code duplication
- `"[0]" could be legaly interpreted as `[.bool(false)]` because of Javascript's interpretation of `truthy` and `falsy` values.
It has been decided that this behaviour would not carry over and `"[0]"` maps to `[.int(0)]` instead of `[.bool(false)]`.
