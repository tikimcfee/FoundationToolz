import Foundation
import SwiftyToolz

/// Decoding Instances of Decodable Types
extension JSON
{
    public func decode<Value: Decodable>(as type: Value.Type = Value.self) throws -> Value
    {
        try Value(jsonData: encode())
    }
}

/// String Representation
extension JSON: CustomStringConvertible, CustomDebugStringConvertible
{
    public var debugDescription: String { description }
    
    public var description: String
    {
        let jo = jsonObject()
        return (try? Data(jsonObject: jo))?.utf8String ?? "\(jo)"
    }
}

/// Data Conversion
extension JSON
{
    public init(_ data: Data) throws
    {
        self = try Self(JSONSerialization.jsonObject(with: data))
    }
    
    public func encode() throws -> Data
    {
        try Data(jsonObject: jsonObject())
    }
}

/// JSON Object Conversion
public extension JSON
{
    init(_ jsonObject: JSONObject) throws
    {
        switch jsonObject
        {
        case is NSNull:
            self = .null
        case let bool as Bool:
            self = .bool(bool)
        case let int as Int:
            self = .int(int)
        case let string as String:
            self = .string(string)
        case let array as [JSONObject]:
            self = try .array(array.map(Self.init))
        case let dictionary as [String: JSONObject]:
            self = try .dictionary(dictionary.mapValues(Self.init))
        default:
            throw "Invalid JSON object: \(jsonObject)"
        }
    }
    
    private func jsonObject() -> JSONObject
    {
        switch self
        {
        case .null:
            return NSNull()
        case .bool(let bool):
            return bool
        case .int(let int):
            return int
        case .string(let string):
            return string
        case .array(let array):
            return array.map { $0.jsonObject() }
        case .dictionary(let dictionary):
            return dictionary.mapValues { $0.jsonObject() }
        }
    }
}
