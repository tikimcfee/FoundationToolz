import Foundation
import SwiftyToolz

/// String Representation
extension JSON: CustomStringConvertible, CustomDebugStringConvertible
{
    public var debugDescription: String { description }
    
    public var description: String
    {
        (try? data())?.utf8String ?? "Error creating description for \(self)"
    }
}

/// Data Conversion
extension JSON
{
    public init(_ data: Data) throws
    {
        self = try Self(JSONSerialization.jsonObject(with: data))
    }
    
    public func data() throws -> Data
    {
        try JSONSerialization.data(withJSONObject: jsonObject(),
                                   options: .prettyPrinted)
    }
}

/// JSON Object Conversion
extension JSON
{
    public init(_ jsonObject: JSONObject) throws
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
        case let array as JSONObjectArray:
            self = try .array(array.map(Self.init))
        case let dictionary as JSONObjectDictionary:
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

public typealias JSONObjectDictionary = [String: JSONObject]
public typealias JSONObjectArray = [JSONObject]
public typealias JSONObject = Any

/// Case Access
extension JSON
{
    // MARK: - Case Values
    
    func null(_ field: String? = nil) throws -> NSNull
    {
        if let field = field { return try at(field).null() }
        guard case .null = self else { throw "JSON is not null" }
        return NSNull()
    }
    
    func bool(_ field: String? = nil) throws -> Bool
    {
        if let field = field { return try at(field).bool() }
        guard case .bool(let bool) = self else { throw "JSON is not a Bool" }
        return bool
    }
    
    func int(_ field: String? = nil) throws -> Int
    {
        if let field = field { return try at(field).int() }
        guard case .int(let int) = self else { throw "JSON is not an Int" }
        return int
    }
    
    func string(_ field: String? = nil) throws -> String
    {
        if let field = field { return try at(field).string() }
        guard case .string(let string) = self else { throw "JSON is not a String" }
        return string
    }
    
    func array(_ field: String? = nil) throws -> [JSON]
    {
        if let field = field { return try at(field).array() }
        guard case .array(let array) = self else { throw "JSON is not an Array" }
        return array
    }
    
    func dictionary(_ field: String? = nil) throws -> [String: JSON]
    {
        if let field = field { return try at(field).dictionary() }
        guard case .dictionary(let dict) = self else { throw "JSON is not a Dictionary" }
        return dict
    }
    
    // MARK: - Array Elements
    
    subscript(index: Int) -> JSON?
    {
        guard case .array(let array) = self else { return nil }
        return array.indices.contains(index) ? array[index] : nil
    }
    
    func at(_ index: Int) throws -> JSON
    {
        guard case .array(let array) = self else
        {
            throw "JSON is not an array"
        }
        
        guard array.indices.contains(index) else
        {
            throw "JSON array contains no index \(index)"
        }
        
        return array[index]
    }
    
    // MARK: - Dictionary Elements
    
    subscript(key: String) -> JSON?
    {
        guard case .dictionary(let dictionary) = self else { return nil }
        return dictionary[key]
    }
    
    func at(_ key: String) throws -> JSON
    {
        guard case .dictionary(let dictionary) = self else
        {
            throw "JSON is not a dictionary"
        }
        
        guard let json = dictionary[key] else
        {
            throw "JSON dictionary contains no field \"\(key)\""
        }
        
        return json
    }
}

/// JSON with Dynamic Lookup of Dictionary Elements
@dynamicMemberLookup
public enum JSON
{
    subscript(dynamicMember member: String) -> JSON?
    {
        guard case .dictionary(let dictionary) = self else { return nil }
        return dictionary[member]
    }
    
    case null
    case bool(Bool)
    case int(Int)
    case string(String)
    case array([JSON])
    case dictionary([String: JSON])
}
