//
//  EatBreakfirstWidget.swift
//  EatBreakfirstWidget
//
//  Created by Sheng Ma on 3/7/25.
//

import WidgetKit
import SwiftUI
import AppIntents

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
        
        // 设置下一次更新时间（午夜）
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: Date().addingTimeInterval(86400))
        
        return Timeline(entries: [entry], policy: .after(tomorrow))
    }
    
    // 获取今天的早餐状态
    private func getTodayBreakfastStatus() -> Bool? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let key = "breakfast_\(Int(today.timeIntervalSince1970))"
        
        if BreakfastTracker.shared.object(forKey: key) != nil {
            let status = BreakfastTracker.shared.bool(forKey: key)
            print("Widget: 获取今天的早餐状态，key=\(key), status=\(status)")
            return status
        }
        
        print("Widget: 今天没有记录早餐状态，key=\(key)")
        return nil
    }
    
    // 计算连续天数
    private func calculateStreak() -> Int {
        var streak = 0
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 检查今天是否已记录为已吃
        let todayKey = "breakfast_\(Int(today.timeIntervalSince1970))"
        if BreakfastTracker.shared.bool(forKey: todayKey) {
            streak += 1
            print("Widget: 今天已吃早餐，连续天数 +1")
        } else if BreakfastTracker.shared.object(forKey: todayKey) != nil {
            // 如果今天记录为没吃，则连续天数为0
            print("Widget: 今天没吃早餐，连续天数为0")
            return 0
        }
        
        // 检查之前的连续天数
        var currentDate = today
        while true {
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            let key = "breakfast_\(Int(currentDate.timeIntervalSince1970))"
            
            if BreakfastTracker.shared.bool(forKey: key) {
                streak += 1
                print("Widget: \(calendar.dateComponents([.year, .month, .day], from: currentDate).day ?? 0)日已吃早餐，连续天数 +1")
            } else {
                print("Widget: \(calendar.dateComponents([.year, .month, .day], from: currentDate).day ?? 0)日没有记录或没吃早餐，连续天数计算结束")
                break
            }
        }
        
        print("Widget: 计算连续天数结果：\(streak)")
        return streak
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
    let primaryColor = Color(hex: "3F88C5")      // 主要蓝色 - 匹配 categoryStreak
    let secondaryColor = Color.secondary
    let successColor = Color(hex: "5CAB7D")      // 成功绿色 - 匹配 categoryConsistency
    let warningColor = Color(hex: "F2A65A")      // 警告橙色 - 匹配 categoryMilestone
    let specialColor = Color(hex: "A16AE8")      // 特殊紫色 - 匹配 categorySpecial
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
                            Text("已吃早餐")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(successColor)
                            
                            if entry.streak > 0 {
                                Text("连续 \(entry.streak) 天")
                                    .font(.system(size: 14))
                                    .foregroundColor(successColor.opacity(0.8))
                            }
                        }
                    } else {
                        // 显示提醒信息
                        VStack(spacing: 4) {
                            Text("没吃早餐")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(warningColor)
                            
                            Text("明天要记得吃早饭")
                                .font(.system(size: 14))
                                .foregroundColor(warningColor.opacity(0.8))
                        }
                    }
                }
            } else {
                // 未记录状态 - 显示按钮
                VStack(spacing: 16) {
                    Text("记录今天的早餐")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 16) {
                        // 已吃早餐按钮
                        Button(intent: MarkBreakfastEatenIntent()) {
                            VStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(successColor)
                                
                                Text("已吃")
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
                                
                                Text("没吃")
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

// 颜色扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // 添加应用颜色常量
    static let secondaryText = Color.secondary
    static let categoryStreak = Color(hex: "3F88C5")      // 优化的蓝色
    static let categoryConsistency = Color(hex: "5CAB7D") // 优化的绿色
    static let categoryMilestone = Color(hex: "F2A65A")   // 优化的橙色
    static let categorySpecial = Color(hex: "A16AE8")     // 优化的紫色
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
