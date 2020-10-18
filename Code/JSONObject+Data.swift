import Foundation
import SwiftyToolz

public extension JSONObject
{
    func data() throws -> Data
    {
        try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
    }
    
    init(_ data: Data) throws
    {
        self = try (JSONSerialization.jsonObject(with: data) as? JSONObject).unwrap()
    }
    
    func nul(_ key: String) throws -> NSNull { try (self[key] as? NSNull).unwrap() }
}

public extension JSONArray
{
    init(_ data: Data) throws
    {
        self = try (JSONSerialization.jsonObject(with: data) as? JSONArray).unwrap()
    }
}
