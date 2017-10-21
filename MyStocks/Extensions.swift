import Foundation

extension Date {
    static func getDateFromString(dateString: String) -> Date? {
        let date = Date.getDateFromString(dateString: dateString, formatString: "yyyy-MM-dd HH:mm:ss")
        if date != nil { return date }
        return Date.getDateFromString(dateString: dateString, formatString: "yyyy-MM-dd")
    }
    
    static func getDateFromString(dateString: String, formatString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        return dateFormatter.date(from: dateString)
    }
}
