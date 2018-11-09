import Foundation

public extension Data
{
    init?(filePath: String)
    {
        self.init(fileURL: URL(fileURLWithPath: filePath))
    }
    
    init?(fileURL: URL?)
    {
        guard let fileURL = fileURL else { return nil }
        
        do
        {
            self = try Data(contentsOf: fileURL)
        }
        catch
        {
            return nil
        }
    }
    
    @discardableResult
    func save(to filePath: String) -> URL?
    {
        return save(to: URL(fileURLWithPath: filePath))
    }
    
    @discardableResult
    func save(to fileUrl: URL) -> URL?
    {
        do
        {
            try write(to: fileUrl)
            return fileUrl
        }
        catch
        {
            print(error)
            return nil
        }
    }
    
    var utf8String: String?
    {
        return String(data: self, encoding: .utf8)
    }
}
