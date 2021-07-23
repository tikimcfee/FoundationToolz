import Foundation

public extension Int
{
    var stringWithThousandsSeparator: String
    {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "'"
        formatter.numberStyle = .decimal
        
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}
