//
//  BreakfastTracker.swift
//  EatBreakFirst
//
//  Created on 3/6/25.
//

import Foundation
import SwiftUI
import UserNotifications
import WidgetKit

// Model to track breakfast records
class BreakfastTracker: ObservableObject {
    @Published var records: [Date: Bool] = [:]
    @Published var streakCount: Int = 0
    @Published var longestStreak: Int = 0
    @Published var achievements: [Achievement] = []
    @Published var showAchievementUnlocked: Bool = false
    @Published var latestAchievement: Achievement? = nil
    @Published var isReminderEnabled: Bool = false
    @Published var reminderTime: Date = Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: Date()) ?? Date()
    
    private let userDefaultsKey = "breakfastRecords"
    private let longestStreakKey = "longestStreak"
    private let reminderEnabledKey = "reminderEnabled"
    private let reminderTimeKey = "reminderTime"
    
    // App Group identifier for sharing data with widget
    static let appGroupIdentifier = "group.com.masheal2333.EatBreakFirst"
    
    // Shared UserDefaults for app and widget
    static var shared: UserDefaults {
        return UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
    }

    
    init() {
        loadRecords()
        calculateStreak()
        setupAchievements()
        loadReminderSettings()
        // 确保应用启动时不显示成就弹窗
        showAchievementUnlocked = false
        latestAchievement = nil
        
        // 请求通知权限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知权限已授予")
                // 如果启用了提醒，确保它们被正确设置
                if self.isReminderEnabled {
                    DispatchQueue.main.async {
                        self.scheduleReminder()
                    }
                }
            } else if let error = error {
                print("通知权限请求错误: \(error.localizedDescription)")
            }
        }
    }
    
    func recordBreakfast(eaten: Bool, for date: Date = Date()) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        if let normalizedDate = calendar.date(from: components) {
            records[normalizedDate] = eaten
            saveRecords()
            calculateStreak()
            
            // 只有在用户记录早餐时才显示成就弹窗
            if eaten {
                // 如果用户吃了早餐，检查成就并显示弹窗
                checkAchievements(showPopup: true)
            }
        }
    }
    
    // 更新小组件
    private func updateWidget() {
        #if os(iOS)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
    
    // 从小组件记录早餐的静态方法
    static func recordBreakfastFromWidget(eaten: Bool) {
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: today)
        
        guard let normalizedDate = calendar.date(from: components) else { return }
        
        // 获取现有记录
        var records: [Date: Bool] = [:]
        if let data = shared.data(forKey: "breakfastRecords") {
            let decoder = JSONDecoder()
            if let recordsArray = try? decoder.decode([BreakfastRecord].self, from: data) {
                records = Dictionary(uniqueKeysWithValues: recordsArray.map { 
                    (Date(timeIntervalSince1970: $0.date), $0.hasEaten) 
                })
            }
        }
        
        // 更新今天的记录
        records[normalizedDate] = eaten
        
        // 保存更新后的记录
        let encoder = JSONEncoder()
        let recordsArray = records.map { BreakfastRecord(date: $0.key.timeIntervalSince1970, hasEaten: $0.value) }
        if let encoded = try? encoder.encode(recordsArray) {
            shared.set(encoded, forKey: "breakfastRecords")
        }
        
        // 更新小组件
        #if os(iOS)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
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
            BreakfastTracker.shared.set(longestStreak, forKey: longestStreakKey)
            checkAchievements()
        }
    }
    
    private func saveRecords() {
        let encoder = JSONEncoder()
        let recordsArray = records.map { BreakfastRecord(date: $0.key.timeIntervalSince1970, hasEaten: $0.value) }
        if let encoded = try? encoder.encode(recordsArray) {
            BreakfastTracker.shared.set(encoded, forKey: userDefaultsKey)
            // Update widget
            updateWidget()
        }
    }
    
    private func loadRecords() {
        if let data = BreakfastTracker.shared.data(forKey: userDefaultsKey) {
            let decoder = JSONDecoder()
            if let recordsArray = try? decoder.decode([BreakfastRecord].self, from: data) {
                records = Dictionary(uniqueKeysWithValues: recordsArray.map { 
                    (Date(timeIntervalSince1970: $0.date), $0.hasEaten) 
                })
            }
        }
        
        // Load longest streak
        longestStreak = BreakfastTracker.shared.integer(forKey: longestStreakKey)
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
        
        // 在应用启动时检查成就，但不显示弹窗
        checkAchievements(showPopup: false)
    }
    
    // Check and update achievements
    private func checkAchievements(showPopup: Bool = false) {
        let previouslyUnlockedCount = achievements.filter { $0.isUnlocked }.count
        
        // Update achievements based on streak
        for i in 0..<achievements.count {
            if streakCount >= achievements[i].requirement && !achievements[i].isUnlocked {
                achievements[i].isUnlocked = true
                latestAchievement = achievements[i]
                // 只有当showPopup为true时才显示成就弹窗
                showAchievementUnlocked = showPopup
            }
        }
        
        let newlyUnlockedCount = achievements.filter { $0.isUnlocked }.count
        if newlyUnlockedCount > previouslyUnlockedCount && !showPopup {
            // 新解锁成就，但不显示弹窗
            // 在应用启动时不显示弹窗
        }
    }
    
    // Calculate statistics
    func calculateStats() -> BreakfastStats {
        let totalDaysTracked = records.count
        let daysEaten = records.filter { $0.value }.count
        let daysSkipped = records.filter { !$0.value }.count
        
        // 计算更有意义的完成率
        // 1. 获取最近30天的记录
        let calendar = Calendar.current
        let today = Date()
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today)!
        
        var recentRecords: [Date: Bool] = [:]
        var recentDaysTracked = 0
        var recentDaysEaten = 0
        
        // 遍历最近30天
        for dayOffset in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            if let normalizedDate = calendar.date(from: components) {
                if let hasEaten = records[normalizedDate] {
                    recentRecords[normalizedDate] = hasEaten
                    recentDaysTracked += 1
                    if hasEaten {
                        recentDaysEaten += 1
                    }
                }
            }
        }
        
        // 计算最近30天的完成率，如果记录不足30天，则使用实际记录天数
        let recentCompletionRate = recentDaysTracked > 0 ? 
            Double(recentDaysEaten) / Double(recentDaysTracked) * 100.0 : 0.0
        
        // 计算全部历史的完成率
        let allTimeCompletionRate = totalDaysTracked > 0 ? 
            Double(daysEaten) / Double(totalDaysTracked) * 100.0 : 0.0
        
        // 使用加权平均，最近30天的记录权重更高
        let completionRate = recentDaysTracked > 0 ? 
            (recentCompletionRate * 0.7 + allTimeCompletionRate * 0.3) : allTimeCompletionRate
        
        return BreakfastStats(
            totalDaysTracked: totalDaysTracked,
            daysEaten: daysEaten,
            daysSkipped: daysSkipped,
            currentStreak: streakCount,
            longestStreak: longestStreak,
            completionRate: completionRate,
            weeklyRecords: records,
            recentCompletionRate: recentCompletionRate,
            allTimeCompletionRate: allTimeCompletionRate,
            recentDaysTracked: recentDaysTracked,
            recentDaysEaten: recentDaysEaten
        )
    }
    
    // MARK: - 提醒功能
    
    // 加载提醒设置
    private func loadReminderSettings() {
        isReminderEnabled = BreakfastTracker.shared.bool(forKey: reminderEnabledKey)
        if let savedTime = BreakfastTracker.shared.object(forKey: reminderTimeKey) as? Date {
            reminderTime = savedTime
        }
    }
    
    // 保存提醒设置
    private func saveReminderSettings() {
        BreakfastTracker.shared.set(isReminderEnabled, forKey: reminderEnabledKey)
        BreakfastTracker.shared.set(reminderTime, forKey: reminderTimeKey)
        
        // 更新小组件
        updateWidget()
    }
    
    // 设置或更新提醒
    func setReminder(enabled: Bool, time: Date? = nil) {
        isReminderEnabled = enabled
        
        if let time = time {
            reminderTime = time
        }
        
        saveReminderSettings()
        
        if enabled {
            scheduleReminder()
        } else {
            cancelReminder()
        }
    }
    
    // 安排提醒通知
    func scheduleReminder() {
        // 取消现有提醒
        cancelReminder()
        
        // 只有在启用提醒的情况下才安排新的提醒
        guard isReminderEnabled else { return }
        
        let center = UNUserNotificationCenter.current()
        
        // 检查通知权限
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("通知权限未授予，无法设置提醒")
                return
            }
            
            // 创建通知内容
            let content = UNMutableNotificationContent()
            content.title = "该吃早餐啦！🍳"
            content.body = "早上好！记得吃早餐，健康的一天从现在开始。不要错过今天的能量补充！"
            content.sound = .default
            content.badge = 1
            
            // 添加通知类别，以便用户可以直接从通知中记录早餐状态
            content.categoryIdentifier = "breakfastReminderCategory"
            
            // 设置通知类别和操作
            let eatAction = UNNotificationAction(
                identifier: "EAT_ACTION",
                title: "我已吃早餐",
                options: .foreground
            )
            
            let skipAction = UNNotificationAction(
                identifier: "SKIP_ACTION",
                title: "今天跳过",
                options: .foreground
            )
            
            let category = UNNotificationCategory(
                identifier: "breakfastReminderCategory",
                actions: [eatAction, skipAction],
                intentIdentifiers: [],
                options: []
            )
            
            // 注册通知类别
            center.setNotificationCategories([category])
            
            // 从reminderTime中提取小时和分钟
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: self.reminderTime)
            let minute = calendar.component(.minute, from: self.reminderTime)
            
            // 创建每日触发器
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // 创建请求
            let request = UNNotificationRequest(
                identifier: "breakfastReminder",
                content: content,
                trigger: trigger
            )
            
            // 添加通知请求
            center.add(request) { error in
                if let error = error {
                    print("添加通知请求时出错: \(error.localizedDescription)")
                } else {
                    print("早餐提醒已设置为每天 \(hour):\(minute)")
                    
                    // 调试：打印所有待处理的通知请求
                    center.getPendingNotificationRequests { requests in
                        print("当前待处理的通知请求数量: \(requests.count)")
                        for request in requests {
                            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                                print("通知ID: \(request.identifier), 触发时间: \(trigger.dateComponents)")
                            }
                        }
                    }
                    
                    // 如果当前时间接近设置的提醒时间，立即发送一个测试通知
                    let now = Date()
                    let nowHour = calendar.component(.hour, from: now)
                    let nowMinute = calendar.component(.minute, from: now)
                    
                    // 如果当前时间与设置的提醒时间相差不超过5分钟，发送测试通知
                    if abs(nowHour - hour) * 60 + abs(nowMinute - minute) <= 5 {
                        // 创建一个立即触发的测试通知
                        let testContent = UNMutableNotificationContent()
                        testContent.title = "提醒已设置"
                        testContent.body = "您的早餐提醒已成功设置为每天 \(hour):\(minute)"
                        testContent.sound = .default
                        
                        let testTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                        let testRequest = UNNotificationRequest(
                            identifier: "breakfastReminderTest",
                            content: testContent,
                            trigger: testTrigger
                        )
                        
                        center.add(testRequest) { error in
                            if let error = error {
                                print("添加测试通知请求时出错: \(error.localizedDescription)")
                            } else {
                                print("测试通知已发送")
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 取消提醒通知
    func cancelReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["breakfastReminder"])
        print("早餐提醒已取消")
    }
    
    // 检查今天是否可以选择早餐状态
    func canSelectBreakfastToday() -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: today)
        
        if let normalizedDate = calendar.date(from: components) {
            // 检查今天是否已经记录了早餐状态
            if records[normalizedDate] != nil {
                // 已经记录了，检查是否已经过了午夜
                let now = Date()
                let midnight = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: today)!)
                
                // 如果现在的时间已经过了今天的午夜，则可以再次选择
                return now >= midnight
            }
        }
        
        // 如果今天还没有记录，则可以选择
        return true
    }
    
    // 重置每日选择状态（在午夜调用）
    func resetDailySelection() {
        // 这个方法会在午夜被调用，不需要做任何事情
        // 因为我们的检查逻辑是基于日期的，每天自动更新
        
        // 可以在这里添加任何需要在新的一天开始时执行的逻辑
        print("新的一天开始了，可以再次选择早餐状态")
        
        // 通知观察者状态已重置
        objectWillChange.send()
    }
}
