//
//  CalendarMenuView.swift
//  Daybar
//

import SwiftUI

enum CalendarMonthData {
    struct DayCell: Identifiable {
        var id: Date { date }
        let date: Date
        let dayNumber: Int
        let isCurrentMonth: Bool
        let isToday: Bool
    }
    
    static func generate(for monthDate: Date, calendar: Calendar = .autoupdatingCurrent) -> [DayCell] {
        let today = Date()
        
        // Find start of month
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [DayCell] = []
        var currentDate = firstWeek.start
        
        // Generate 42 days (6 weeks × 7 days)
        for _ in 0..<42 {
            let isCurrentMonth = calendar.isDate(currentDate, equalTo: monthDate, toGranularity: .month)
            let isToday = calendar.isDate(currentDate, inSameDayAs: today)
            let dayNum = calendar.component(.day, from: currentDate)
            
            days.append(DayCell(
                date: currentDate,
                dayNumber: dayNum,
                isCurrentMonth: isCurrentMonth,
                isToday: isToday
            ))
            
            guard let next = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = next
        }
        
        return days
    }
}

struct CalendarMenuView: View {
    static let menuSize = CGSize(width: 190, height: 188)

    @State private var displayedMonth: Date = Date()
    private let calendar = Calendar.autoupdatingCurrent
    
    var body: some View {
        let isShowingCurrentMonth = calendar.isDate(
            displayedMonth,
            equalTo: Date(),
            toGranularity: .month
        )

        VStack(spacing: 5) {
            // Header: Month Year  <  •  >
            HStack(spacing: 0) {
                Text(monthYearString(for: displayedMonth))
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)

                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 18, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Previous Month")

                Button(action: { resetToToday() }) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 5))
                        .foregroundColor(isShowingCurrentMonth ? .secondary : .accentColor)
                        .frame(width: 18, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Return to Today")

                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 18, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Next Month")
            }
            .padding(.leading, 7)
            .padding(.trailing, 3.5)
            
            // Weekday headers
            let weekdaySymbols = reorderedWeekdaySymbols()
            HStack(spacing: 0) {
                ForEach(weekdaySymbols.indices, id: \.self) { index in
                    Text(weekdaySymbols[index].uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // 6 × 7 Days Grid
            let cells = CalendarMonthData.generate(for: displayedMonth, calendar: calendar)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 1) {
                ForEach(cells) { cell in
                    DayCellView(cell: cell)
                }
            }
        }
        .padding(8)
        .frame(width: Self.menuSize.width, height: Self.menuSize.height)
    }
    
    private func changeMonth(by value: Int) {
        if let next = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = next
        }
    }
    
    private func resetToToday() {
        displayedMonth = Date()
    }
    
    private static let monthYearFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.locale = .autoupdatingCurrent
        fmt.calendar = .autoupdatingCurrent
        fmt.dateFormat = "LLLL yyyy"
        return fmt
    }()
    
    private func monthYearString(for date: Date) -> String {
        Self.monthYearFormatter.calendar = calendar
        return Self.monthYearFormatter.string(from: date).capitalized
    }
    
    private func reorderedWeekdaySymbols() -> [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let firstIndex = calendar.firstWeekday - 1
        guard firstIndex >= 0 && firstIndex < symbols.count else { return symbols }
        let firstPart = Array(symbols[firstIndex..<symbols.count])
        let secondPart = Array(symbols[0..<firstIndex])
        return firstPart + secondPart
    }
}

struct DayCellView: View {
    let cell: CalendarMonthData.DayCell
    
    var body: some View {
        ZStack {
            if cell.isToday {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 20, height: 20)
            }
            
            Text("\(cell.dayNumber)")
                .font(.system(size: 11, weight: cell.isToday ? .bold : .regular))
                .foregroundColor(
                    cell.isToday ? .white : (cell.isCurrentMonth ? .primary : Color.secondary.opacity(0.35))
                )
        }
        .frame(height: 20)
    }
}
