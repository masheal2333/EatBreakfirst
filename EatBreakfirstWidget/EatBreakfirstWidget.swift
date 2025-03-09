//
//  EatBreakfirstWidget.swift
//  EatBreakfirstWidget
//
//  Created by Sheng Ma on 3/7/25.
//

import WidgetKit
import SwiftUI
import AppIntents
import SwiftData

// 导入本地化管理器
// @_exported import EatBreakFirst

// 简单的本地化函数
func localizedString(_ key: String) -> String {
    // 获取当前系统语言
    let currentLanguage = Locale.current.languageCode
    let isChinese = currentLanguage == "zh"
    
    // 简单的本地化字典
    let localizedStrings: [String: [String: String]] = [
        "widgetHasEatenBreakfast": ["zh": "已吃早餐", "en": "Breakfast Eaten"],
        "widgetStreakDays": ["zh": "连续 %d 天", "en": "%d Day Streak"],
        "widgetNoBreakfast": ["zh": "没吃早餐", "en": "No Breakfast"],
        "widgetRememberTomorrow": ["zh": "明天要记得哟", "en": "Remember Tomorrow"],
        "widgetBreakfastQuestion": ["zh": "今天吃早餐了没?", "en": "Did you eat breakfast today?"],
        "widgetEaten": ["zh": "已吃", "en": "Yes"],
        "widgetNotEaten": ["zh": "没吃", "en": "No"]
    ]
    
    if let translations = localizedStrings[key] {
        return isChinese ? translations["zh"]! : translations["en"]!
    }
    
    return key
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), hasEatenBreakfast: nil, streak: 0)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        // 获取早餐状态和连续天数
        let hasEatenBreakfast = getTodayBreakfastStatus()
        let streak = calculateStreak()
        
        return SimpleEntry(date: Date(), configuration: configuration, hasEatenBreakfast: hasEatenBreakfast, streak: streak)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        print("Widget: 开始生成时间线")
        
        // 执行数据一致性检查，确保小组件数据与应用数据一致
        ensureDataConsistency()
        
        // 强制同步 UserDefaults
        BreakfastTracker.shared.synchronize()
        
        // 获取早餐状态和连续天数
        let hasEatenBreakfast = getTodayBreakfastStatus()
        let streak = calculateStreak()
        
        print("Widget timeline: 早餐状态 = \(hasEatenBreakfast?.description ?? "nil"), 连续天数 = \(streak)")
        
        // 创建当前条目
        let entry = SimpleEntry(
            date: Date(),
            configuration: configuration,
            hasEatenBreakfast: hasEatenBreakfast,
            streak: streak
        )
        
        // 设置下一次更新时间（较短时间，确保能及时更新）
        // 根据当前状态决定更新频率
        let nextUpdateDate: Date
        if hasEatenBreakfast == nil {
            // 如果没有记录，更频繁地检查（5分钟）
            nextUpdateDate = Date().addingTimeInterval(5 * 60)
            print("Widget: 未记录状态，设置5分钟后更新")
        } else {
            // 如果已有记录，可以降低更新频率（15分钟）
            nextUpdateDate = Date().addingTimeInterval(15 * 60)
            print("Widget: 已记录状态，设置15分钟后更新")
        }
        
        print("Widget: 时间线生成完成，下次更新时间: \(nextUpdateDate)")
        return Timeline(entries: [entry], policy: .after(nextUpdateDate))
    }
    
    // 获取今天的早餐状态
    private func getTodayBreakfastStatus() -> Bool? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        print("Widget: 正在获取今天(\(today))的早餐状态")
        
        // 使用与应用相同的数据存储方式和键名
        let userDefaultsKey = "breakfastRecords"
        
        // 强制同步 UserDefaults
        BreakfastTracker.shared.synchronize()
        
        if let data = BreakfastTracker.shared.data(forKey: userDefaultsKey) {
            print("Widget: 从UserDefaults获取到数据")
            let decoder = JSONDecoder()
            if let recordsArray = try? decoder.decode([BreakfastRecord].self, from: data) {
                print("Widget: 成功解码记录数组，共\(recordsArray.count)条记录")
                
                // 查找今天的记录
                let todayTimestamp = today.timeIntervalSince1970
                
                // 打印所有记录的日期，便于调试
                for record in recordsArray {
                    let recordDate = Date(timeIntervalSince1970: record.date)
                    let recordDay = calendar.startOfDay(for: recordDate)
                    print("Widget: 记录日期 = \(recordDay), 状态 = \(record.hasEaten)")
                }
                
                if let todayRecord = recordsArray.first(where: { 
                    let recordDate = Date(timeIntervalSince1970: $0.date)
                    let recordDay = calendar.startOfDay(for: recordDate)
                    let isSameDay = calendar.isDate(recordDay, inSameDayAs: today)
                    print("Widget: 比较日期 \(recordDay) 与今天 \(today): \(isSameDay)")
                    return isSameDay
                }) {
                    print("Widget: 找到今天的早餐记录，状态=\(todayRecord.hasEaten)")
                    return todayRecord.hasEaten
                } else {
                    print("Widget: 未找到今天的早餐记录")
                }
            } else {
                print("Widget: 无法解码从UserDefaults加载的记录数据")
            }
        } else {
            print("Widget: UserDefaults中没有找到breakfastRecords数据")
        }
        
        print("Widget: 今天没有记录早餐状态，返回nil")
        return nil
    }
    
    // 确保小组件数据与应用数据一致，以应用数据为准
    private func ensureDataConsistency() {
        print("Widget: 开始执行数据一致性检查")
        
        // 强制同步 UserDefaults
        BreakfastTracker.shared.synchronize()
        
        // 获取当前小组件显示的状态
        let currentWidgetStatus = getTodayBreakfastStatus()
        print("Widget: 当前小组件状态 = \(currentWidgetStatus?.description ?? "nil")")
        
        // 主动请求更新小组件
        WidgetCenter.shared.reloadAllTimelines()
        print("Widget: 已请求更新小组件以确保数据一致性")
    }
    
    // 计算连续天数
    private func calculateStreak() -> Int {
        var streak = 0
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 从应用的共享数据中加载记录
        if let data = BreakfastTracker.shared.data(forKey: "breakfastRecords") {
            let decoder = JSONDecoder()
            if let recordsArray = try? decoder.decode([BreakfastRecord].self, from: data) {
                // 将记录转换为字典格式以便于查找
                let records = Dictionary(uniqueKeysWithValues: recordsArray.map { 
                    let date = Date(timeIntervalSince1970: $0.date)
                    return (calendar.startOfDay(for: date), $0.hasEaten) 
                })
                
                // 检查今天是否已记录为已吃
                if let hasEatenToday = records[today], hasEatenToday {
                    streak += 1
                    print("Widget: 今天已吃早餐，连续天数 +1")
                } else if records[today] != nil {
                    // 如果今天记录为没吃，则连续天数为0
                    print("Widget: 今天没吃早餐，连续天数为0")
                    return 0
                }
                
                // 检查之前的连续天数
                var currentDate = today
                while true {
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
                    if let hasEaten = records[currentDate], hasEaten {
                        streak += 1
                        print("Widget: \(calendar.dateComponents([.year, .month, .day], from: currentDate).day ?? 0)日已吃早餐，连续天数 +1")
                    } else {
                        print("Widget: \(calendar.dateComponents([.year, .month, .day], from: currentDate).day ?? 0)日没有记录或没吃早餐，连续天数计算结束")
                        break
                    }
                }
            }
        }
        
        print("Widget: 计算连续天数结果：\(streak)")
        return streak
    }
}

