//
//  StatsView.swift
//  EatBreakFirst
//
//  Created on 3/6/25.
//

import SwiftUI
// 确保可以使用ColorExtensions.swift中定义的Color扩展
// 导入早餐背景图片组件

// Stats View
public struct StatsView: View {
    let stats: BreakfastStats
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var animateChart = false
    @State private var showDetails = false
    
    private var weekdayNames: [String] {
        ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    }
    
    // 获取每周真实数据
    private var weeklyData: [CGFloat] {
        // 使用辅助函数分解复杂逻辑
        let (weekdayValues, weekdayCounts) = calculateWeekdayStats()
        return calculateCompletionRates(values: weekdayValues, counts: weekdayCounts)
    }
    
    // 计算每周的统计数据
    private func calculateWeekdayStats() -> ([CGFloat], [Int]) {
        let calendar = Calendar.current
        
        // 初始化数组
        var weekdayValues: [CGFloat] = [0, 0, 0, 0, 0, 0, 0]
        var weekdayCounts: [Int] = [0, 0, 0, 0, 0, 0, 0]
        
        // 获取最近90天的记录
        let today = Date()
        guard let ninetyDaysAgo = calendar.date(byAdding: .day, value: -90, to: today) else {
            return (weekdayValues, weekdayCounts)
        }
        
        // 遍历记录
        for (date, hasEaten) in stats.weeklyRecords {
            if date >= ninetyDaysAgo {
                let adjustedIndex = getWeekdayIndex(for: date, calendar: calendar)
                
                if hasEaten {
                    weekdayValues[adjustedIndex] += 1
                }
                weekdayCounts[adjustedIndex] += 1
            }
        }
        
        return (weekdayValues, weekdayCounts)
    }
    
    // 获取星期索引
    private func getWeekdayIndex(for date: Date, calendar: Calendar) -> Int {
        // 获取星期几 (1-7, 其中1是周日)
        let weekday = calendar.component(.weekday, from: date)
        
        // 调整为周一为0的索引 (周日是6)
        switch weekday {
        case 1: return 6  // 周日
        case 2: return 0  // 周一
        case 3: return 1  // 周二
        case 4: return 2  // 周三
        case 5: return 3  // 周四
        case 6: return 4  // 周五
        case 7: return 5  // 周六
        default: return 0  // 默认周一
        }
    }
    
    // 计算完成率
    private func calculateCompletionRates(values: [CGFloat], counts: [Int]) -> [CGFloat] {
        var results: [CGFloat] = []
        
        for index in 0..<values.count {
            let value = values[index]
            let count = counts[index]
            
            // 避免除以零
            if count > 0 {
                results.append(value / CGFloat(count))
            } else {
                results.append(0)
            }
        }
        
        return results
    }
    
    public var body: some View {
        ZStack {
            // 背景渐变
            backgroundGradient
            
            // 添加早餐背景图片
            BreakfastImagesBackground()
                .opacity(0.7)
            
            VStack(spacing: 0) {
                headerView
                mainContentView
            }
            
            // 添加动画效果视图，避免重复代码
            animationEffect
        }
    }
    
    // 背景渐变
    private var backgroundGradient: some View {
        let gradientTopColor = colorScheme == .dark ? Color(hex: "1A1A1A") : Color(hex: "F8F9FA")
        let gradientBottomColor = colorScheme == .dark ? Color(hex: "2D2D2D") : Color(hex: "FFFFFF")
        
        return LinearGradient(
            gradient: Gradient(colors: [gradientTopColor, gradientBottomColor]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // 头部视图
    private var headerView: some View {
        HStack {
            Text("早餐统计")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 10)
    }
    
    // 主要内容视图
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 25) {
                summaryCardView
                completionRateCardView
                weeklyTrendCardView
            }
            .padding(.vertical, 15)
        }
    }
    
