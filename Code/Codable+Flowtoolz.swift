import Foundation
import SwiftyToolz

public extension Decodable
{
    init?(fromFilePath filePath: String)
    {
        self.init(from: URL(fileURLWithPath: filePath))
    }
    
    init?(from file: URL?)
    {
        if let decodedSelf = Self(fromJSON: Data(from: file))
        {
            self = decodedSelf
        }
        else
        {
            return nil
        }
    }
    
    init?(fromJSON jsonData: Data?)
    {
        guard let jsonData = jsonData else { return nil }
        
        do
        {
            self = try JSONDecoder().decode(Self.self, from: jsonData)
        }
        catch
        {
            log(error: error.localizedDescription)
            return nil
        }
    }
}

public extension Encodable
{
    @discardableResult
    func save(toFilePath filePath: String) -> URL?
    {
        return encode()?.save(toFilePath: filePath)
    }
    
    @discardableResult
    func save(to file: URL?) -> URL?
    {
        return encode()?.save(to: file)
    }
    
    func encode() -> Data?
    {
        let jsonEncoder = JSONEncoder()
        
        jsonEncoder.outputFormatting = .prettyPrinted
        
        do
        {
            return try jsonEncoder.encode(self)
        }
        catch
        {
            log(error: error.localizedDescription)
            return nil
        }
    }
}
