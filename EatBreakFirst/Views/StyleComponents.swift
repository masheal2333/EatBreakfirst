//
//  StyleComponents.swift
//  EatBreakFirst
//
//  Created on 3/6/25.
//

import SwiftUI

public struct ScaleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

public struct BackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var sunOffset: CGFloat = 0.2
    @State private var glowOpacity: Double = 0
    @State private var cloudOffset1: CGFloat = -30
    @State private var cloudOffset2: CGFloat = 30
    
    public var body: some View {
        ZStack {
            // Base color that respects light/dark mode
            Color(UIColor.systemBackground)
            
            // Morning sunrise gradient and animation
            GeometryReader { geometry in
                ZStack {
                    // 现代渐变色，参考成功的健康和生活方式应用
                    if colorScheme == .dark {
                        // 深色模式 - 温暖的早餐主题色调，带有治愈感
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "2C2117"),  // 深咖啡色 - 底部（如咖啡）
                                Color(hex: "3D2B1F"),  // 中等烘焙咖啡色 - 中间
                                Color(hex: "4E3629")   // 带点温暖的深棕色 - 顶部（如烤面包）
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    } else {
                        // 浅色模式 - 明亮温暖的早餐主题色调，带有治愈感
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "FFF8E1"),  // 温暖的奶油色 - 底部（如黄油）
                                Color(hex: "FFECB3"),  // 淡黄色 - 中间（如蜂蜜）
                                Color(hex: "FFE0B2")   // 淡橙色 - 顶部（如煎饼）
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    }
                    
                    // 移除断层效果，保持背景色一致
                    
                    // 移除太阳光线波纹效果，保持简洁的背景
                    
                    // 完全移除太阳光晕效果，保持简洁的背景设计
                    
                    // 简洁的云层效果 - 现代极简风格
                    Group {
                        // 第一个蒸汽/早餐香气效果 - 温暖舒适
                        Ellipse()
                            .fill(colorScheme == .dark ? 
                                 Color(hex: "A67C52").opacity(0.08) : // 深色模式下的淡咖啡色（如咖啡蒸汽）
                                 Color(hex: "FFD180").opacity(0.5))   // 浅色模式下的淡橙色（如煎饼香气）
                            .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.12)
                            .position(x: geometry.size.width * 0.7 + cloudOffset1, y: geometry.size.height * 0.25)
                            .blur(radius: 18)
                        
                        // 第二个蒸汽/早餐香气效果 - 温暖舒适
                        Ellipse()
                            .fill(colorScheme == .dark ? 
                                 Color(hex: "8D6E63").opacity(0.06) : // 深色模式下的淡棕色（如烤面包香气）
                                 Color(hex: "FFECB3").opacity(0.4))   // 浅色模式下的淡黄色（如蜂蜜香气）
                            .frame(width: geometry.size.width * 0.45, height: geometry.size.width * 0.14)
                            .position(x: geometry.size.width * 0.25 + cloudOffset2, y: geometry.size.height * 0.18)
                            .blur(radius: 20)
                    }
                }
            }
            .onAppear {
                // 移除所有动画效果
                // 直接设置最终位置，不使用动画
                sunOffset = 0.0
                glowOpacity = 1.0
                cloudOffset1 = 0  // 保持云层在原位置
                cloudOffset2 = 0  // 保持云层在原位置
            }
        }
    }
}
