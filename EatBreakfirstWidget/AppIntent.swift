//
//  AppIntent.swift
//  EatBreakfirstWidget
//
//  Created by Sheng Ma on 3/7/25.
//

import WidgetKit
import AppIntents
import SwiftUI

// 小组件配置选项
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "早餐记录小组件配置" }
    static var description: IntentDescription { "配置早餐记录小组件的显示选项" }
    
    // 不再需要配置参数
}

// 标记吃了早餐的意图
struct MarkBreakfastEatenIntent: AppIntent {
    static var title: LocalizedStringResource = "标记已吃早餐"
    static var description = IntentDescription("记录今天已经吃了早餐")
    
    // 添加小组件交互支持
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult {
        print("Widget: MarkBreakfastEatenIntent.perform() 开始执行")
        
        // 使用更简单的方式记录早餐状态
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 直接保存到 UserDefaults
        let key = "breakfast_\(Int(today.timeIntervalSince1970))"
        BreakfastTracker.shared.set(true, forKey: key)
        BreakfastTracker.shared.synchronize()
        
        print("Widget: 已记录今天已吃早餐，key=\(key)")
        
        // 立即更新小组件
        WidgetCenter.shared.reloadAllTimelines()
        print("Widget: 已请求更新所有小组件")
        
        print("Widget: MarkBreakfastEatenIntent.perform() 执行完成")
        return .result()
    }
}

// 标记没吃早餐的意图
struct MarkBreakfastSkippedIntent: AppIntent {
    static var title: LocalizedStringResource = "标记没吃早餐"
    static var description = IntentDescription("记录今天没有吃早餐")
    
    // 添加小组件交互支持
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult {
        print("Widget: MarkBreakfastSkippedIntent.perform() 开始执行")
        
        // 使用更简单的方式记录早餐状态
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 直接保存到 UserDefaults
        let key = "breakfast_\(Int(today.timeIntervalSince1970))"
        BreakfastTracker.shared.set(false, forKey: key)
        BreakfastTracker.shared.synchronize()
        
        print("Widget: 已记录今天没吃早餐，key=\(key)")
        
        // 立即更新小组件
        WidgetCenter.shared.reloadAllTimelines()
        print("Widget: 已请求更新所有小组件")
        
        print("Widget: MarkBreakfastSkippedIntent.perform() 执行完成")
        return .result()
    }
}

// 共享的BreakfastTracker类型，用于与主应用共享数据
struct BreakfastTracker {
    // App Group identifier for sharing data with app
    static let appGroupIdentifier = "group.com.masheal2333.EatBreakFirst"
    
    // Shared UserDefaults for app and widget
    static var shared: UserDefaults {
        let defaults = UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
        print("Widget: 使用 UserDefaults，suiteName=\(appGroupIdentifier)")
        return defaults
    }
    
    // 从小组件记录早餐的静态方法 - 保留但不再使用
    static func recordBreakfastFromWidget(eaten: Bool) {
        // 此方法保留但不再使用
        print("Widget: recordBreakfastFromWidget 方法已弃用")
    }
    
    // 检查并更新成就 - 保留但不再使用
    private static func checkAndUpdateAchievements(eaten: Bool) {
        // 此方法保留但不再使用
        print("Widget: checkAndUpdateAchievements 方法已弃用")
    }
    
    // 检查今天是否已经记录了早餐 - 保留但不再使用
    static func hasEatenBreakfastToday() -> Bool? {
        // 此方法保留但不再使用
        print("Widget: hasEatenBreakfastToday 方法已弃用")
        return nil
    }
    
    // 获取当前连续记录天数 - 保留但不再使用
    static func getCurrentStreak() -> Int {
        // 此方法保留但不再使用
        print("Widget: getCurrentStreak 方法已弃用")
        return 0
    }
}

// 用于记录的数据模型
struct BreakfastRecord: Codable, Identifiable {
    var id: String { return String(date) }
    let date: TimeInterval
    let hasEaten: Bool
}
