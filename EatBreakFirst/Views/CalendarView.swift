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
    @State private var refreshID = UUID() // Force view refresh
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var isAnimating = false
    @State private var pageWidth: CGFloat = UIScreen.main.bounds.width - 40 // Default width, will be updated
    
    // 检查当前月份是否是当前日期所在的月份
    private var isCurrentMonthToday: Bool {
        let calendar = Calendar.current
        let currentMonthComponents = calendar.dateComponents([.year, .month], from: currentMonth)
        let todayComponents = calendar.dateComponents([.year, .month], from: Date())
        return currentMonthComponents.year == todayComponents.year && currentMonthComponents.month == todayComponents.month
    }
    
    // 使用完整的星期几符号，以周一为起始日
    private let weekdaySymbols = ["一", "二", "三", "四", "五", "六", "日"]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter
    }()
    
    // Initialize visible months when the view appears
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
                    // 只有当前月不是今天所在的月份时才允许前进到下一个月
                    if !isCurrentMonthToday {
                        slideDirection = .left
                        nextMonth()
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(isCurrentMonthToday ? .gray.opacity(0.4) : .primary)
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
            
            // Calendar days - using a paged approach similar to iOS Calendar
            GeometryReader { geometry in
                ZStack {
                    // Previous month view
                    CalendarMonthView(
                        month: getPreviousMonth(),
                        breakfastTracker: breakfastTracker,
                        columns: columns,
                        slideDirection: .right
                    )
                    .opacity(dragOffset > 0 ? 1 : 0)
                    .offset(x: -pageWidth + dragOffset)
                    
                    // Current month view
                    CalendarMonthView(
                        month: currentMonth,
                        breakfastTracker: breakfastTracker,
                        columns: columns,
                        slideDirection: slideDirection
                    )
                    .id(refreshID) // Force refresh when month changes
                    .offset(x: dragOffset)
                    
                    // Next month view - 只在当前月不是今天所在月时显示
                    if !isCurrentMonthToday {
                        CalendarMonthView(
                            month: getNextMonth(),
                            breakfastTracker: breakfastTracker,
                            columns: columns,
                            slideDirection: .left
                        )
                        .opacity(dragOffset < 0 ? 1 : 0)
                        .offset(x: pageWidth + dragOffset)
                    }
                }
                .onAppear {
                    // Update page width based on actual container size
                    pageWidth = geometry.size.width
                }
            }
            .frame(height: 260) // 调整高度以确保完整显示
            .contentShape(Rectangle())
            .clipped() // Prevent views from showing outside the container
            .gesture(
                DragGesture(minimumDistance: 1, coordinateSpace: .local)
                    .onChanged { value in
                        // Only respond to horizontal drags if not currently animating
                        if abs(value.translation.width) > abs(value.translation.height) && !isAnimating {
                            isDragging = true
                            // Add resistance as we drag further
                            let translation = value.translation.width
                            let resistance: CGFloat = 0.7
                            if translation > 0 {
                                // Dragging right (previous month)
                                dragOffset = translation * resistance
                            } else {
                                // 只有当前月不是今天所在的月份时才允许向左拖动（下一个月）
                                if !isCurrentMonthToday {
                                    dragOffset = translation * resistance
                                } else {
                                    // 如果是当前月，不允许向左拖动，但提供轻微反馈
                                    dragOffset = translation * 0.1 // 很小的阻力，几乎不移动但有反馈
                                }
                            }
                        }
                    }
                    .onEnded { value in
                        let horizontalAmount = value.translation.width
                        let velocity = value.predictedEndTranslation.width / value.translation.width
                        let threshold: CGFloat = pageWidth / 3
                        
                        // Determine if we should change months based on drag distance and velocity
                        let shouldChangePage = abs(horizontalAmount) > threshold || abs(velocity) > 1.5
                        
                        isAnimating = true
                        
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            if horizontalAmount < 0 && shouldChangePage && !isCurrentMonthToday {
                                // 向左滑动 - 下个月
                                slideDirection = .left
                                dragOffset = -pageWidth
                            } else if horizontalAmount > 0 && shouldChangePage {
                                // 向右滑动 - 上个月
                                slideDirection = .right
                                dragOffset = pageWidth
                            } else {
                                // Return to current month
                                dragOffset = 0
                            }
                        }
                        
                        // After animation completes, update the current month if needed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            if dragOffset == -pageWidth {
                                nextMonth(animated: false)
                            } else if dragOffset == pageWidth {
                                previousMonth(animated: false)
                            }
                            
                            // Reset states
                            dragOffset = 0
                            isDragging = false
                            isAnimating = false
                        }
                    }
            )
        }
        .padding()
        .background(Color.primary.opacity(0.03))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func previousMonth(animated: Bool = true) {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            if animated {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentMonth = newDate
                    refreshID = UUID() // Force view refresh
                }
            } else {
                currentMonth = newDate
                refreshID = UUID() // Force view refresh
            }
        }
    }
    
    private func nextMonth(animated: Bool = true) {
        // 检查是否可以前进到下一个月（只能查看过去的月份，不能查看未来）
        let calendar = Calendar.current
        let currentMonthComponents = calendar.dateComponents([.year, .month], from: currentMonth)
        let todayComponents = calendar.dateComponents([.year, .month], from: Date())
        
        // 只有当前显示的月份不是今天所在的月份时，才允许前进到下一个月
        let canAdvance = currentMonthComponents.year! < todayComponents.year! || 
                        (currentMonthComponents.year! == todayComponents.year! && 
                         currentMonthComponents.month! < todayComponents.month!)
        
        if canAdvance, let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            if animated {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentMonth = newDate
                    refreshID = UUID() // Force view refresh
                }
            } else {
                currentMonth = newDate
                refreshID = UUID() // Force view refresh
            }
        }
    }
    
    private func getPreviousMonth() -> Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func getNextMonth() -> Date {
        // 如果当前月已经是今天所在的月份，则不允许获取下一个月
        if isCurrentMonthToday {
            return currentMonth
        }
        return Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
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
        VStack(spacing: 0) {
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        // 检查日期是否属于当前月
                        if isSameMonth(date: date, month: month) {
                            DayCell(date: date, breakfastTracker: breakfastTracker)
                        } else {
                            // 如果不是当前月的日期，显示空白
                            Color.clear
                                .frame(width: 36, height: 36)
                        }
                    } else {
                        Color.clear
                            .frame(width: 36, height: 36)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func daysInMonth() -> [Date?] {
        // 创建一个以周一为起始日的日历
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 2 表示周一
        
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
        
        // 填充剩余空位，使网格完整，但不显示下个月的日期
        let remainingDays = 7 - (days.count % 7)
        if remainingDays < 7 {
            days.append(contentsOf: Array(repeating: nil as Date?, count: remainingDays))
        }
        
        return days
    }
}

// 检查日期是否属于同一个月
fileprivate func isSameMonth(date: Date, month: Date) -> Bool {
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month], from: date)
    let monthComponents = calendar.dateComponents([.year, .month], from: month)
    return dateComponents.year == monthComponents.year && dateComponents.month == monthComponents.month
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
            // 移除选中日期的背景色
            Circle()
                .fill(Color.clear)
                .frame(width: 32, height: 32)
            
            Text(dayNumber)
                .font(.footnote)
            
            if let hasEaten = breakfastTracker.hasEatenBreakfast(on: date), hasEaten {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.categoryConsistency)
                    .offset(x: 0, y: 10)
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
