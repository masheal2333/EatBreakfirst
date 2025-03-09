//
//  LocalizedStringKey.swift
//  EatBreakFirst
//
//  Created on 3/9/25.
//

import Foundation

// 本地化字符串键
enum LocalizedStringKey {
    // 通用
    case appName
    
    // 主界面
    case eatBreakfastQuestion
    case alreadyRecorded
    case comeBackTomorrow
    case congratulations
    case streakCount(Int)
    case recordedToday
    case clearTodayRecord
    
    // 提醒相关
    case rememberTomorrow
    case healthyDayStart
    case setBreakfastReminder
    case dailyReminder(String)
    case selectReminderTime
    case cancel
    case confirm
    
    // 设置
    case language
    case switchLanguage
    
    // 成就和统计
    case statistics
    case achievements
    case unlockProgress
    case breakfastDataOverview
    case breakfastDays
    case skippedBreakfast
    case currentStreak
    case longestRecord
    case completionRate
    case weeklyTrend
    case showDetails
    case hideDetails
    
    // 统计页面额外文本
    case recentRecord
    case allRecord
    case daysUnit
    case percentUnit
    case bestPerformance
    case needImprovement
    case weeklyAverageBreakfast
    case needEffortToImprove
    case roomForImprovement
    case averagePerformance
    case goodPerformance
    case excellentPerformance
    
    // 成就页面额外文本
    case unlocked
    case daysRequired
    case achievementUnlocked
    case shareAchievement
    case achievementDetails
    case howToGet
    case consecutiveDaysRequired
    case unlockInfo
    case unlockTime
    case congratsMessage
    case achievementTips
    case notUnlocked
    case currentProgress
    case unlockTimeDetail
    case achievementTipsText
    case achievementCongratsText
    
    // 提醒设置页面
    case reminderSettings
    case done
    case needNotificationPermission
    case goToSettings
    case notificationPermissionMessage
    case allowNotifications
    case allowButton
    case notificationExplanationMessage
    case testNotificationSent
    case reminderTime
    case dailyReminderTime
    case enableBreakfastReminder
    case aboutBreakfastReminder
    case reminderExplanation
    case reminderPreview
    case reminderTitle
    case reminderBody
    case testNotification
    case testNotificationTitle
    case testNotificationBody
    
    // 小组件文本
    case widgetHasEatenBreakfast
    case widgetStreakDays
    case widgetNoBreakfast
    case widgetRememberTomorrow
    case widgetBreakfastQuestion
    case widgetEaten
    case widgetNotEaten
    
    // 应用版本
    case appVersion
    
