import Foundation

extension FileManager
{
    @discardableResult
    public func ensureDirectoryExists(_ dir: URL) -> URL?
    {
        guard !fileExists(atPath: dir.path) else { return dir }
        
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
    
    public func files(in directory: URL?) -> [URL]
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
}
