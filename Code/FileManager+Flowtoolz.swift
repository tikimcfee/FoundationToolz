import Foundation

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
            print(error.localizedDescription)
            return nil
        }
    }
    
    func itemExists(_ file: URL) -> Bool
    {
        return fileExists(atPath: file.path)
    }
    
    func items(in directory: URL?) -> [URL]
    {
        guard let directory = directory else { return [] }
        
        do
        {
            return try contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        }
        catch
        {
            print(error.localizedDescription)
            return []
        }
    }
    
    @discardableResult
    func remove(item: URL) -> Bool
    {
        do
        {
            try removeItem(at: item)
            return true
        }
        catch
        {
            print(error.localizedDescription)
            return false
        }
    }
}
