//
//  ContentView.swift
//  EatBreakFirst
//
//  Created by Sheng Ma on 3/6/25.
//

import SwiftUI
import UserNotifications
// 导入早餐背景视图组件

struct ContentView: View {
    @EnvironmentObject var breakfastTracker: BreakfastTracker
    @State private var hasEatenBreakfast: Bool? = nil
    @State private var showConfetti = false
    @State private var showStats = false
    @State private var showAchievements = false
    @State private var showReminderSettings = false
    @State private var showCalendar = false // 控制日历视图显示
    @State private var sunOffset: CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme
    
    // 添加一个计时器来检查午夜时间
    @State private var midnightTimer: Timer? = nil
    // 添加一个状态来跟踪今天是否可以选择早餐状态
    @State private var canSelectToday: Bool = true
    // 添加用户角色状态
    @State private var isAdmin: Bool = false
    
    // 使用新的颜色系统 - 灵感来自斯德哥尔摩设计学院的色彩理论
    private let accentColor = Color.accentColor     // 主题蓝色 - 沉稳而专业
    private let greenColor = Color.successColor     // 成功绿色 - 清新而有活力
    private let redColor = Color.errorColor         // 错误红色 - 醒目而不刺眼
    
    init() {
        // 检查今天是否已经记录了早餐状态
        let today = Date()
        // 使用 EnvironmentObject 中的 breakfastTracker 会在视图加载时自动注入
        // 所以我们需要在 onAppear 中检查早餐状态
        _canSelectToday = State(initialValue: true) // 默认值，将在 onAppear 中更新
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 美味的早餐背景
                ZStack {
                    // 基础背景渐变
                    BackgroundView()
                    
                    // 早餐食物图案背景
                    // 暂时注释掉新组件，等我们解决导入问题
                    // BreakfastImagesBackground()
                }
                .ignoresSafeArea()
                
                // Main content container - following Dieter Rams' principle of "Less, but better"
                VStack {
                    // Top toolbar with refined spacing and sizing
                    HStack {
                        // Stats button with subtle hover effect
                        Button(action: { showStats.toggle() }) {
                            Image(systemName: "chart.bar.fill")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                .font(.system(size: 22, weight: .medium))
                                .frame(width: 44, height: 44)
                                .contentShape(Circle())
                                .background(
                                    Circle()
                                        .fill(Color.primary.opacity(0.05))
                                        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                                )
                        }
                        .buttonStyle(.plain)
                        #if DEBUG
                        // 在调试模式下，长按统计按钮可以切换角色
                        .onLongPressGesture {
                            UserRoleManager.shared.toggleRole()
                            isAdmin = UserRoleManager.shared.isAdmin()
                            
                            // 显示角色切换提示
                            let roleName = isAdmin ? "管理员" : "普通用户"
                            let feedback = UINotificationFeedbackGenerator()
                            feedback.notificationOccurred(.success)
                            
                            // 使用临时弹窗提示角色已切换
                            let alert = UIAlertController(
                                title: "角色已切换",
                                message: "当前角色: \(roleName)",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "确定", style: .default))
                            
                            // 获取当前的 UIWindow
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootViewController = windowScene.windows.first?.rootViewController {
                                rootViewController.present(alert, animated: true)
                            }
                        }
                        #endif
                        
                        Spacer()
                        
                        // Trophy button with matching style
                        Button(action: { showAchievements.toggle() }) {
                            Image(systemName: "trophy.fill")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                .font(.system(size: 22, weight: .medium))
                                .frame(width: 44, height: 44)
                                .contentShape(Circle())
                                .background(
                                    Circle()
                                        .fill(Color.primary.opacity(0.05))
                                        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    if hasEatenBreakfast == nil {
                        // 检查今天是否可以选择早餐状态
                        if canSelectToday {
                            // Question View - Inspired by Dieter Rams' principle of "As little design as possible"
                            VStack(spacing: 40) {
                                // Question text with refined typography
                                Text("今天吃了早餐吗？")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .tracking(-0.5) // 更紧凑的字母间距，增加优雅感
                                    .foregroundColor(colorScheme == .dark ? Color.primaryText : .black)
                                    .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
                                
                                // 简化后的早餐图标 - 极简设计
                                VStack(spacing: 30) {
                                    // 只保留早餐表情符号
                                    Text("🥐  🍞  🥖")
                                        .font(.system(size: 50))
                                        .tracking(2) // 表情符号之间的间距
                                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                                }
                                .padding(.bottom, 40)
                            }
                            .padding(.horizontal)
                            
                            Spacer() // 添加空间将按钮推到底部
                            
                            // 调整后的按钮设计 - 移动到屏幕底部便于用户触及
                            HStack(spacing: 40) {
                                // 否定按钮 - 保持在左侧
                                Button(action: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        hasEatenBreakfast = false
                                        breakfastTracker.recordBreakfast(eaten: false)
                                        // 更新可选择状态
                                        canSelectToday = breakfastTracker.canSelectBreakfastToday()
                                    }
                                }) {
                                    // 简洁圆形按钮与 X 标记
                                    Image(systemName: "xmark")
                                        .font(.system(size: 40, weight: .medium))
                                        .foregroundStyle(.white)
                                        .frame(width: 120, height: 120)
                                        .background(
                                            Circle()
                                                .fill(redColor)
                                        )
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                        .shadow(color: redColor.opacity(0.3), radius: 10, x: 0, y: 5)
                                }
                                .buttonStyle(ScaleButtonStyle())
                                
                                // 确认按钮 - 保持在右侧
                                Button(action: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        hasEatenBreakfast = true
                                        showConfetti = true
                                        breakfastTracker.recordBreakfast(eaten: true)
                                        // 更新可选择状态
                                        canSelectToday = breakfastTracker.canSelectBreakfastToday()
                                    }
                                }) {
                                    // 简洁圆形按钮与对勾标记
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 40, weight: .medium))
                                        .foregroundStyle(.white)
                                        .frame(width: 120, height: 120)
                                        .background(
                                            Circle()
                                                .fill(greenColor)
                                        )
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                        .shadow(color: greenColor.opacity(0.3), radius: 10, x: 0, y: 5)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 40) // 增加底部空间，使按钮更容易触及
                        } else {
                            // 如果今天已经选择过了，显示一个提示
                            VStack(spacing: 30) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(accentColor)
                                    .padding(.bottom, 20)
                                
                                Text("今天已经记录了早餐状态")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.primary)
                                
