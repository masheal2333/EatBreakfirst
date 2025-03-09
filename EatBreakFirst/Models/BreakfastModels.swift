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
    
    // 获取本地化的成就名称
    var localizedName: String {
        let language = UserRoleManager.shared.getCurrentLanguage()
        
        // 根据名称和语言返回对应的本地化文本
        if language == .english {
            switch name {
            case "第一步": return "First Step"
            case "一周坚持": return "One Week Streak"
            case "坚持不懈": return "Persistence"
            case "习惯养成": return "Habit Formation"
            case "生活大师": return "Life Master"
            default: return name
            }
        } else {
            switch name {
            case "First Step": return "第一步"
            case "One Week Streak": return "一周坚持"
            case "Persistence": return "坚持不懈"
            case "Habit Formation": return "习惯养成"
            case "Life Master": return "生活大师"
            default: return name
            }
        }
    }
    
    // 获取本地化的成就描述
    var localizedDescription: String {
        let language = UserRoleManager.shared.getCurrentLanguage()
        
        // 根据描述和语言返回对应的本地化文本
        if language == .english {
            switch description {
            case "记录你的第一个早餐": return "Record your first breakfast"
            case "连续7天吃早餐": return "Eat breakfast for 7 consecutive days"
            case "连续14天吃早餐": return "Eat breakfast for 14 consecutive days"
            case "连续21天吃早餐": return "Eat breakfast for 21 consecutive days"
            case "连续30天吃早餐": return "Eat breakfast for 30 consecutive days"
            default: return description
            }
        } else {
            switch description {
            case "Record your first breakfast": return "记录你的第一个早餐"
            case "Eat breakfast for 7 consecutive days": return "连续7天吃早餐"
            case "Eat breakfast for 14 consecutive days": return "连续14天吃早餐"
            case "Eat breakfast for 21 consecutive days": return "连续21天吃早餐"
            case "Eat breakfast for 30 consecutive days": return "连续30天吃早餐"
            default: return description
            }
        }
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
            return Color.categoryStreak // 使用ColorExtensions中定义的颜色
        case .consistency:
            return Color.categoryConsistency
        case .milestone:
            return Color.categoryMilestone
        case .special:
            return Color.categorySpecial
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
    
    // 添加本地化支持
    var localizedName: String {
        let language = UserRoleManager.shared.getCurrentLanguage()
        
        switch language {
        case .english:
            switch self {
            case .streak: return "Streak"
            case .consistency: return "Consistency"
            case .milestone: return "Milestone"
            case .special: return "Special"
            }
        case .chinese:
            switch self {
            case .streak: return "连续记录"
            case .consistency: return "坚持不懈"
            case .milestone: return "里程碑"
            case .special: return "特殊成就"
            }
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


