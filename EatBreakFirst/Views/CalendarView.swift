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
    @State private var slideDirection = SlideDirection.none
    
    // 使用完整的星期几符号，以周一为起始日
    private let weekdaySymbols = ["一", "二", "三", "四", "五", "六", "日"]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter
    }()
    
    public var body: some View {
        VStack(spacing: 10) {
            // Month navigation
            HStack {
                Button(action: { 
                    slideDirection = .right
                    previousMonth() 
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())
                
                Spacer()
                
                Text(dateFormatter.string(from: currentMonth))
                    .font(.headline)
                
                Spacer()
                
                Button(action: { 
                    slideDirection = .left
                    nextMonth() 
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.horizontal)
            
            // Weekday headers
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                        .frame(height: 20)
                }
            }
            
            // Calendar days
            TabView(selection: $currentMonth) {
                ForEach(-1...1, id: \.self) { offset in
                    if let month = getMonth(offset: offset) {
                        CalendarMonthView(
                            month: month,
                            breakfastTracker: breakfastTracker,
                            columns: columns,
                            slideDirection: slideDirection
                        )
                        .tag(month)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 260) // 调整高度以确保完整显示
            .onChange(of: currentMonth) { oldValue, newValue in
                // 当月份变化时，更新滑动方向
                if let oldDate = Calendar.current.dateComponents([.year, .month], from: oldValue).date,
                   let newDate = Calendar.current.dateComponents([.year, .month], from: newValue).date {
                    let comparison = Calendar.current.compare(oldDate, to: newDate, toGranularity: .month)
                    if comparison == .orderedAscending {
                        slideDirection = .left
                    } else if comparison == .orderedDescending {
                        slideDirection = .right
                    }
                }
            }
        }
        .padding()
        .background(Color.primary.opacity(0.03))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
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
    
    private func getMonth(offset: Int) -> Date? {
        return Calendar.current.date(byAdding: .month, value: offset, to: currentMonth)
    }
    
    enum SlideDirection {
        case left, right, none
    }
}

// 日历月份视图
struct CalendarMonthView: View {
    let month: Date
    let breakfastTracker: BreakfastTracker
    let columns: [GridItem]
    let slideDirection: CalendarView.SlideDirection
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(daysInMonth(), id: \.self) { date in
                if let date = date {
                    DayCell(date: date, breakfastTracker: breakfastTracker)
                } else {
                    Color.clear
                        .frame(width: 36, height: 36)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        
        // 创建一个以周一为起始日的日历
        var customCalendar = Calendar.current
        customCalendar.firstWeekday = 2 // 2 表示周一
        
        // 获取月份的第一天
        let components = calendar.dateComponents([.year, .month], from: month)
        guard let firstDayOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return []
        }
        
        // 获取第一天是星期几（1是周日，2是周一，...，7是周六）
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // 计算偏移量，使周一为起始日
        // 如果第一天是周一(2)，偏移量为0
        // 如果第一天是周日(1)，偏移量为6
        let offsetDays = (firstWeekday + 5) % 7
        
        // 创建数组，为月份第一天之前的日期留出空位
        var days = Array(repeating: nil as Date?, count: offsetDays)
        
        // 添加月份中的所有日期
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        // 填充剩余空位，使网格完整
        let remainingDays = 7 - (days.count % 7)
        if remainingDays < 7 {
            days.append(contentsOf: Array(repeating: nil as Date?, count: remainingDays))
        }
        
        // 确保始终有6行（42个单元格），以保持高度一致
        let totalCells = 42 // 6行 × 7列
        if days.count < totalCells {
            days.append(contentsOf: Array(repeating: nil as Date?, count: totalCells - days.count))
        }
        
        return days
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
                .fill(isToday ? Color.categoryStreak.opacity(0.2) : Color.clear)
                .frame(width: 32, height: 32)
            
            Text(dayNumber)
                .font(.footnote)
                .foregroundColor(isToday ? Color.categoryStreak : .primary)
            
            if let hasEaten = breakfastTracker.hasEatenBreakfast(on: date), hasEaten {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.categoryConsistency)
                    .offset(x: 10, y: -10)
            }
        }
        .frame(width: 36, height: 36)
    }
}

// 按钮按压样式
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
