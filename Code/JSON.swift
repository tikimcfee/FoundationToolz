import Foundation
import SwiftyToolz

@dynamicMemberLookup
public enum JSON
{
    // MARK: - Conversions
    
    public init(_ data: Data) throws
    {
        self = try Self(JSONSerialization.jsonObject(with: data))
    }
    
    public func data() throws -> Data
    {
        try JSONSerialization.data(withJSONObject: jsonObject(), options: .prettyPrinted)
    }
    
    public init(_ jsonObject: Object) throws
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
        case let array as ObjectArray:
            self = try .array(array.map(Self.init))
        case let dictionary as ObjectDictionary:
            self = try .dictionary(dictionary.mapValues(Self.init))
        default:
            throw "Invalid JSON object"
        }
    }
    
    private func jsonObject() -> Object
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
    
    public typealias ObjectDictionary = [String: Object]
    public typealias ObjectArray = [Object]
    public typealias Object = Any
    
    // MARK: - Values
    
    func null(_ field: String? = nil) throws -> NSNull
    {
        if let field = field { return try self.field(field).null() }
        guard case .null = self else { throw "JSON is not null" }
        return NSNull()
    }
    
    func bool(_ field: String? = nil) throws -> Bool
    {
        if let field = field { return try self.field(field).bool() }
        guard case .bool(let bool) = self else { throw "JSON is not a Bool" }
        return bool
    }
    
    func int(_ field: String? = nil) throws -> Int
    {
        if let field = field { return try self.field(field).int() }
        guard case .int(let int) = self else { throw "JSON is not an Int" }
        return int
    }
    
    func string(_ field: String? = nil) throws -> String
    {
        if let field = field { return try self.field(field).string() }
        guard case .string(let string) = self else { throw "JSON is not a String" }
        return string
    }
    
    subscript(index: Int) -> JSON?
    {
        guard case .array(let array) = self else { return nil }
        return array.indices.contains(index) ? array[index] : nil
    }
    
    func array(_ field: String? = nil) throws -> [JSON]
    {
        if let field = field { return try self.field(field).array() }
        guard case .array(let array) = self else { throw "JSON is not an Array" }
        return array
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
    
    subscript(key: String) -> JSON?
    {
        guard case .dictionary(let dictionary) = self else { return nil }
        return dictionary[key]
    }
    
    subscript(dynamicMember member: String) -> JSON?
    {
        guard case .dictionary(let dictionary) = self else { return nil }
        return dictionary[member]
    }
    
    func field(_ field: String) throws -> JSON
    {
        guard case .dictionary(let dictionary) = self else
        {
            throw "JSON is not a dictionary"
        }
        
        guard let json = dictionary[field] else
        {
            throw "JSON dictionary contains no field \"\(field)\""
        }
        
        return json
    }
    
    case null
    case bool(Bool)
    case int(Int)
    case string(String)
    case array(Array<JSON>)
    case dictionary(Dictionary<String, JSON>)
}
