import Foundation
import SwiftyToolz

public extension Data
{
    init?(fromFilePath filePath: String)
    {
        self.init(from: URL(fileURLWithPath: filePath))
    }
    
    init?(from file: URL?)
    {
        guard let file = file else { return nil }
        
        do
        {
            self = try Data(contentsOf: file)
        }
        catch
        {
            log(error: error.localizedDescription)
            return nil
        }
    }
    
    @discardableResult
    func save(toFilePath filePath: String) -> URL?
    {
        return save(to: URL(fileURLWithPath: filePath))
    }
    
    @discardableResult
    func save(to file: URL?) -> URL?
    {
        guard let file = file else { return nil }
        
        if FileManager.default.itemExists(file)
        {
            do
            {
                try write(to: file)
                return file
            }
            catch
            {
                log(error: error.localizedDescription)
                return nil
            }
        }
        else
        {
            let didCreateFile = FileManager.default.createFile(atPath: file.path,
                                                               contents: self)
            
            return didCreateFile ? file : nil
        }
    }
    
    var utf8String: String?
    {
        return String(data: self, encoding: .utf8)
    }
}
