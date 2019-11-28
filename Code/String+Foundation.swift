import Foundation
import SwiftyToolz

public extension String
{
    init?(with filePath: String)
    {
        do
        {
            self = try String(contentsOfFile: filePath)
        }
        catch
        {
            log(error: error.localizedDescription)
            return nil
        }
    }
    
    var fileName: String
    {
        URL(fileURLWithPath: self).lastPathComponent
    }
    
    var fileExtension: String?
    {
        let parts = components(separatedBy: ".")
        guard let lastPart = parts.last,
            parts.count > 1,
            (1 ... 4).contains(lastPart.count) else { return nil }
        return lastPart
    }
    
    func dateString(fromFormat: String, toFormat: String) -> String
    {
        guard let date = Date(fromString: self, withFormat: fromFormat) else
        {
            return self
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = toFormat
        return formatter.string(from: date)
    }
    
    init(unicode: Int)
    {
        var unicodeCharacter = unichar(unicode)
        
        self = String(utf16CodeUnits: &unicodeCharacter, count: 1)
    }
}