    // 摘要卡片视图
    private var summaryCardView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("早餐数据概览")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color.primaryText)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 15)
            
            // 数据卡片网格
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                // 早餐天数
                statCardView(
                    value: stats.daysEaten,
                    label: "早餐天数",
                    icon: "takeoutbag.and.cup.and.straw.fill",
                    color: Color.categoryConsistency,
                    backgroundColor: Color.categoryConsistency.opacity(0.1)
                )
                
                // 未吃早餐
                statCardView(
                    value: stats.daysSkipped,
                    label: "未吃早餐",
                    icon: "xmark.circle.fill",
                    color: Color(hex: "F44336"),
                    backgroundColor: Color(hex: "F44336").opacity(0.1)
                )
                
                // 当前连续
                statCardView(
                    value: stats.currentStreak,
                    label: "当前连续",
                    icon: "flame.fill",
                    color: Color.categoryStreak,
                    backgroundColor: Color.categoryStreak.opacity(0.1)
                )
                
                // 最长纪录
                statCardView(
                    value: stats.longestStreak,
                    label: "最长纪录",
                    icon: "trophy.fill",
                    color: Color.categoryMilestone,
                    backgroundColor: Color.categoryMilestone.opacity(0.1)
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(cardBackground)
        .padding(.horizontal, 20)
    }
    
    // 单个统计卡片
    private func statCardView(value: Int, label: String, icon: String, color: Color, backgroundColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // 图标
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(backgroundColor)
                .clipShape(Circle())
            
            // 数值
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color.primaryText)
            
            // 标签
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(Color(hex: colorScheme == .dark ? "2A2A2A" : "F8F8F8").opacity(0.9))
        .cornerRadius(12)
        .shadow(color: Color.shadowColor.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // 卡片背景
    private var cardBackground: some View {
        ZStack {
            let cardColor = colorScheme == .dark ? Color(hex: "2A2A2A").opacity(0.9) : Color.white.opacity(0.95)
            RoundedRectangle(cornerRadius: 20)
                .fill(cardColor)
                .shadow(color: Color.shadowColor.opacity(0.08), radius: 8, x: 0, y: 4)
        }
    }
                        
    // 完成率卡片视图
    private var completionRateCardView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("早餐完成率")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.primaryText : .black)
                
                Spacer()
                
                let completionRateInt = Int(stats.completionRate)
                let completionRateColor = getCompletionRateColor(rate: stats.completionRate)
                
                Text("\(completionRateInt)%")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .shadow(color: completionRateColor.opacity(0.2), radius: 1, x: 0, y: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 15)
            
            // 简化的进度条设计
            VStack(spacing: 15) {
                // 近30天进度条
                HStack {
                    Text("近期记录")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.secondaryText)
                    
                    Spacer()
                    
                    Text("\(stats.recentDaysEaten)/\(stats.recentDaysTracked) 天")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.secondaryText)
                }
                
                // 进度条
                ZStack(alignment: .leading) {
                    // 背景条
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.progressBackground)
                        .frame(height: 12)
                    
                    // 进度条
                    let recentProgressWidth = stats.recentDaysTracked > 0 ? 
                        CGFloat(stats.recentDaysEaten) / CGFloat(stats.recentDaysTracked) : 0
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(getCompletionRateColor(rate: stats.recentCompletionRate))
                        .frame(height: 12)
                        .scaleEffect(x: animateChart ? recentProgressWidth : 0.01, y: 1, anchor: .leading)
                        .animation(.easeOut(duration: 1.0), value: animateChart)
                        .shadow(color: getCompletionRateColor(rate: stats.recentCompletionRate).opacity(0.3), radius: 1, x: 0, y: 0)
                }
                
                // 全部记录进度条
                HStack {
                    Text("全部记录")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.secondaryText)
                    
                    Spacer()
                    
                    Text("\(stats.daysEaten)/\(stats.totalDaysTracked) 天")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.secondaryText)
                }
                
                // 进度条
                ZStack(alignment: .leading) {
                    // 背景条
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.progressBackground)
                        .frame(height: 12)
                    
                    // 进度条
                    let allTimeProgressWidth = stats.totalDaysTracked > 0 ? 
                        CGFloat(stats.daysEaten) / CGFloat(stats.totalDaysTracked) : 0
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(getCompletionRateColor(rate: stats.allTimeCompletionRate))
                        .frame(height: 12)
                        .scaleEffect(x: animateChart ? allTimeProgressWidth : 0.01, y: 1, anchor: .leading)
                        .animation(.easeOut(duration: 1.0).delay(0.3), value: animateChart)
                        .shadow(color: getCompletionRateColor(rate: stats.allTimeCompletionRate).opacity(0.3), radius: 1, x: 0, y: 0)
                }
                
                // 评价标签
                assessmentBadgeView
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 5)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(cardBackground)
        .padding(.horizontal, 20)
    }
    

    

    

    

    
    // 评价标签视图
    private var assessmentBadgeView: some View {
        let assessmentText = getCompletionRateAssessment(rate: stats.completionRate)
        let assessmentColor = getCompletionRateColor(rate: stats.completionRate)
        
        return Text(assessmentText)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(assessmentColor)
            .padding(.vertical, 4)
            .padding(.horizontal, 10)
            .background(assessmentColor.opacity(0.1))
            .cornerRadius(8)
            .padding(.top, 4)
    }
                        
    // 早餐习惯洞察卡片视图
    private var weeklyTrendCardView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("早餐习惯洞察")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color.primaryText)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showDetails.toggle()
                    }
                }) {
                    Image(systemName: showDetails ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 15)
            
            if showDetails {
                VStack(spacing: 20) {
                    // 最佳和最差日统计
                    HStack(spacing: 15) {
                        // 最佳日卡片
                        VStack(spacing: 8) {
                            Text("最佳表现")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.secondaryText)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color.categoryMilestone)
                                    .font(.system(size: 16))
                                
                                Text(stats.bestWeekday ?? "--")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color.primaryText)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color(hex: colorScheme == .dark ? "2A2A2A" : "F8F8F8").opacity(0.9))
                        .cornerRadius(12)
                        .shadow(color: Color.shadowColor.opacity(0.05), radius: 2, x: 0, y: 1)
                        
                        // 最差日卡片
                        VStack(spacing: 8) {
                            Text("需要改进")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.secondaryText)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(Color(hex: "F44336"))
                                    .font(.system(size: 16))
                                
                                Text(stats.worstWeekday ?? "--")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color.primaryText)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color(hex: colorScheme == .dark ? "2A2A2A" : "F8F8F8").opacity(0.9))
                        .cornerRadius(12)
                        .shadow(color: Color.shadowColor.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal, 20)
                    
                    // 平均每周早餐天数
                    VStack(spacing: 10) {
                        Text("平均每周早餐天数")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.secondaryText)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f", stats.weeklyAverage))
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color.primaryText)
                            
                            Text("天")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.secondaryText)
                                .padding(.leading, 2)
                        }
                        
                        // 星期指示器 - 使用GeometryReader让宽度与卡片保持一致
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                ForEach(0..<7, id: \.self) { day in
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(day < Int(stats.weeklyAverage) ? 
                                              Color.categoryConsistency : 
                                              (day < Int(stats.weeklyAverage) + 1 && stats.weeklyAverage.truncatingRemainder(dividingBy: 1) > 0 ? 
                                               Color.categoryConsistency.opacity(stats.weeklyAverage.truncatingRemainder(dividingBy: 1)) : 
                                               Color.progressBackground))
                                        .frame(width: (geometry.size.width - 6) / 7, height: 12) // 均匀分配宽度，留出小间隔
                                        .padding(.horizontal, 0.5) // 添加小间隔
                                }
                            }
                        }
                        .frame(height: 12) // 固定高度
                        .padding(.top, 5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                }
                .transition(.opacity)
            }
        }
        .background(cardBackground)
        .padding(.horizontal, 20)
    }
    

    

    

    

    
    // 动画效果
    private var animationEffect: some View {
        Color.clear
            .onAppear {
                // 简化动画逻辑，使用更直接的方式
                let delayTime = 0.3
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                    withAnimation {
                        animateChart = true
                    }
                }
            }
    }
    
    // 根据完成率获取对应的颜色
    private func getCompletionRateColor(rate: Double) -> Color {
        // 将范围检查拆分为单独的条件语句而非使用复杂的switch语句
        if rate < 30 {
            // 红色 - 需要改进
            return Color(hex: "F44336")
        } else if rate < 50 {
            // 橙色 - 一般
            return Color.categoryMilestone
        } else if rate < 70 {
            // 蓝色 - 良好
            return Color.categoryStreak
        } else if rate < 90 {
            // 浅绿色 - 很好
            return Color.categoryConsistency.opacity(0.8)
        } else {
            // 绿色 - 优秀
            return Color.categoryConsistency
        }
    }
    
    // 根据完成率获取评价文本
    private func getCompletionRateAssessment(rate: Double) -> String {
        // 使用简单的条件语句替代switch语句
        if rate < 30 {
            return "需要努力提升"
        } else if rate < 50 {
            return "有待改进"
        } else if rate < 70 {
            return "表现一般"
        } else if rate < 90 {
            return "表现不错"
        } else {
            return "非常出色"
        }
    }
}