// 导入BreakfastRecord模型以便在Widget中使用
struct BreakfastRecord: Codable, Identifiable {
    var id: String { return String(date) }
    let date: TimeInterval
    let hasEaten: Bool
    var note: String? = nil
    
    // 获取日期对象
    var dateObject: Date {
        return Date(timeIntervalSince1970: date)
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
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let hasEatenBreakfast: Bool?
    let streak: Int
    
    // 格式化日期
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: date)
    }
    
    // 获取星期几
    var weekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

struct EatBreakfirstWidgetEntryView : View {
    var entry: Provider.Entry
    
    // 颜色常量 - 匹配应用的颜色方案
    let primaryColor = Color(red: 0.247, green: 0.533, blue: 0.773)      // 主要蓝色 - 匹配 categoryStreak (3F88C5)
    let secondaryColor = Color.secondary
    let successColor = Color(red: 0.361, green: 0.671, blue: 0.49)      // 成功绿色 - 匹配 categoryConsistency (5CAB7D)
    let warningColor = Color(red: 0.949, green: 0.651, blue: 0.353)      // 警告橙色 - 匹配 categoryMilestone (F2A65A)
    let specialColor = Color(red: 0.631, green: 0.416, blue: 0.91)      // 特殊紫色 - 匹配 categorySpecial (A16AE8)
    let backgroundColor = Color(UIColor.secondarySystemBackground)
    
