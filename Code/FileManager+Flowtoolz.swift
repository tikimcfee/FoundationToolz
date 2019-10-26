import Foundation
import SwiftyToolz

public extension FileManager
{
    @discardableResult
    func ensureDirectoryExists(_ dir: URL) -> URL?
    {
        if itemExists(dir) { return dir }
        
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
        remove(items(in: directory))
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
    
    /**
     Removes items if they exist
     - Returns: `true` if all items were actually removed. `false` if at least one doesn't exist or an error occured.
     **/
    @discardableResult
    func remove(_ items: [URL]) -> Bool
    {
        items.reduce(true) { removedAll, item in removedAll && remove(item) }
    }
    
    /**
     Removes an item if it exists
     - Returns: `true` if the item actually was removed. `false` if it doesn't exist or some error occured.
     **/
    @discardableResult
    func remove(_ item: URL?) -> Bool
    {
        guard let item = item, itemExists(item) else { return false }
        
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
    
    func itemExists(_ item: URL?) -> Bool
    {
        guard let item = item else { return false }
        return fileExists(atPath: item.path)
    }
}
