//
//  DatePatternFormatter.swift
//  Daybar
//

import Foundation

@MainActor
struct DatePatternFormatter {
    static let defaultPattern = "E h:mm a"
    
    private static let formatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.locale = .autoupdatingCurrent
        fmt.calendar = .autoupdatingCurrent
        fmt.timeZone = .autoupdatingCurrent
        return fmt
    }()
    
    enum Granularity {
        case seconds
        case minutes
        case daily
    }
    
    static func validate(pattern: String) -> Bool {
        let trimmed = pattern.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        
        formatter.dateFormat = pattern
        let formatted = formatter.string(from: Date())
        return !formatted.isEmpty
    }
    
    static func format(date: Date, pattern: String) -> String {
        let activePattern = validate(pattern: pattern) ? pattern : defaultPattern
        formatter.dateFormat = activePattern
        return formatter.string(from: date)
    }
    
    static func granularity(for pattern: String) -> Granularity {
        let activePattern = validate(pattern: pattern) ? pattern : defaultPattern
        let secondFields: Set<Character> = ["s", "S", "A"]
        let minuteFields: Set<Character> = [
            "m", "h", "H", "k", "K",
            "a", "b", "B",
            "z", "Z", "O", "v", "V", "X", "x"
        ]
        let symbols = Array(activePattern)
        var isInsideQuote = false
        var finestGranularity = Granularity.daily
        var index = 0

        while index < symbols.count {
            let symbol = symbols[index]

            if symbol == "'" {
                if index + 1 < symbols.count, symbols[index + 1] == "'" {
                    index += 2
                    continue
                }
                isInsideQuote.toggle()
            } else if !isInsideQuote {
                if secondFields.contains(symbol) {
                    return .seconds
                }
                if minuteFields.contains(symbol) {
                    finestGranularity = .minutes
                }
            }

            index += 1
        }

        return finestGranularity
    }
    
    static func nextUpdateInterval(for pattern: String, from date: Date = Date()) -> TimeInterval {
        let g = granularity(for: pattern)
        let calendar = Calendar.autoupdatingCurrent
        
        switch g {
        case .seconds:
            let nanoseconds = Double(calendar.component(.nanosecond, from: date))
            let secondsFraction = nanoseconds / 1_000_000_000.0
            return max(0.05, 1.0 - secondsFraction)
            
        case .minutes:
            let seconds = Double(calendar.component(.second, from: date))
            let nanoseconds = Double(calendar.component(.nanosecond, from: date))
            let subMinute = seconds + (nanoseconds / 1_000_000_000.0)
            return max(0.1, 60.0 - subMinute)
            
        case .daily:
            if let nextDay = calendar.nextDate(after: date, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) {
                return max(1.0, nextDay.timeIntervalSince(date))
            }
            return 60.0
        }
    }
}
