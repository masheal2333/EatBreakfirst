//
//  ContentView.swift
//  EatBreakFirst
//
//  Created by Sheng Ma on 3/6/25.
//

import SwiftUI

// Codable struct for breakfast records
struct BreakfastRecord: Codable {
    let date: TimeInterval
    let hasEaten: Bool
}

// Model to track breakfast records
class BreakfastTracker: ObservableObject {
    @Published var records: [Date: Bool] = [:]
    @Published var streakCount: Int = 0
    
    private let userDefaultsKey = "breakfastRecords"
    
    init() {
        loadRecords()
        calculateStreak()
    }
    
    func recordBreakfast(eaten: Bool, for date: Date = Date()) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        if let normalizedDate = calendar.date(from: components) {
            records[normalizedDate] = eaten
            saveRecords()
            calculateStreak()
        }
    }
    
    func hasEatenBreakfast(on date: Date) -> Bool? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        if let normalizedDate = calendar.date(from: components) {
            return records[normalizedDate]
        }
        return nil
    }
    
    func calculateStreak() {
        let calendar = Calendar.current
        var currentDate = Date()
        var streak = 0
        
        // Check if today is already recorded as eaten
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        if let today = calendar.date(from: todayComponents), let hasEatenToday = records[today], hasEatenToday {
            streak += 1
        }
        
        // Count consecutive days before today
        var dayBefore = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        while true {
            let components = calendar.dateComponents([.year, .month, .day], from: dayBefore)
            if let date = calendar.date(from: components), let hasEaten = records[date], hasEaten {
                streak += 1
                dayBefore = calendar.date(byAdding: .day, value: -1, to: dayBefore)!
            } else {
                break
            }
        }
        
        streakCount = streak
    }
    
    private func saveRecords() {
        let encoder = JSONEncoder()
        let recordsArray = records.map { BreakfastRecord(date: $0.key.timeIntervalSince1970, hasEaten: $0.value) }
        if let encoded = try? encoder.encode(recordsArray) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            let decoder = JSONDecoder()
            if let recordsArray = try? decoder.decode([BreakfastRecord].self, from: data) {
                records = Dictionary(uniqueKeysWithValues: recordsArray.map { 
                    (Date(timeIntervalSince1970: $0.date), $0.hasEaten) 
                })
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var breakfastTracker = BreakfastTracker()
    @State private var hasEatenBreakfast: Bool? = nil
    @State private var showConfetti = false
    @State private var showCalendar = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    if hasEatenBreakfast == nil {
                        // Question View
                        VStack(spacing: 30) {
                            Text("今天早上吃了早餐吗？")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 5) {
                                Image(systemName: "bread.fill")
                                    .renderingMode(.original)
                                    .foregroundStyle(.orange, .yellow)
                                    .font(.system(size: 120))
                                    .symbolEffect(.pulse)
                                
                                Text("🥐 🍞 🥖")
                                    .font(.system(size: 40))
                            }
                            .padding(.bottom, 20)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    hasEatenBreakfast = true
                                    showConfetti = true
                                    breakfastTracker.recordBreakfast(eaten: true)
                                }
                            }) {
                                Label {
                                    Text("吃了")
                                        .font(.headline)
                                } icon: {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: Color.accentColor.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    hasEatenBreakfast = false
                                    breakfastTracker.recordBreakfast(eaten: false)
                                }
                            }) {
                                Label {
                                    Text("没吃")
                                        .font(.headline)
                                } icon: {
                                    Image(systemName: "x.circle.fill")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(UIColor.secondarySystemBackground))
                                .foregroundColor(.primary)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        .padding(.horizontal, 30)
                    } else if hasEatenBreakfast == true {
                        // Success View
                        VStack(spacing: 30) {
                            // Streak counter
                            VStack(spacing: 5) {
                                Text("连续 \(breakfastTracker.streakCount) 天吃了早饭")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.accentColor.opacity(0.1))
                                    )
                            }
                            .padding(.bottom, 10)
                            
                            HStack(spacing: 25) {
                                Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .font(.system(size: 70))
                                
                                Image(systemName: "face.smiling.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .foregroundStyle(.yellow)
                                    .font(.system(size: 70))
                                    .symbolEffect(.bounce, options: .repeating)
                            }
                            
                            Text("恭喜你！")
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("保持健康的早餐习惯")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            // Calendar view
                            CalendarView(breakfastTracker: breakfastTracker)
                                .frame(height: 280)
                                .padding(.top, 10)
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        hasEatenBreakfast = nil
                                        showConfetti = false
                                    }
                                }) {
                                    Text("返回")
                                        .font(.headline)
                                        .frame(width: 120)
                                        .padding(.vertical, 14)
                                        .background(Color(UIColor.tertiarySystemBackground))
                                        .foregroundColor(.primary)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                            .padding(.top, 10)
                        }
                        .padding(.horizontal)
                    } else {
                        // Reminder View
                        VStack(spacing: 30) {
                            HStack(spacing: 25) {
                                Image(systemName: "clock.badge.exclamationmark.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .font(.system(size: 70))
                                    .symbolEffect(.pulse)
                                
                                Image(systemName: "carrot.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .foregroundStyle(.orange)
                                    .font(.system(size: 70))
                            }
                            
                            Text("明天要记得吃早饭")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("健康的一天从早餐开始")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    hasEatenBreakfast = nil
                                }
                            }) {
                                Text("返回")
                                    .font(.headline)
                                    .frame(width: 120)
                                    .padding(.vertical, 14)
                                    .background(Color(UIColor.tertiarySystemBackground))
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .padding(.top, 20)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding()
                
                if showConfetti {
                    ConfettiView()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ConfettiView: View {
    @State private var confettiPieces = [ConfettiPiece]()
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                Circle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
                    .position(piece.position)
                    .opacity(piece.opacity)
            }
        }
        .onAppear {
            generateConfetti()
        }
        .onReceive(timer) { _ in
            updateConfetti()
        }
    }
    
    func generateConfetti() {
        for _ in 0..<100 {
            let randomX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
            let randomY = CGFloat.random(in: 0...100)
            let randomSize = CGFloat.random(in: 5...15)
            let randomColor = colors.randomElement() ?? .red
            let randomVelocity = CGFloat.random(in: 2...5)
            let randomRotationSpeed = CGFloat.random(in: -0.1...0.1)
            
            let piece = ConfettiPiece(
                position: CGPoint(x: randomX, y: randomY),
                size: randomSize,
                color: randomColor,
                velocity: randomVelocity,
                rotationSpeed: randomRotationSpeed
            )
            confettiPieces.append(piece)
        }
    }
    
    func updateConfetti() {
        for i in 0..<confettiPieces.count {
            if i < confettiPieces.count {
                var piece = confettiPieces[i]
                piece.position.y += piece.velocity
                piece.rotation += piece.rotationSpeed
                
                if piece.position.y > UIScreen.main.bounds.height {
                    piece.opacity -= 0.02
                }
                
                confettiPieces[i] = piece
                
                if piece.opacity <= 0 {
                    confettiPieces.remove(at: i)
                }
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var velocity: CGFloat
    var rotation: CGFloat = 0
    var rotationSpeed: CGFloat
    var opacity: CGFloat = 1.0
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct BackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Base color that respects light/dark mode
            Color(UIColor.systemBackground)
            
            // Subtle gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.18) : Color(red: 0.95, green: 0.95, blue: 0.97),
                    colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Subtle pattern overlay
            GeometryReader { geometry in
                ZStack {
                    // Top decorative element
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: geometry.size.width * 0.7)
                        .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.1)
                        .blur(radius: 60)
                    
                    // Bottom decorative element
                    Circle()
                        .fill(Color.accentColor.opacity(0.08))
                        .frame(width: geometry.size.width * 0.6)
                        .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.85)
                        .blur(radius: 60)
                }
            }
        }
    }
}

// Calendar view for tracking breakfast habits
struct CalendarView: View {
    @ObservedObject var breakfastTracker: BreakfastTracker
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    @State private var currentMonth = Date()
    
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter
    }()
    
    var body: some View {
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
struct DayCell: View {
    let date: Date
    @ObservedObject var breakfastTracker: BreakfastTracker
    
    private var dayNumber: String {
        let day = Calendar.current.component(.day, from: date)
        return String(day)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
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

#Preview {
    ContentView()
}
