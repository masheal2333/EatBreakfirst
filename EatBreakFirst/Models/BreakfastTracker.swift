//
//  BreakfastTracker.swift
//  EatBreakFirst
//
//  Created on 3/6/25.
//

import Foundation
import SwiftUI
import UserNotifications

// Model to track breakfast records
class BreakfastTracker: ObservableObject {
    @Published var records: [Date: Bool] = [:]
    @Published var streakCount: Int = 0
    @Published var longestStreak: Int = 0
    @Published var achievements: [Achievement] = []
    @Published var showAchievementUnlocked: Bool = false
    @Published var latestAchievement: Achievement? = nil

    
    private let userDefaultsKey = "breakfastRecords"
    private let longestStreakKey = "longestStreak"

    
    init() {
        loadRecords()
        calculateStreak()
        setupAchievements()

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
        
        // Update longest streak if current streak is longer
        if streak > longestStreak {
            longestStreak = streak
            UserDefaults.standard.set(longestStreak, forKey: longestStreakKey)
            checkAchievements()
        }
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
        
        // Load longest streak
        longestStreak = UserDefaults.standard.integer(forKey: longestStreakKey)
    }
    

    
    // Setup achievements
    private func setupAchievements() {
        achievements = [
            Achievement(name: "第一步", description: "记录你的第一个早餐", icon: "sunrise.fill", requirement: 1),
            Achievement(name: "一周坚持", description: "连续7天吃早餐", icon: "calendar.badge.clock", requirement: 7),
            Achievement(name: "坚持不懈", description: "连续14天吃早餐", icon: "calendar.badge.exclamationmark", requirement: 14),
            Achievement(name: "习惯养成", description: "连续21天吃早餐", icon: "calendar.badge.checkmark", requirement: 21),
            Achievement(name: "生活大师", description: "连续30天吃早餐", icon: "star.fill", requirement: 30)
        ]
        
        checkAchievements()
    }
    
    // Check and update achievements
    private func checkAchievements() {
        let previouslyUnlockedCount = achievements.filter { $0.isUnlocked }.count
        
        // Update achievements based on streak
        for i in 0..<achievements.count {
            if streakCount >= achievements[i].requirement && !achievements[i].isUnlocked {
                achievements[i].isUnlocked = true
                latestAchievement = achievements[i]
                showAchievementUnlocked = true
            }
        }
        
        let newlyUnlockedCount = achievements.filter { $0.isUnlocked }.count
        if newlyUnlockedCount > previouslyUnlockedCount {
            // New achievement unlocked
            // This is handled by setting showAchievementUnlocked to true above
        }
    }
    
    // Calculate statistics
    func calculateStats() -> BreakfastStats {
        let totalDaysTracked = records.count
        let daysEaten = records.filter { $0.value }.count
        let daysSkipped = records.filter { !$0.value }.count
        let completionRate = totalDaysTracked > 0 ? Double(daysEaten) / Double(totalDaysTracked) * 100.0 : 0.0
        
        return BreakfastStats(
            totalDaysTracked: totalDaysTracked,
            daysEaten: daysEaten,
            daysSkipped: daysSkipped,
            currentStreak: streakCount,
            longestStreak: longestStreak,
            completionRate: completionRate
        )
    }
    

}