                                Text("请明天凌晨 12:00 后再来记录")
                                    .font(.system(size: 18))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                // 显示日历视图
                                CalendarView(breakfastTracker: breakfastTracker)
                                    .frame(height: 280)
                                    .padding(16)
                                    .padding(.top, 20)
                            }
                            .padding()
                        }
                    } else if hasEatenBreakfast == true {
                        // Success View - Refined with Dieter Rams' principles
                        VStack(spacing: 36) {
                            // Congratulations text with refined typography
                            Text("牛哇牛哇！")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .tracking(-0.5)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .shadow(color: accentColor.opacity(0.2), radius: 2, x: 0, y: 1)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .zIndex(1) // 确保这个元素保持在顶层

                            // Streak counter with refined design - tappable to show calendar
                            VStack(spacing: 5) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        showCalendar.toggle()
                                    }
                                }) {
                                    HStack {
                                        Text("连续 \(breakfastTracker.streakCount) 天吃了早饭")
                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                        
                                        Image(systemName: showCalendar ? "chevron.up" : "chevron.down")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                            .animation(.easeInOut, value: showCalendar)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(.white.opacity(0.1))
                                    )
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                            .padding(.bottom, 10)
                            
                            // Calendar view with refined card design - only shown when tapped
                            ZStack {
                                if showCalendar {
                                    CalendarView(breakfastTracker: breakfastTracker)
                                        .frame(height: 280)
                                        .padding(16)
                                        .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                                        .zIndex(0) // Ensure this stays below other elements
                                }
                            }
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showCalendar)
                            
                            // 返回按钮已移除
                            
                            // 如果不能选择今天的早餐状态，显示一个提示
                            if !breakfastTracker.canSelectBreakfastToday() {
                                Text("今天已记录，明天再来")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .padding(.top, 10)
                            }
                            
                            // 添加清除今天记录的按钮（仅管理员可见）
                            if isAdmin {
                                Button(action: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        breakfastTracker.clearTodayRecord()
                                        hasEatenBreakfast = nil
                                        canSelectToday = true
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.system(size: 14))
                                        Text("清除今天的记录")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.gray.opacity(0.1))
                                    )
                                }
                                .padding(.top, 16)
                            }
                        }
                        .padding(.horizontal, 24)
                    } else {
                        // Reminder View - Refined with minimalist principles
                        VStack(spacing: 40) {
                            // Icon container with refined visual design
                            HStack(spacing: 40) {
                                // Clock icon with subtle background
                                ZStack {
                                    Circle()
                                        .fill(accentColor.opacity(0.15))
                                        .frame(width: 90, height: 90)
                                    
                                    Image(systemName: "clock.badge.exclamationmark.fill")
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundStyle(accentColor)
                                        .font(.system(size: 48, weight: .medium))
                                        .shadow(color: accentColor.opacity(0.2), radius: 2, x: 0, y: 1)
                                }
                                
                                // Carrot icon with subtle background
                                ZStack {
                                    Circle()
                                        .fill(Color.warningColor.opacity(0.15))
                                        .frame(width: 90, height: 90)
                                    
                                    Image(systemName: "carrot.fill")
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundStyle(Color.warningColor)
                                        .font(.system(size: 48, weight: .medium))
                                        .shadow(color: Color.warningColor.opacity(0.2), radius: 2, x: 0, y: 1)
                                }
                            }
                            .padding(.bottom, 10)
                            
                            // Reminder text with refined typography
                            Text("明天要记得吃早饭")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .tracking(-0.5) // 更紧凑的字母间距
                                .foregroundColor(accentColor)
                                .multilineTextAlignment(.center)
                                .shadow(color: accentColor.opacity(0.15), radius: 2, x: 0, y: 1)
                            
                            // Subtitle with subtle styling
                            Text("健康的一天从早餐开始")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(Color.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.top, -10)
                            
                            // Reminder card with subtle design
                            VStack(spacing: 16) {
                                Button(action: {
                                    showReminderSettings = true
                                }) {
                                    HStack(spacing: 14) {
                                        Image(systemName: breakfastTracker.isReminderEnabled ? "bell.fill" : "bell")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(accentColor)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("设置早餐提醒")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(Color.primaryText)
                                            
                                            if breakfastTracker.isReminderEnabled {
                                                Text("每天 \(formatTime(breakfastTracker.reminderTime))")
                                                    .font(.system(size: 13, weight: .regular))
                                                    .foregroundColor(Color.secondaryText)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(accentColor.opacity(0.5))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(accentColor.opacity(0.08))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(accentColor.opacity(0.15), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // 返回按钮已移除
                            
                            // 如果不能选择今天的早餐状态，显示一个提示
                            if !breakfastTracker.canSelectBreakfastToday() {
                                Text("今天已记录，明天再来")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .padding(.top, 10)
                            }
                            
                            // 添加清除今天记录的按钮（仅管理员可见）
                            if isAdmin {
                                Button(action: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        breakfastTracker.clearTodayRecord()
                                        hasEatenBreakfast = nil
                                        canSelectToday = true
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.system(size: 14))
                                        Text("清除今天的记录")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.gray.opacity(0.1))
                                    )
                                }
                                .padding(.top, 16)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                }
                .padding()
                
                if showConfetti {
                    ConfettiView()
                        .allowsHitTesting(false)
                }
                
                // Achievement unlocked popup
                if breakfastTracker.showAchievementUnlocked, let achievement = breakfastTracker.latestAchievement {
                    VStack {
                        Spacer()
                        AchievementUnlockedView(achievement: achievement) {
                            // 移除动画效果
                            breakfastTracker.showAchievementUnlocked = false
                        }
                        Spacer()
                    }
                    // 移除过渡和动画效果
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showStats) {
            StatsView(stats: breakfastTracker.calculateStats())
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView(achievements: breakfastTracker.achievements)
                .environmentObject(breakfastTracker)
        }
        .sheet(isPresented: $showReminderSettings) {
            ReminderSettingsView(breakfastTracker: breakfastTracker)
        }
        .onAppear {
            // 检查今天是否已经记录了早餐状态
            let today = Date()
            if let hasEaten = breakfastTracker.hasEatenBreakfast(on: today) {
                hasEatenBreakfast = hasEaten
            }
            
            // 检查今天是否可以选择早餐状态
            canSelectToday = breakfastTracker.canSelectBreakfastToday()
            
            // 确保小组件数据与应用数据一致
            breakfastTracker.ensureWidgetDataConsistency()
            
            // 初始化用户角色状态
            isAdmin = UserRoleManager.shared.isAdmin()
            
            // 添加角色变更通知监听
            NotificationCenter.default.addObserver(
                forName: .userRoleDidChange,
                object: nil,
                queue: .main
            ) { _ in
                self.isAdmin = UserRoleManager.shared.isAdmin()
            }
            
            // 设置计时器，每分钟检查一次是否已经过了午夜
            midnightTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                let calendar = Calendar.current
                let now = Date()
                let components = calendar.dateComponents([.hour, .minute], from: now)
                
                // 如果现在是凌晨 12:00，重置选择状态
                if components.hour == 0 && components.minute == 0 {
                    breakfastTracker.resetDailySelection()
                    canSelectToday = true
                    
                    // 如果用户当前在结果页面，返回到选择页面
                    if hasEatenBreakfast != nil {
                        hasEatenBreakfast = nil
                        showConfetti = false
                    }
                }
                
                // 更新可选择状态
                canSelectToday = breakfastTracker.canSelectBreakfastToday()
            }
        }
        .onDisappear {
            // 清理计时器
            midnightTimer?.invalidate()
            midnightTimer = nil
            
            // 移除角色变更通知监听
            NotificationCenter.default.removeObserver(self, name: .userRoleDidChange, object: nil)
        }
    }
}

// Helper function to format time
fileprivate func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

#Preview {
    ContentView()
        .environmentObject(BreakfastTracker())
}


