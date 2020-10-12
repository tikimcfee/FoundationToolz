import Foundation
import SwiftyToolz

public extension URL
{
    func get<Value: Decodable>(_ type: Value.Type,
                               handleResult: @escaping (Result<Value, Error>) -> Void)
    {
        URLSession.shared.dataTask(with: self)
        {
            data, response, error in
            
            if let error = error
            {
                return handleResult(.failure(error.localizedDescription))
            }
            
            guard let data = data else
            {
                return handleResult(.failure("Didn't receive any data"))
            }
            
            guard let value = Value(fromJSON: data) else
            {
                return handleResult(.failure("Couldn't decode data as \(Value.self)"))
            }
            
            handleResult(.success(value))
        }
        .resume()
    }
    
    func post<Value: Encodable>(_ value: Value,
                                handleError: @escaping (Error?) -> Void)
    {
        guard let valueData = value.encode() else
        {
            return handleError("Couldn't encode value")
        }
        
        var request = URLRequest(url: self)
        request.httpBody = valueData
        
        URLSession.shared.dataTask(with: request)
        {
            _, _, error in handleError(error?.localizedDescription)
        }
        .resume()
    }
}