    var body: some View {
        smallWidgetView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor)
    }
    
    // 小尺寸小组件视图
    var smallWidgetView: some View {
        VStack(spacing: 8) {
            Spacer()
            
            // 早餐状态显示
            if let hasEaten = entry.hasEatenBreakfast {
                // 已记录状态
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(hasEaten ? successColor.opacity(0.1) : warningColor.opacity(0.1))
                            .frame(width: 90, height: 90)
                        
                        Image(systemName: hasEaten ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(hasEaten ? successColor : warningColor)
                    }
                    
                    if hasEaten {
                        // 显示连续吃早饭天数
                        VStack(spacing: 4) {
                            Text(localizedString("widgetHasEatenBreakfast"))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            if entry.streak > 0 {
                                Text(String(format: localizedString("widgetStreakDays"), entry.streak))
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    } else {
                        // 显示提醒信息
                        VStack(spacing: 4) {
                            Text(localizedString("widgetNoBreakfast"))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(localizedString("widgetRememberTomorrow"))
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
            } else {
                // 未记录状态 - 显示按钮
                VStack(spacing: 16) {
                    Text(localizedString("widgetBreakfastQuestion"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                    
                    HStack(spacing: 16) {
                        // 已吃早餐按钮
                        Button(intent: MarkBreakfastEatenIntent()) {
                            VStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(successColor)
                                
                                Text(localizedString("widgetEaten"))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(successColor)
                            }
                            .frame(width: 70, height: 70)
                            .background(successColor.opacity(0.1))
                            .cornerRadius(14)
                        }
                        
                        .buttonStyle(ScaleButtonStyle())
                        .contentShape(Rectangle()) // 确保整个区域可点击
                        
                        // 未吃早餐按钮
                        Button(intent: MarkBreakfastSkippedIntent()) {
                            VStack(spacing: 6) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(warningColor)
                                
                                Text(localizedString("widgetNotEaten"))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(warningColor)
                            }
                            .frame(width: 70, height: 70)
                            .background(warningColor.opacity(0.1))
                            .cornerRadius(14)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .contentShape(Rectangle()) // 确保整个区域可点击
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .onAppear {
            print("Widget view appeared: hasEatenBreakfast=\(entry.hasEatenBreakfast?.description ?? "nil"), streak=\(entry.streak)")
        }
    }
}

struct EatBreakfirstWidget: Widget {
    let kind: String = "EatBreakfirstWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            EatBreakfirstWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("早餐记录")
        .description("记录你的早餐习惯，直接从小组件标记今天是否吃了早餐")
        .supportedFamilies([.systemSmall])
    }
}

// 用于预览的示例配置
extension ConfigurationAppIntent {
    fileprivate static var preview: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
}

// Widget专用颜色定义
extension Color {
    // 添加应用颜色常量
    static let secondaryText = Color.secondary
    static let categoryStreak = Color(red: 0.247, green: 0.533, blue: 0.773)      // 优化的蓝色 (3F88C5)
    static let categoryConsistency = Color(red: 0.361, green: 0.671, blue: 0.49) // 优化的绿色 (5CAB7D)
    static let categoryMilestone = Color(red: 0.949, green: 0.651, blue: 0.353)   // 优化的橙色 (F2A65A)
    static let categorySpecial = Color(red: 0.631, green: 0.416, blue: 0.91)     // 优化的紫色 (A16AE8)
}

#Preview(as: .systemSmall) {
    EatBreakfirstWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .preview, hasEatenBreakfast: true, streak: 7)
    SimpleEntry(date: .now, configuration: .preview, hasEatenBreakfast: false, streak: 0)
    SimpleEntry(date: .now, configuration: .preview, hasEatenBreakfast: nil, streak: 3)
}

// 添加按钮样式以匹配应用内的交互效果
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .brightness(configuration.isPressed ? 0.1 : 0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .contentShape(Rectangle()) // 确保整个区域可点击
    }
}
