//
//  BreakfastBackgroundView.swift
//  EatBreakFirst
//
//  Created on 3/8/25.
//

import SwiftUI

// 早餐图片背景组件
public struct BreakfastImagesBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentImageIndex: Int = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 1.05
    
    // 早餐图片集合 - 使用SF Symbols中的食物图标模拟真实图片
    private let breakfastImages: [BreakfastImage] = [
        BreakfastImage(symbols: ["croissant.fill", "cup.and.saucer.fill"], title: "牛角面包和咖啡", colors: [Color.categoryMilestone.opacity(0.8), Color.categorySpecial.opacity(0.6)]),
        BreakfastImage(symbols: ["egg.fill", "carrot.fill", "leaf.fill"], title: "健康早餐", colors: [Color.categoryMilestone.opacity(0.7), Color.categoryConsistency.opacity(0.7)]),
        BreakfastImage(symbols: ["mug.fill", "takeoutbag.and.cup.and.straw.fill"], title: "早餐饮品", colors: [Color.categoryStreak.opacity(0.6), Color.categoryMilestone.opacity(0.5)])
    ]
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景渐变层
                Color.clear
                
                // 早餐图片展示
                VStack(spacing: 0) {
                    Spacer()
                    
                    // 当前早餐图片
                    ZStack {
                        // 背景圆形
                        Circle()
                            .fill(colorScheme == .dark ? 
                                 Color.primary.opacity(0.3) : 
                                 Color.categoryMilestone.opacity(0.2))
                            .frame(width: geometry.size.width * 1.2, height: geometry.size.width * 1.2)
                            .offset(y: geometry.size.height * 0.25)
                        
                        // 食物图标展示
                        VStack(spacing: 15) {
                            HStack(spacing: 30) {
                                ForEach(breakfastImages[currentImageIndex].symbols, id: \.self) { symbol in
                                    Image(systemName: symbol)
                                        .font(.system(size: 80))
                                        .foregroundColor(breakfastImages[currentImageIndex].colors.first)
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                                }
                            }
                            
                            Text(breakfastImages[currentImageIndex].title)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.7))
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                        .offset(y: geometry.size.height * 0.15)
                    }
                    .opacity(opacity)
                    .scaleEffect(scale)
                    
                    Spacer()
                }
            }
            .onAppear {
                // 初始化动画
                withAnimation(.easeInOut(duration: 1.0)) {
                    opacity = 0.9
                    scale = 1.0
                }
                
                // 每20秒切换一次早餐图片
                Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 0.8)) {
                        opacity = 0
                        scale = 0.95
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        currentImageIndex = (currentImageIndex + 1) % breakfastImages.count
                        
                        withAnimation(.easeInOut(duration: 0.8)) {
                            opacity = 0.9
                            scale = 1.0
                        }
                    }
                }
            }
        }
    }
}

// 早餐图片数据模型
struct BreakfastImage {
    let symbols: [String]
    let title: String
    let colors: [Color]
}

// 注意：颜色扩展已移至ColorExtensions.swift文件中
