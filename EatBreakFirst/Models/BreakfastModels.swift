//
//  BreakfastModels.swift
//  EatBreakFirst
//
//  Created on 3/6/25.
//

import Foundation
import SwiftUI

// Codable struct for breakfast records
struct BreakfastRecord: Codable, Identifiable {
    var id: String { return String(date) }
    let date: TimeInterval
    let hasEaten: Bool
    var note: String? = nil
    
    // 获取日期对象
    var dateObject: Date {
        return Date(timeIntervalSince1970: date)
    }
    
    // 获取格式化的日期字符串
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: dateObject)
    }
    
    // 获取星期几
    var weekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: dateObject)
    }
    
    // 获取简短的星期几
    var shortWeekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: dateObject)
    }
}

// Achievement model
struct Achievement: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let requirement: Int
    var isUnlocked: Bool = false
    var unlockDate: Date? = nil
    var category: AchievementCategory = .streak
    
    // 用于Equatable协议
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        return lhs.id == rhs.id
    }
    
    // 获取成就进度百分比
    func progressPercentage(currentStreak: Int) -> Double {
        guard !isUnlocked else { return 100.0 }
        // 确保进度与日历中的记录逻辑一致
        // 如果当前连续天数为0，返回0
        guard currentStreak > 0 else { return 0.0 }
        let progress = min(Double(currentStreak) / Double(requirement), 1.0)
        return progress * 100.0
    }
    
    // 获取成就颜色
    var color: Color {
        switch category {
        case .streak:
            return Color(hex: "2196F3") // 蓝色
        case .consistency:
            return Color(hex: "4CAF50") // 绿色
        case .milestone:
            return Color(hex: "FF9800") // 橙色
        case .special:
            return Color(hex: "9C27B0") // 紫色
        }
    }
    
    // 获取成就背景渐变
    var gradient: LinearGradient {
        if isUnlocked {
            return LinearGradient(
                gradient: Gradient(colors: [color, color.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// 成就类别
enum AchievementCategory: String, Codable {
    case streak = "连续记录"
    case consistency = "坚持不懈"
    case milestone = "里程碑"
    case special = "特殊成就"
    
    var icon: String {
        switch self {
        case .streak: return "flame.fill"
        case .consistency: return "calendar.badge.clock"
        case .milestone: return "trophy.fill"
        case .special: return "star.fill"
        }
    }
}

// Statistics model
struct BreakfastStats {
    let totalDaysTracked: Int
    let daysEaten: Int
    let daysSkipped: Int
    let currentStreak: Int
    let longestStreak: Int
    let completionRate: Double
    var weekdayStats: [String: Double] = [:]
    var monthlyProgress: [Int: Double] = [:]
    var weeklyRecords: [Date: Bool] = [:]
    var recentCompletionRate: Double = 0.0
    var allTimeCompletionRate: Double = 0.0
    var recentDaysTracked: Int = 0
    var recentDaysEaten: Int = 0
    
    // 获取最常吃早餐的星期
    var bestWeekday: String? {
        return weekdayStats.max(by: { $0.value < $1.value })?.key
    }
    
    // 获取最少吃早餐的星期
    var worstWeekday: String? {
        return weekdayStats.min(by: { $0.value < $1.value })?.key
    }
    
    // 获取平均每周吃早餐的天数
    var weeklyAverage: Double {
        let weeks = Double(totalDaysTracked) / 7.0
        guard weeks > 0 else { return 0 }
        return Double(daysEaten) / weeks
    }
    
    // 获取本月进度与上月比较
    var monthlyImprovement: Double? {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let lastMonth = currentMonth == 1 ? 12 : currentMonth - 1
        
        guard let currentRate = monthlyProgress[currentMonth],
              let lastRate = monthlyProgress[lastMonth] else {
            return nil
        }
        
        return currentRate - lastRate
    }
}


