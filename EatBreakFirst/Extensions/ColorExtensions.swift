//
//  ColorExtensions.swift
//  EatBreakFirst
//
//  Created on 3/6/25.
//

import SwiftUI

// 颜色扩展，用于从十六进制字符串创建颜色和应用的色彩系统
extension Color {
    // 从十六进制字符串创建颜色的初始化方法
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
    
    // 主要类别颜色 - 采用现代iOS应用的色彩方案，既有活力又保持和谐
    // 支持 Light/Dark 模式的颜色定义
    static var categoryStreak: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(red: 0.04, green: 0.52, blue: 1.0, alpha: 1.0) : // 深色模式下更亮的蓝色 #0A84FF
                UIColor(red: 0.0, green: 0.32, blue: 0.78, alpha: 1.0)  // 浅色模式更深的蓝色 #0052C7
        })
    }
    
    static var categoryConsistency: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(red: 0.19, green: 0.82, blue: 0.35, alpha: 1.0) : // 深色模式下更亮的绿色 #30D158
                UIColor(red: 0.0, green: 0.65, blue: 0.18, alpha: 1.0)  // 浅色模式更深的绿色 #00A62E
        })
    }
    
    static var categoryMilestone: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(red: 1.0, green: 0.62, blue: 0.04, alpha: 1.0) : // 深色模式下更亮的橙色 #FF9F0A
                UIColor(red: 0.85, green: 0.45, blue: 0.0, alpha: 1.0)   // 浅色模式更深的橙色 #D97300
        })
    }
    
    static var categorySpecial: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(red: 0.75, green: 0.35, blue: 0.95, alpha: 1.0) : // 深色模式下更亮的紫色 #BF5AF2
                UIColor(red: 0.53, green: 0.18, blue: 0.72, alpha: 1.0)  // 浅色模式更深的紫色 #872EB8
        })
    }
    
    // 进度条颜色 - 采用微妙的色调变化增强视觉层次
    static var progressBackground: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(red: 0.22, green: 0.22, blue: 0.23, alpha: 1.0) : // 深色模式下更深的背景色 #38383A
                UIColor(red: 0.90, green: 0.90, blue: 0.92, alpha: 1.0)  // 浅色模式背景色 #E5E5EA
        })
    }
    
    static var progressForeground: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(red: 0.04, green: 0.52, blue: 1.0, alpha: 1.0) : // 深色模式下更亮的蓝色 #0A84FF
                UIColor(red: 0.0, green: 0.32, blue: 0.78, alpha: 1.0)  // 浅色模式更深的蓝色 #0052C7
        })
    }
    
    // 文本颜色 - 严格遵循苹果人机界面指南的色彩建议
    static let primaryText = Color.primary                // 系统主要文本颜色
    static let secondaryText = Color.secondary            // 系统次要文本颜色
    static let tertiaryText = Color(UIColor.tertiaryLabel) // 系统第三级文本颜色
    
    static var accentText: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(red: 0.04, green: 0.52, blue: 1.0, alpha: 1.0) : // 深色模式下更亮的蓝色 #0A84FF
                UIColor(red: 0.0, green: 0.32, blue: 0.78, alpha: 1.0)  // 浅色模式更深的蓝色 #0052C7
        })
    }
    
    // 强调色 - 用于特殊元素和重点突出，采用iOS系统色彩
    public static var accentColor: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(red: 0.04, green: 0.52, blue: 1.0, alpha: 1.0) : // 深色模式下更亮的蓝色 #0A84FF
                UIColor(red: 0.0, green: 0.32, blue: 0.78, alpha: 1.0)  // 浅色模式更深的蓝色 #0052C7
        })
    }
    
    static var successColor: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(red: 0.19, green: 0.82, blue: 0.35, alpha: 1.0) : // 深色模式下更亮的绿色 #30D158
                UIColor(red: 0.0, green: 0.65, blue: 0.18, alpha: 1.0)  // 浅色模式更深的绿色 #00A62E
        })
    }
    
    static var warningColor: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(red: 1.0, green: 0.62, blue: 0.04, alpha: 1.0) : // 深色模式下更亮的橙色 #FF9F0A
                UIColor(red: 0.85, green: 0.45, blue: 0.0, alpha: 1.0)   // 浅色模式更深的橙色 #D97300
        })
    }
    
    static var errorColor: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(red: 1.0, green: 0.27, blue: 0.23, alpha: 1.0) : // 深色模式下更亮的红色 #FF453A
                UIColor(red: 0.75, green: 0.10, blue: 0.10, alpha: 1.0)  // 浅色模式更深的红色 #C01919
        })
    }
    
    // 背景颜色
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    static let groupedBackground = Color(UIColor.systemGroupedBackground)
    
    // 阴影颜色
    static var shadowColor: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.25) : // 深色模式下更强的阴影
                UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.15)  // 浅色模式阴影
        })
    }
    
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
