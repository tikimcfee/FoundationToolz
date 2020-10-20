import Foundation
import SwiftyToolz

public struct LSP
{
    public enum Message
    {
        public init(packet: Data) throws
        {
            let data = try LSP.getMessageData(fromPacket: packet)
            self = try Self(data)
        }
        
        public init(_ data: Data) throws
        {
            self = try Self(JSON(data))
        }
        
        public init(_ json: JSON) throws
        {
            guard let nullableID = Message.getID(fromMessage: json) else
            {
                self = try .notification(.init(method: json.string("method"),
                                               params: json.params))
                return
            }
            
            if let result = json.result // success response
            {
                self = .response(.init(id: nullableID, result: .success(result)))
            }
            else if let error = json.error  // error response
            {
                self = .response(.init(id: nullableID,
                                       result: .failure(try .init(error))))
            }
            else // request
            {
                guard case .value(let id) = nullableID else
                {
                    throw "Invalid message JSON: Either it's a response with no error and no result, or it's a request/notification with a <null> id"
                }
                
                self = try .request(.init(id: id,
                                          method: json.string("method"),
                                          params: json.params))
            }
        }
        
        private static func getID(fromMessage message: JSON) -> NullableID?
        {
            guard let idJSON = message.id else { return nil }
            
            switch idJSON {
            case .null: return .null
            case .int(let int): return .value(.int(int))
            case .string(let string): return .value(.string(string))
            default: return nil
            }
        }
        
        public func packet() throws -> Data
        {
            try LSP.makePacket(withMessageData: data())
        }
        
        public func data() throws -> Data
        {
            try json().data()
        }
        
        public func json() -> JSON
        {
            var dictionary: [String : JSON] = ["jsonrpc": .string("2.0")]
            
            switch self
            {
            case .request(let request):
                dictionary["id"] = request.id.json
                dictionary["method"] = .string(request.method)
                dictionary["params"] = request.params
            case .response(let response):
                dictionary["id"] = response.id.json
                switch response.result
                {
                case .success(let resultJSON):
                    dictionary["result"] = resultJSON
                case .failure(let error):
                    dictionary["error"] = error.json()
                }
            case .notification(let notification):
                dictionary["method"] = .string(notification.method)
                dictionary["params"] = notification.params
            }
            
            return .dictionary(dictionary)
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
                init(_ error: JSON) throws
                {
                    self.code = try error.int("code")
                    self.message = try error.string("message")
                    data = error["data"]
                }
                
                func json() -> JSON
                {
                    var dictionary: [String : JSON] =
                        [
                            "code": .int(code),
                            "message": .string(message)
                        ]
                    
                    dictionary["data"] = data
                    
                    return .dictionary(dictionary)
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
            public init(id: ID = ID(), method: String, params: JSON?)
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
                case .null: return .null
                }
            }
            
            case value(ID), null
        }
        
        public enum ID: CustomStringConvertible
        {
            public init() { self = .string(UUID().uuidString) }
            
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
                case .string(let string): return .string(string)
                case .int(let int): return .int(int)
                }
            }
            
            case string(String), int(Int)
        }
    }
    
    public static func makePacket(withMessageData message: Data) -> Data
    {
        let header = "Content-Length: \(message.count)\r\n\r\n".data!
        return header + message
    }
    
    public static func getMessageData(fromPacket packet: Data) throws -> Data
    {
        guard let contentIndex = indexOfContent(in: packet) else
        {
            throw "Invalid LSP Packet"
        }
        
        return packet[contentIndex...]
    }
    
    private static func indexOfContent(in packet: Data) -> Int?
    {
        let separatorLength = 4
        
        guard packet.count > separatorLength else { return nil }
        
        let lastIndex = packet.count - 1
        let lastSearchIndex = lastIndex - separatorLength
        
        for index in 0 ... lastSearchIndex
        {
            if packet[index] == 13,
               packet[index + 1] == 10,
               packet[index + 2] == 13,
               packet[index + 3] == 10
            {
                return index + separatorLength
            }
        }
        
        return nil
    }
}
