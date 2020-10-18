import Foundation
import SwiftyToolz

public struct LSP
{
    public enum Message
    {
        public init(_ json: JSONObject) throws
        {
            if let nullableID = Message.getID(fromMessage: json) // request or response
            {
                if let result = try? json.any("result") // success response
                {
                    self = .response(.init(id: nullableID, result: .success(result)))
                }
                else if let errorJSON = try? json.obj("error") // error response
                {
                    let error = try Response.Error(errorJSON)
                    self = .response(.init(id: nullableID, result: .failure(error)))
                }
                else // request
                {
                    guard case .value(let id) = nullableID else
                    {
                        throw "Invalid message JSON. Either it's a response with no error and no result, or it's a request/notification with a <null> id"
                    }
                    self = .request(.init(id: id,
                                          method: try json.str("method"),
                                          params: json["params"]))
                }
            }
            else // notification
            {
                self = .notification(.init(method: try json.str("method"),
                                           params: json["params"]))
            }
        }
        
        private static func getID(fromMessage message: JSONObject) -> NullableID?
        {
            guard let anyID = message["id"] else { return nil }
            
            switch anyID {
            case let string as String: return .value(.string(string))
            case let int as Int: return .value(.int(int))
            case is NSNull: return .null
            default: return nil
            }
        }
        
        public func jsonObject() -> JSONObject
        {
            var json: JSONObject = ["jsonrpc": "2.0"]
            
            switch self
            {
            case .request(let request):
                json["id"] = request.id.json
                json["method"] = request.method
                json["params"] = request.params
            case .response(let response):
                json["id"] = response.id.json
                switch response.result
                {
                case .success(let resultJSON):
                    json["result"] = resultJSON
                case .failure(let error):
                    json["error"] = error.jsonObject()
                }
            case .notification(let notification):
                json["method"] = notification.method
                json["params"] = notification.params
            }
            
            return json
        }
        
        case request(Request)
        case response(Response)
        case notification(Notification)
        
        public struct Notification
        {
            public init(method: String, params: JSON?)
            {
                self.method = method
                self.params = params
            }
            
            public let method: String
            public let params: JSON?
        }

        public struct Response
        {
            public init(id: NullableID, result: Result<JSON, Error>)
            {
                self.id = id
                self.result = result
            }
            
            public let id: NullableID
            public let result: Result<JSON, Error>
            
            public struct Error: Swift.Error, CustomStringConvertible, ReadableErrorConvertible
            {
                init(_ json: JSONObject) throws
                {
                    code = try json.int("code")
                    message = try json.str("message")
                    data = json["data"]
                }
                
                func jsonObject() -> JSONObject
                {
                    var object: JSONObject = ["code": code, "message": message]
                    data.forSome { object["data"] = $0 }
                    return object
                }
                
                public var readableMessage: String { description }
                
                public var description: String
                {
                    var errorString = "LSP Error: \(message) (code \(code))"
                    data.forSome { errorString += " data:\n\($0)" }
                    return errorString
                }
                
                public let code: Int
                public let message: String
                public let data: JSON?
            }
        }

        public struct Request
        {
            public init(id: ID, method: String, params: JSON?)
            {
                self.id = id
                self.method = method
                self.params = params
            }
            
            public let id: ID
            public let method: String
            public let params: JSON?
        }
        
        public enum NullableID: CustomStringConvertible
        {
            public var description: String
            {
                switch self
                {
                case .value(let id): return id.description
                case .null: return NSNull().description
                }
            }
            
            var json: JSON
            {
                switch self
                {
                case .value(let id): return id.json
                case .null: return NSNull()
                }
            }
            
            case value(ID), null
        }

        public enum ID: CustomStringConvertible
        {
            public var description: String
            {
                switch self
                {
                case .string(let string): return string.description
                case .int(let int): return int.description
                }
            }
            
            var json: JSON
            {
                switch self
                {
                case .string(let string): return string
                case .int(let int): return int
                }
            }
            
            case string(String), int(Int)
        }
    }
    
    public static func makeFrame(withContent content: Data) -> Data
    {
        let header = "Content-Length: \(content.count)\r\n\r\n".data!
        return header + content
    }
    
    public static func extractContent(fromFrame frame: Data) throws -> Data
    {
        guard let contentIndex = indexOfContent(in: frame) else
        {
            throw "Invalid LSP Frame"
        }
        
        return frame[contentIndex...]
    }
    
    private static func indexOfContent(in frame: Data) -> Int?
    {
        let separatorLength = 4
        
        guard frame.count > separatorLength else { return nil }
        
        let lastIndex = frame.count - 1
        let lastSearchIndex = lastIndex - separatorLength
        
        for index in 0 ... lastSearchIndex
        {
            if frame[index] == 13,
               frame[index + 1] == 10,
               frame[index + 2] == 13,
               frame[index + 3] == 10
            {
                return index + separatorLength
            }
        }
        
        return nil
    }
}
