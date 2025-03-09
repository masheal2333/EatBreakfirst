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

// 早餐食物图标背景
struct FoodIconsBackground: View {
    let foodSet: [String]
    let colors: [Color]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 创建一个食物图标的网格背景
                ForEach(0..<20) { index in
                    let iconIndex = index % foodSet.count
                    let colorIndex = index % colors.count
                    let size = CGFloat.random(in: 20...40)
                    let x = CGFloat.random(in: 0...geometry.size.width)
                    let y = CGFloat.random(in: 0...geometry.size.height)
                    let opacity = colorScheme == .dark ? 0.15 : 0.3
                    
                    Image(systemName: foodSet[iconIndex])
                        .font(.system(size: size))
                        .foregroundColor(colors[colorIndex])
                        .opacity(opacity)
                        .position(x: x, y: y)
                        .rotationEffect(Angle(degrees: Double.random(in: -20...20)))
                }
            }
        }
    }
}

// 蒸汽效果形状
struct SteamEffect: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // 创建一个波浪形状模拟蒸汽
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        // 左侧曲线
        path.addCurve(
            to: CGPoint(x: rect.midX * 0.5, y: rect.midY),
            control1: CGPoint(x: rect.minX, y: rect.maxY * 0.8),
            control2: CGPoint(x: rect.midX * 0.2, y: rect.maxY * 0.6)
        )
        
        // 中间曲线
        path.addCurve(
            to: CGPoint(x: rect.midX * 1.5, y: rect.midY * 0.8),
            control1: CGPoint(x: rect.midX * 0.8, y: rect.midY * 0.4),
            control2: CGPoint(x: rect.midX * 1.2, y: rect.midY * 0.6)
        )
        
        // 右侧曲线
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control1: CGPoint(x: rect.midX * 1.8, y: rect.maxY * 0.6),
            control2: CGPoint(x: rect.maxX, y: rect.maxY * 0.8)
        )
        
        // 闭合路径
        path.closeSubpath()
        
        return path
    }
}

public struct BackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var foodIconsOpacity: Double = 0
    @State private var foodIconsScale: CGFloat = 0.8
    @State private var steamOffset1: CGFloat = 0
    @State private var steamOffset2: CGFloat = 0
    @State private var currentFoodSet: Int = 0
    
    // 早餐食物图标集合 - 使用SF Symbols中的食物图标
    private let foodSets: [[String]] = [
        ["croissant.fill", "cup.and.saucer.fill", "mug.fill", "takeoutbag.and.cup.and.straw.fill", "fork.knife", "carrot.fill"],
        ["egg.fill", "carrot.fill", "leaf.fill", "cup.and.saucer.fill", "mug.fill", "fork.knife"],
        ["takeoutbag.and.cup.and.straw.fill", "mug.fill", "cup.and.saucer.fill", "croissant.fill", "fork.knife", "leaf.fill"]
    ]
    
    // 早餐食物颜色集合 - 使用食欲色彩
    private let foodColors: [Color] = [
        Color(hex: "FFB74D"), // 温暖的橙色（如煎蛋）
        Color(hex: "A1887F"), // 咖啡色
        Color(hex: "FFCC80"), // 淡橙色（如煎饼）
        Color(hex: "D7CCC8"), // 奶油色（如牛奶）
        Color(hex: "C8E6C9"), // 淡绿色（如蔬菜）
        Color(hex: "FFECB3")  // 淡黄色（如蜂蜜）
    ]
    
    public var body: some View {
        ZStack {
            // 基础背景色 - 根据深浅模式调整
            Color(UIColor.systemBackground)
            
            // 早餐主题渐变背景
            GeometryReader { geometry in
                ZStack {
                    // 现代渐变色，参考美味早餐的色调
                    if colorScheme == .dark {
                        // 深色模式 - 温暖的早餐主题色调
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "3E2723"),  // 深咖啡色（如浓咖啡）
                                Color(hex: "4E342E"),  // 中等烘焙咖啡色
                                Color(hex: "5D4037")   // 带点温暖的深棕色（如烤面包）
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .opacity(0.7) // 降低不透明度以便图标更明显
                    } else {
                        // 浅色模式 - 明亮温暖的早餐主题色调
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "FFF8E1"),  // 温暖的奶油色（如黄油）
                                Color(hex: "FFECB3"),  // 淡黄色（如蜂蜜）
                                Color(hex: "FFE0B2")   // 淡橙色（如煎饼）
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    }
                    
                    // 早餐食物图案背景
                    FoodIconsBackground(foodSet: foodSets[currentFoodSet], colors: foodColors)
                        .opacity(foodIconsOpacity)
                        .scaleEffect(foodIconsScale)
                    
                    // 早餐蒸汽/香气效果
                    Group {
                        // 第一个蒸汽效果
                        SteamEffect()
                            .fill(colorScheme == .dark ? 
                                 Color(hex: "A67C52").opacity(0.15) : // 深色模式下的咖啡色蒸汽
                                 Color(hex: "FFD180").opacity(0.6))   // 浅色模式下的温暖蒸汽
                            .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.15)
                            .position(x: geometry.size.width * 0.7, y: geometry.size.height * 0.25 + steamOffset1)
                            .blur(radius: 15)
                        
                        // 第二个蒸汽效果
                        SteamEffect()
                            .fill(colorScheme == .dark ? 
                                 Color(hex: "8D6E63").opacity(0.12) : // 深色模式下的咖啡色蒸汽
                                 Color(hex: "FFECB3").opacity(0.5))   // 浅色模式下的温暖蒸汽
                            .frame(width: geometry.size.width * 0.45, height: geometry.size.width * 0.18)
                            .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.18 + steamOffset2)
                            .blur(radius: 18)
                    }
                }
            }
            .onAppear {
                // 初始化动画
                withAnimation(.easeInOut(duration: 1.2)) {
                    foodIconsOpacity = 0.9
                    foodIconsScale = 1.0
                }
                
                // 蒸汽缓慢上升动画
                withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                    steamOffset1 = -15
                    steamOffset2 = -20
                }
                
                // 每30秒切换一次食物图标集合
                Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 1.0)) {
                        foodIconsOpacity = 0.1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        currentFoodSet = (currentFoodSet + 1) % foodSets.count
                        
                        withAnimation(.easeInOut(duration: 1.0)) {
                            foodIconsOpacity = 0.9
                        }
                    }
                }
            }
        }
    }
}

// 注意：颜色扩展已移至ColorExtensions.swift文件中
