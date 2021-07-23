import Foundation

/// Arbitrary Helpers that should probably be simplified/integrated/removed ... accumulated from different projects but not systematic ...

extension Int {
    // MARK: - Get month name from month number
    
    var monthString: String
    {
        monthString(withDateFormat: "MMMM")
    }
    
    var monthStringShort: String
    {
        monthString(withDateFormat: "MMM")
    }
    
    func monthString(withDateFormat format: String) -> String
    {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MM"
        
        let monthNumber = self % 12 == 0 ? 12 : self % 12
        
        if let date = formatter.date(from: "\(monthNumber)")
        {
            formatter.dateFormat = format
            return formatter.string(from: date)
        }
        
        return String(self)
    }
}

extension Date
{
    static func dayFromJSONDateString(_ json: String) -> Date?
    {
        let onlyDayString = json.components(separatedBy: "T")[0]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"//'T'HH:mm:ss.sssz"
        
        guard let date = formatter.date(from: onlyDayString) else
        {
            return nil
        }
        
        return date
    }
    
    func plus(months: Int) -> Date?
    {
        Calendar.current.date(byAdding: .month, value: months, to: self)
    }
    
    func plus(days: Int) -> Date?
    {
        Calendar.current.date(byAdding: .day, value: days, to: self)
    }
    
    func days(since date: Date) -> Int?
    {
        let calendar = Calendar.current
        
        return calendar.dateComponents([.day],
                                       from: calendar.startOfDay(for: date),
                                       to: calendar.startOfDay(for: self)).day
    }
}
