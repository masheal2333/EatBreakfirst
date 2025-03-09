//
//  ReminderSettingsView.swift
//  EatBreakFirst
//
//  Created on 3/7/25.
//

import SwiftUI
import UserNotifications


struct ReminderSettingsView: View {
    @ObservedObject var breakfastTracker: BreakfastTracker
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var isReminderEnabled: Bool
    @State private var reminderTime: Date
    @State private var showTimePickerAnimation: Bool = false
    @State private var showNotificationAlert = false
    @State private var isRequestingPermission = false
    @State private var showPermissionExplanationAlert = false
    
    // 定义动画常量
    private let animationDuration: Double = 0.3
    private let accentColor = Color(hex: "5E72E4")
    
    init(breakfastTracker: BreakfastTracker) {
        self.breakfastTracker = breakfastTracker
        _isReminderEnabled = State(initialValue: breakfastTracker.isReminderEnabled)
        _reminderTime = State(initialValue: breakfastTracker.reminderTime)
        _showTimePickerAnimation = State(initialValue: breakfastTracker.isReminderEnabled)
    }
    
    // MARK: - 通知权限管理
    
    /// 通知授权状态枚举
    private enum NotificationAuthStatus {
        case authorized
        case notDetermined
        case denied
    }
    
    /// 检查通知权限状态
    private func checkNotificationPermission() {
        breakfastTracker.requestNotificationPermission { granted in
            if !granted {
                // 如果没有通知权限，但提醒已启用，显示提示
                DispatchQueue.main.async {
                    self.disableReminder()
                    showNotificationAlert = true
                }
            }
        }
    }
    
    /// 禁用提醒
    private func disableReminder() {
        isReminderEnabled = false
        showTimePickerAnimation = false
        breakfastTracker.setReminder(enabled: false, time: reminderTime)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundGradientView()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // 开关设置
                        VStack(spacing: 0) {
                            // 启用/禁用提醒
                            ReminderToggleView(
                                breakfastTracker: breakfastTracker,
                                isReminderEnabled: $isReminderEnabled,
                                showTimePickerAnimation: $showTimePickerAnimation,
                                isRequestingPermission: $isRequestingPermission,
                                showNotificationAlert: $showNotificationAlert,
                                reminderTime: $reminderTime,
                                requestNotificationPermission: { completion in
                                    breakfastTracker.requestNotificationPermission(completion: completion)
                                }
                            )
                            
                            // 时间选择器 - 只在启用提醒时显示，带有平滑过渡动画
                            TimePickerView(
                                showTimePickerAnimation: showTimePickerAnimation,
                                reminderTime: $reminderTime,
                                isReminderEnabled: isReminderEnabled,
                                breakfastTracker: breakfastTracker,
                                animationDuration: animationDuration
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(colorScheme == .dark ? Color(hex: "2A2A2A") : Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        
                        // 提示信息
                        InformationCardView()
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle(L(.reminderSettings))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L(.done)) {
                        dismiss()
                    }
                    .foregroundColor(accentColor)
                    .fontWeight(.medium)
                }
            }
            .alert(L(.needNotificationPermission), isPresented: $showNotificationAlert) {
                Button(L(.cancel), role: .cancel) { }
                Button(L(.goToSettings)) {
                    // 打开系统设置
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text(L(.notificationPermissionMessage))
            }
            // 添加自定义的权限说明弹窗
            .alert(L(.allowNotifications), isPresented: $showPermissionExplanationAlert) {
                Button(L(.cancel), role: .cancel) {
                    // 用户取消，恢复开关状态
                    isReminderEnabled = false
                    showTimePickerAnimation = false
                    isRequestingPermission = false
                }
                Button(L(.allowButton)) {
                    // 用户同意，请求系统权限
                    isRequestingPermission = true
                    breakfastTracker.requestNotificationPermission { granted in
                        DispatchQueue.main.async {
                            isRequestingPermission = false
                            if granted {
                                withAnimation(.easeInOut(duration: animationDuration)) {
                                    showTimePickerAnimation = true
                                }
                                
                                // 延迟更新提醒设置，让动画先完成
                                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                                    breakfastTracker.setReminder(enabled: true, time: reminderTime)
                                }
                            } else {
                                isReminderEnabled = false
                                showTimePickerAnimation = false
                                showNotificationAlert = true
                            }
                        }
                    }
                }
            } message: {
                Text(L(.notificationExplanationMessage))
            }
        }
        .onAppear {
            // 如果提醒已启用，检查通知权限状态
            if isReminderEnabled {
                checkNotificationPermission()
            }
        }
    }
}

// MARK: - Helper Views

