import Foundation
import SwiftyToolz

public extension FileManager
{
    @discardableResult
    func ensureDirectoryExists(_ dir: URL) -> URL?
    {
        guard !itemExists(dir) else { return dir }
        
        do
        {
            try createDirectory(at: dir, withIntermediateDirectories: true)
            return dir
        }
        catch
        {
            log(error: error.localizedDescription)
            return nil
        }
    }
    
    func removeItems(in directory: URL?) -> Bool
    {
        return remove(items(in: directory))
    }
    
    func items(in directory: URL?) -> [URL]
    {
        guard let directory = directory else { return [] }
        
        do
        {
            return try contentsOfDirectory(at: directory,
                                           includingPropertiesForKeys: nil,
                                           options: [.skipsHiddenFiles])
        }
        catch
        {
            log(error: error.localizedDescription)
            return []
        }
    }
    
    @discardableResult
    func remove(_ items: [URL]) -> Bool
    {
        var didFail = false
        
        items.forEach { if !remove($0) { didFail = true } }
        
        return !didFail
    }
    
    @discardableResult
    func remove(_ item: URL?) -> Bool
    {
        guard let item = item else { return false }
        
        do
        {
            try removeItem(at: item)
            return true
        }
        catch
        {
            log(error: error.localizedDescription)
            return false
        }
    }
    
    func itemExists(_ item: URL) -> Bool
    {
        return fileExists(atPath: item.path)
    }
}
