//
//  CalendarView.swift
//  EatBreakFirst
//
//  Created on 3/6/25.
//

import SwiftUI

// Calendar view for tracking breakfast habits
public struct CalendarView: View {
    @ObservedObject var breakfastTracker: BreakfastTracker
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    @State private var currentMonth = Date()
    
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter
    }()
    
    public var body: some View {
        VStack(spacing: 10) {
            // Month navigation
            HStack {
                Button(action: { previousMonth() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: currentMonth))
                    .font(.headline)
                
                Spacer()
                
                Button(action: { nextMonth() }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            
            // Weekday headers
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(height: 20)
                }
            }
            
            // Calendar days
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(date: date, breakfastTracker: breakfastTracker)
                    } else {
                        Color.clear
                            .frame(height: 35)
                    }
                }
            }
            .frame(height: 210) // Fixed height for 6 rows of calendar cells
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
        .cornerRadius(16)
    }
    
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        
        // Get the first day of the month
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let firstDayOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return []
        }
        
        // Get the weekday of the first day (0 is Sunday in Swift's Calendar)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offsetDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        // Create array with empty slots for days before the first day of month
        var days = Array(repeating: nil as Date?, count: offsetDays)
        
        // Add all days of the month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        // Fill remaining days to complete the grid
        let remainingDays = 7 - (days.count % 7)
        if remainingDays < 7 {
            days.append(contentsOf: Array(repeating: nil as Date?, count: remainingDays))
        }
        
        // Always ensure we have 6 rows (42 cells) for consistent height
        let totalCells = 42 // 6 rows × 7 columns
        if days.count < totalCells {
            days.append(contentsOf: Array(repeating: nil as Date?, count: totalCells - days.count))
        }
        
        return days
    }
    
    private func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            withAnimation {
                currentMonth = newDate
            }
        }
    }
    
    private func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            withAnimation {
                currentMonth = newDate
            }
        }
    }
}

// Individual day cell in the calendar
public struct DayCell: View {
    let date: Date
    @ObservedObject var breakfastTracker: BreakfastTracker
    
    private var dayNumber: String {
        let day = Calendar.current.component(.day, from: date)
        return String(day)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(isToday ? Color.accentColor.opacity(0.2) : Color.clear)
                .frame(width: 35, height: 35)
            
            Text(dayNumber)
                .font(.footnote)
                .foregroundColor(isToday ? .accentColor : .primary)
            
            if let hasEaten = breakfastTracker.hasEatenBreakfast(on: date), hasEaten {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.red)
                    .offset(x: 12, y: -12)
            }
        }
        .frame(height: 35)
    }
}