    // 获取中文值
    var chineseValue: String {
        switch self {
        // 通用
        case .appName:
            return "早餐打卡"
            
        // 主界面
        case .eatBreakfastQuestion:
            return "今天吃了早餐吗？"
        case .alreadyRecorded:
            return "今天已经记录了早餐状态"
        case .comeBackTomorrow:
            return "请明天凌晨 12:00 后再来记录"
        case .congratulations:
            return "牛哇牛哇！"
        case .streakCount(let count):
            return "连续 \(count) 天吃了早饭"
        case .recordedToday:
            return "今天已记录，明天再来"
        case .clearTodayRecord:
            return "清除今天的记录"
            
        // 提醒相关
        case .rememberTomorrow:
            return "明天要记得吃早饭"
        case .healthyDayStart:
            return "健康的一天从早餐开始"
        case .setBreakfastReminder:
            return "设置早餐提醒"
        case .dailyReminder(let time):
            return "每天 \(time)"
        case .selectReminderTime:
            return "设置早餐提醒时间"
        case .cancel:
            return "取消"
        case .confirm:
            return "确定"
            
        // 设置
        case .language:
            return "语言"
        case .switchLanguage:
            return "切换语言"
            
        // 成就和统计
        case .statistics:
            return "统计"
        case .achievements:
            return "成就"
        case .unlockProgress:
            return "解锁进度"
        case .breakfastDataOverview:
            return "早餐数据概览"
        case .breakfastDays:
            return "早餐天数"
        case .skippedBreakfast:
            return "未吃早餐"
        case .currentStreak:
            return "当前连续"
        case .longestRecord:
            return "最长纪录"
        case .completionRate:
            return "早餐完成率"
        case .weeklyTrend:
            return "早餐习惯洞察"
        case .showDetails:
            return "显示详情"
        case .hideDetails:
            return "隐藏详情"
            
        // 统计页面额外文本
        case .recentRecord:
            return "近期记录"
        case .allRecord:
            return "全部记录"
        case .daysUnit:
            return "天"
        case .percentUnit:
            return "%"
        case .bestPerformance:
            return "最佳表现"
        case .needImprovement:
            return "需要改进"
        case .weeklyAverageBreakfast:
            return "平均每周早餐天数"
        case .needEffortToImprove:
            return "需要努力提升"
        case .roomForImprovement:
            return "有待改进"
        case .averagePerformance:
            return "表现一般"
        case .goodPerformance:
            return "表现不错"
        case .excellentPerformance:
            return "非常出色"
            
        // 成就页面额外文本
        case .unlocked:
            return "已解锁"
        case .daysRequired:
            return "天"
        case .achievementUnlocked:
            return "成就解锁！"
        case .shareAchievement:
            return "分享成就"
        case .achievementDetails:
            return "成就详情"
        case .howToGet:
            return "如何获得"
        case .consecutiveDaysRequired:
            return "连续%d天记录早餐"
        case .unlockInfo:
            return "解锁信息"
        case .unlockTime:
            return "解锁时间: %@"
        case .congratsMessage:
            return "恭喜你!"
        case .achievementTips:
            return "小贴士"
        case .notUnlocked:
            return "未解锁 • 需连续%d天"
        case .currentProgress:
            return "当前进度"
        case .unlockTimeDetail:
            return "解锁时间: %@"
        case .achievementTipsText:
            return "每天吃早餐对健康非常重要，坚持记录并养成良好的早餐习惯。"
        case .achievementCongratsText:
            return "你已经成功解锁了这个成就，继续保持良好的早餐习惯吧！"
            
        // 提醒设置页面
        case .reminderSettings:
            return "早餐提醒设置"
        case .done:
            return "完成"
        case .needNotificationPermission:
            return "需要通知权限"
        case .goToSettings:
            return "去设置"
        case .notificationPermissionMessage:
            return "要接收早餐提醒，请在设置中允许通知权限。"
        case .allowNotifications:
            return "允许发送通知"
        case .allowButton:
            return "允许"
        case .notificationExplanationMessage:
            return "我们需要发送通知来提醒您吃早餐。这将帮助您养成健康的早餐习惯。"
        case .testNotificationSent:
            return "测试通知已发送，请等待5秒"
        case .reminderTime:
            return "提醒时间"
        case .dailyReminderTime:
            return "每天 %@ 提醒您吃早餐"
        case .enableBreakfastReminder:
            return "启用早餐提醒"
        case .aboutBreakfastReminder:
            return "关于早餐提醒"
        case .reminderExplanation:
            return "每天按时吃早餐有助于建立健康的生活习惯。我们会在您设定的时间发送提醒，帮助您坚持这个好习惯。"
        case .reminderPreview:
            return "提醒内容预览"
        case .reminderTitle:
            return "该吃早餐啦！🍳"
        case .reminderBody:
            return "早上好！记得吃早餐，健康的一天从现在开始。不要错过今天的能量补充！"
        case .testNotification:
            return "测试通知"
        case .testNotificationTitle:
            return "测试通知 - 该吃早餐啦！🍳"
        case .testNotificationBody:
            return "这是一条测试通知。实际提醒将在每天 %@ 发送。"
            
        // 小组件文本
        case .widgetHasEatenBreakfast:
            return "已吃早餐"
        case .widgetStreakDays:
            return "连续 %d 天"
        case .widgetNoBreakfast:
            return "没吃早餐"
        case .widgetRememberTomorrow:
            return "明天要记得哟"
        case .widgetBreakfastQuestion:
            return "今天吃早餐了没?"
        case .widgetEaten:
            return "已吃"
        case .widgetNotEaten:
            return "没吃"
            
        // 应用版本
        case .appVersion:
            return "EatBreakFirst v1.0"
        }
    }
    
