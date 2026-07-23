//
//  CalendarMenuView.swift
//  DayBar
//

import SwiftUI

struct CalendarMonthData {
    let monthDate: Date
    let days: [DayCell]
    
    struct DayCell: Identifiable {
        let id = UUID()
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
    @State private var displayedMonth: Date = Date()
    private let calendar = Calendar.autoupdatingCurrent
    
    var body: some View {
        VStack(spacing: 8) {
            // Header: <  Month Year  >
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button(action: { resetToToday() }) {
                    HStack(spacing: 5) {
                        Text(monthYearString(for: displayedMonth))
                            .font(.system(size: 13, weight: .semibold))
                        
                        if !calendar.isDate(displayedMonth, equalTo: Date(), toGranularity: .month) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 5))
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .buttonStyle(.plain)
                .help("Return to Today")
                
                Spacer()
                
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
            .padding(.top, 2)
            
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
            .padding(.vertical, 2)
            
            // 6 × 7 Days Grid
            let cells = CalendarMonthData.generate(for: displayedMonth, calendar: calendar)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 2) {
                ForEach(cells) { cell in
                    DayCellView(cell: cell)
                }
            }
        }
        .padding(10)
        .frame(width: 220)
        .onAppear {
            displayedMonth = Date()
        }
    }
    
    private func changeMonth(by value: Int) {
        if let next = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = next
        }
    }
    
    private func resetToToday() {
        displayedMonth = Date()
    }
    
    private func monthYearString(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = .autoupdatingCurrent
        fmt.calendar = calendar
        fmt.dateFormat = "LLLL yyyy"
        return fmt.string(from: date).capitalized
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
        .frame(height: 22)
    }
}
