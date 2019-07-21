import Foundation
import SwiftyToolz

public extension Decodable
{
    init?(filePath: String)
    {
        let fileUrl = URL(fileURLWithPath: filePath)
        
        self.init(fileURL: fileUrl)
    }
    
    init?(fileURL: URL?)
    {
        if let decodedSelf = Self(jsonData: Data(fileURL: fileURL))
        {
            self = decodedSelf
        }
        else
        {
            log(error: "\(#function) failed for url: \(fileURL?.absoluteString ?? "nil")")
            return nil
        }
    }
    
    init?(jsonData: Data?)
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
    func save(to filePath: String) -> URL?
    {
        return encode()?.save(to: filePath)
    }
    
    @discardableResult
    func save(to file: URL) -> URL?
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