    // 获取英文值
    var englishValue: String {
        switch self {
        // 通用
        case .appName:
            return "Breakfast Check-in"
            
        // 主界面
        case .eatBreakfastQuestion:
            return "Did you eat breakfast today?"
        case .alreadyRecorded:
            return "You've already recorded your breakfast status today"
        case .comeBackTomorrow:
            return "Please come back after 12:00 AM tomorrow"
        case .congratulations:
            return "Awesome!"
        case .streakCount(let count):
            return "\(count) day streak of eating breakfast"
        case .recordedToday:
            return "Recorded today, come back tomorrow"
        case .clearTodayRecord:
            return "Clear today's record"
            
        // 提醒相关
        case .rememberTomorrow:
            return "Remember to eat breakfast tomorrow"
        case .healthyDayStart:
            return "A healthy day starts with breakfast"
        case .setBreakfastReminder:
            return "Set Breakfast Reminder"
        case .dailyReminder(let time):
            return "Daily at \(time)"
        case .selectReminderTime:
            return "Set Breakfast Reminder Time"
        case .cancel:
            return "Cancel"
        case .confirm:
            return "Confirm"
            
        // 设置
        case .language:
            return "Language"
        case .switchLanguage:
            return "Switch Language"
            
        // 成就和统计
        case .statistics:
            return "Statistics"
        case .achievements:
            return "Achievements"
        case .unlockProgress:
            return "Unlock Progress"
        case .breakfastDataOverview:
            return "Breakfast Data Overview"
        case .breakfastDays:
            return "Breakfast Days"
        case .skippedBreakfast:
            return "Skipped Breakfast"
        case .currentStreak:
            return "Current Streak"
        case .longestRecord:
            return "Longest Record"
        case .completionRate:
            return "Completion Rate"
        case .weeklyTrend:
            return "Weekly Trend"
        case .showDetails:
            return "Show Details"
        case .hideDetails:
            return "Hide Details"
            
        // 统计页面额外文本
        case .recentRecord:
            return "Recent Record"
        case .allRecord:
            return "All Records"
        case .daysUnit:
            return "days"
        case .percentUnit:
            return "%"
        case .bestPerformance:
            return "Best Performance"
        case .needImprovement:
            return "Needs Improvement"
        case .weeklyAverageBreakfast:
            return "Weekly Average Breakfast"
        case .needEffortToImprove:
            return "Needs Effort to Improve"
        case .roomForImprovement:
            return "Room for Improvement"
        case .averagePerformance:
            return "Average Performance"
        case .goodPerformance:
            return "Good Performance"
        case .excellentPerformance:
            return "Excellent Performance"
            
        // 成就页面额外文本
        case .unlocked:
            return "Unlocked"
        case .daysRequired:
            return "days"
        case .achievementUnlocked:
            return "Achievement Unlocked!"
        case .shareAchievement:
            return "Share Achievement"
        case .achievementDetails:
            return "Achievement Details"
        case .howToGet:
            return "How to Get"
        case .consecutiveDaysRequired:
            return "Record breakfast for %d consecutive days"
        case .unlockInfo:
            return "Unlock Information"
        case .unlockTime:
            return "Unlocked on: %@"
        case .congratsMessage:
            return "Congratulations!"
        case .achievementTips:
            return "Tips"
        case .notUnlocked:
            return "Not Unlocked • Need %d days"
        case .currentProgress:
            return "Current Progress"
        case .unlockTimeDetail:
            return "Unlocked on: %@"
        case .achievementTipsText:
            return "Eating breakfast daily is important for your health. Keep recording and develop good breakfast habits."
        case .achievementCongratsText:
            return "You've successfully unlocked this achievement. Keep up the good breakfast habits!"
            
        // 提醒设置页面
        case .reminderSettings:
            return "Breakfast Reminder Settings"
        case .done:
            return "Done"
        case .needNotificationPermission:
            return "Notification Permission Required"
        case .goToSettings:
            return "Go to Settings"
        case .notificationPermissionMessage:
            return "To receive breakfast reminders, please allow notifications in settings."
        case .allowNotifications:
            return "Allow Notifications"
        case .allowButton:
            return "Allow"
        case .notificationExplanationMessage:
            return "We need to send notifications to remind you about breakfast. This will help you develop healthy breakfast habits."
        case .testNotificationSent:
            return "Test notification sent, please wait 5 seconds"
        case .reminderTime:
            return "Reminder Time"
        case .dailyReminderTime:
            return "Daily reminder at %@ for breakfast"
        case .enableBreakfastReminder:
            return "Enable Breakfast Reminder"
        case .aboutBreakfastReminder:
            return "About Breakfast Reminders"
        case .reminderExplanation:
            return "Eating breakfast on time every day helps establish healthy living habits. We'll send reminders at your set time to help you maintain this good habit."
        case .reminderPreview:
            return "Reminder Preview"
        case .reminderTitle:
            return "Time for breakfast! 🍳"
        case .reminderBody:
            return "Good morning! Remember to eat breakfast. A healthy day starts now. Don't miss your energy boost today!"
        case .testNotification:
            return "Test Notification"
        case .testNotificationTitle:
            return "Test Notification - Time for breakfast! 🍳"
        case .testNotificationBody:
            return "This is a test notification. Actual reminders will be sent daily at %@."
            
        // 小组件文本
        case .widgetHasEatenBreakfast:
            return "Breakfast Eaten"
        case .widgetStreakDays:
            return "%d Day Streak"
        case .widgetNoBreakfast:
            return "No Breakfast"
        case .widgetRememberTomorrow:
            return "Remember Tomorrow"
        case .widgetBreakfastQuestion:
            return "Did you eat breakfast today?"
        case .widgetEaten:
            return "Yes"
        case .widgetNotEaten:
            return "No"
            
        // 应用版本
        case .appVersion:
            return "EatBreakFirst v1.0"
        }
    }
} 