import Foundation

extension FileManager
{
    @discardableResult
    public func ensureDirectoryExists(_ dir: URL) -> Bool
    {
        guard !fileExists(atPath: dir.path) else { return true }
        
        do
        {
            try createDirectory(at: dir, withIntermediateDirectories: true)
            return true
        }
        catch
        {
            print(error.localizedDescription)
            return false
        }
    }
}
