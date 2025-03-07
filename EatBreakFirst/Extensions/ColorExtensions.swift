//
//  ColorExtensions.swift
//  EatBreakFirst
//
//  Created on 3/6/25.
//

import SwiftUI

// 颜色扩展，用于从十六进制字符串创建颜色
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
}

// 应用和谐色彩系统
extension Color {
    // 主要类别颜色 - 更和谐的色调
    static let categoryStreak = Color(hex: "3F88C5")      // 优化的蓝色
    static let categoryConsistency = Color(hex: "5CAB7D") // 优化的绿色
    static let categoryMilestone = Color(hex: "F2A65A")   // 优化的橙色
    static let categorySpecial = Color(hex: "A16AE8")     // 优化的紫色
    
    // 进度条颜色
    static let progressBackground = Color(hex: "E5E5E5")  // 统一的进度条背景色
    static let progressForeground = Color(hex: "3F88C5")  // 主要进度条前景色
    
    // 文本颜色
    static let primaryText = Color.primary                // 系统主要文本颜色
    static let secondaryText = Color.secondary            // 系统次要文本颜色
    static let accentText = Color(hex: "3F88C5")          // 强调文本颜色
    
    // 背景颜色
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    
    // 获取类别对应的颜色
    static func forCategory(_ category: AchievementCategory) -> Color {
        switch category {
        case .streak:
            return .categoryStreak
        case .consistency:
            return .categoryConsistency
        case .milestone:
            return .categoryMilestone
        case .special:
            return .categorySpecial
        }
    }
    
    // 获取不同透明度的颜色
    func withOpacity(_ opacity: Double) -> Color {
        return self.opacity(opacity)
    }
}