/// 背景渐变视图
private struct BackgroundGradientView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                colorScheme == .dark ? Color(hex: "1A1A1A") : Color(hex: "F8F9FA"),
                colorScheme == .dark ? Color(hex: "2A2A2A") : Color(hex: "FFFFFF")
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

/// 时间选择器视图
private struct TimePickerView: View {
    let showTimePickerAnimation: Bool
    @Binding var reminderTime: Date
    let isReminderEnabled: Bool
    let breakfastTracker: BreakfastTracker
    let animationDuration: Double
    @Environment(\.colorScheme) private var colorScheme
    
    private let accentColor = Color(hex: "5E72E4")
    
    var body: some View {
        VStack {
            if showTimePickerAnimation {
                Divider()
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 20))
                            .foregroundColor(accentColor)
                            .frame(width: 30)
                        
                        Text(L(.reminderTime))
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // 美化的时间选择器
                    ZStack {
                        // 背景装饰
                        RoundedRectangle(cornerRadius: 12)
                            .fill(accentColor.opacity(0.05))
                            .frame(height: 200)
                            .padding(.horizontal, 16)
                        
                        DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .onChangeCompat(of: reminderTime) { newValue in
                                // 当用户更改时间时更新提醒设置
                                breakfastTracker.setReminder(enabled: isReminderEnabled, time: newValue)
                            }
                            .padding(.horizontal, 8)
                    }
                    
                    // 显示当前选择的时间
                    Text(String(format: L(.dailyReminderTime), formatTime(reminderTime)))
                        .font(.system(size: 15))
                        .foregroundColor(Color.secondaryText)
                        .padding(.bottom, 16)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: animationDuration), value: showTimePickerAnimation)
        .clipped()
    }
}

/// 提醒开关视图
private struct ReminderToggleView: View {
    @ObservedObject var breakfastTracker: BreakfastTracker
    @Binding var isReminderEnabled: Bool
    @Binding var showTimePickerAnimation: Bool
    @Binding var isRequestingPermission: Bool
    @Binding var showNotificationAlert: Bool
    @Binding var reminderTime: Date
    let requestNotificationPermission: (@escaping (Bool) -> Void) -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private let accentColor = Color(hex: "5E72E4")
    private let animationDuration: Double = 0.3
    
    var body: some View {
        HStack {
            Image(systemName: "bell.fill")
                .font(.system(size: 20))
                .foregroundColor(accentColor)
                .frame(width: 30)
            
            Text(L(.enableBreakfastReminder))
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            Toggle("", isOn: $isReminderEnabled)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: accentColor))
                .disabled(isRequestingPermission) // 在请求权限时禁用开关
                .onChangeCompat(of: isReminderEnabled) { newValue in
                    handleToggleChange(newValue: newValue)
                }
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(colorScheme == .dark ? Color(hex: "2A2A2A") : Color.white)
        )
        .overlay(
            // 显示加载指示器
            Group {
                if isRequestingPermission {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: accentColor))
                            .scaleEffect(0.8)
                            .padding(.trailing, 8)
                    }
                    .padding(.horizontal)
                }
            }
        )
    }
    
    private func handleToggleChange(newValue: Bool) {
        if newValue {
            // 当用户启用提醒时，请求通知权限
            isRequestingPermission = true // 开始请求权限
            requestNotificationPermission { granted in
                isRequestingPermission = false // 请求完成
                if granted {
                    // 用户授予了通知权限，继续启用提醒
                    withAnimation(.easeInOut(duration: animationDuration)) {
                        showTimePickerAnimation = true
                    }
                    
                    // 延迟更新提醒设置，让动画先完成
                    DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                        breakfastTracker.setReminder(enabled: true, time: reminderTime)
                    }
                } else {
                    // 用户拒绝了通知权限，恢复开关状态
                    DispatchQueue.main.async {
                        isReminderEnabled = false
                        showTimePickerAnimation = false
                        // 显示一个提示，告诉用户需要启用通知权限
                        showNotificationAlert = true
                    }
                }
            }
        } else {
            // 用户禁用提醒，直接更新UI和设置
            withAnimation(.easeInOut(duration: animationDuration)) {
                showTimePickerAnimation = false
            }
            
            // 延迟更新提醒设置，让动画先完成
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                breakfastTracker.setReminder(enabled: false, time: reminderTime)
            }
        }
    }
}

/// 信息卡片视图
private struct InformationCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    private let accentColor = Color(hex: "5E72E4")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(accentColor)
                    .font(.system(size: 18))
                
                Text(L(.aboutBreakfastReminder))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(accentColor)
            }
            
            Text(L(.reminderExplanation))
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(hex: "2A2A2A") : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
}

// Helper function to format time
fileprivate func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
}