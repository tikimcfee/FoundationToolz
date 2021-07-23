import Foundation
import SwiftyToolz

public extension URL
{
    func get<Value: Decodable>(_ type: Value.Type = Value.self,
                               handleResult: @escaping (Result<Value, RequestError>) -> Void)
    {
        URLSession.shared.dataTask(with: self)
        {
            data, response, error in
            
            if let error = error
            {
                let nsError = error as NSError
                let isURLError = nsError.domain == URLError.errorDomain
                let urlErrorCode = isURLError ? URLError.Code(rawValue: nsError.code) : nil
                return handleResult(.failure(.receivingResponseFailed(nsError, urlErrorCode)))
            }
            
            let httpResponse = response as! HTTPURLResponse
            
            guard (200 ... 299).contains(httpResponse.statusCode) else
            {
                return handleResult(.failure(.validatingResponseStatusFailed(httpResponse, data)))
            }
                
            guard let data = data else
            {
                return handleResult(.failure(.receivingDataFailed(httpResponse)))
            }
            
            guard let value = Value(data) else
            {
                return handleResult(.failure(.decodingDataFailed(httpResponse, data)))
            }
            
            handleResult(.success(value))
        }
        .resume()
    }
    
    func post<Value: Encodable>(_ value: Value,
                                handleResult: @escaping (Result<Void, RequestError>) -> Void)
    {
        guard let valueData = value.encode() else
        {
            return handleResult(.failure(.encodingDataFailed))
        }
        
        var request = URLRequest(url: self)
        request.httpMethod = "POST"
        request.httpBody = valueData
        
        URLSession.shared.dataTask(with: request)
        {
            data, response, error in
            
            if let error = error
            {
                let nsError = error as NSError
                let isURLError = nsError.domain == URLError.errorDomain
                let urlErrorCode = isURLError ? URLError.Code(rawValue: nsError.code) : nil
                let error = RequestError.receivingResponseFailed(nsError, urlErrorCode)
                return handleResult(.failure(error))
            }
            
            let httpResponse = response as! HTTPURLResponse
            
            guard (200...299).contains(httpResponse.statusCode) else
            {
                let error = RequestError.validatingResponseStatusFailed(httpResponse, data)
                return handleResult(.failure(error))
            }
            
            handleResult(.success(()))
        }
        .resume()
    }
    
    enum RequestError: Error, CustomStringConvertible, CustomDebugStringConvertible
    {
        public var localizedDescription: String { description }
        
        public var debugDescription: String { description }
        
        public var description: String
        {
            switch self
            {
            case .encodingDataFailed:
                return "Could not endecode the data."
            case .receivingResponseFailed(let nsError, let urlErrorCode):
                var message = nsError.localizedDescription
                if let urlErrorCode = urlErrorCode
                {
                    message += " URL error code: \(urlErrorCode.rawValue)"
                }
                return message
            case .receivingDataFailed(let response):
                let status = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
                return "Response has no data. HTTP Status: " + status
            case .decodingDataFailed(let response, _):
                let status = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
                return "Could not decode the data. HTTP Status: " + status
            case .validatingResponseStatusFailed(let response, let data):
                let status = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
                var message = "Unexpected HTTP Status: " + status
                if let dataString = data?.utf8String
                {
                    message += "\nResponse data: " + dataString
                }
                return message
            }
        }
        
        case encodingDataFailed
        case receivingResponseFailed(NSError, URLError.Code?)
        case validatingResponseStatusFailed(HTTPURLResponse, Data?)
        case receivingDataFailed(HTTPURLResponse)
        case decodingDataFailed(HTTPURLResponse, Data)
    }
}
