import Foundation

public extension Array where Element == Date
{
    var latest: Date? { self.max(by: <) }
    var earliest: Date? { self.min(by: <) }
}
