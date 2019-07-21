import Foundation
import SwiftyToolz

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
            log(error: error.localizedDescription)
            return nil
        }
    }
    
    @discardableResult
    func save(to filePath: String) -> URL?
    {
        return save(to: URL(fileURLWithPath: filePath))
    }
    
    @discardableResult
    func save(to file: URL) -> URL?
    {
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
