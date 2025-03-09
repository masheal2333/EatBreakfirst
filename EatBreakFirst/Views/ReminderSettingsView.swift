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
    @State private var showTestNotificationSent = false
    
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
    
    // MARK: - 测试通知管理
    
    /// 发送测试通知
    private func sendTestNotification() {
        let center = UNUserNotificationCenter.current()
        
        // 检查通知权限
        checkNotificationAuthorizationForTest { isAuthorized in
            guard isAuthorized else { return }
            
            // 创建并发送测试通知
            self.createAndSendTestNotification()
        }
    }
    
    /// 检查测试通知的授权状态
    private func checkNotificationAuthorizationForTest(completion: @escaping (Bool) -> Void) {
        breakfastTracker.requestNotificationPermission { granted in
            DispatchQueue.main.async {
                if !granted {
                    showNotificationAlert = true
                }
                completion(granted)
            }
        }
    }
    
    /// 创建并发送测试通知
    private func createAndSendTestNotification() {
        let center = UNUserNotificationCenter.current()
        
        // 创建测试通知内容
        let content = createTestNotificationContent()
        
        // 创建立即触发的触发器（5秒后触发）
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // 创建请求
        let request = UNNotificationRequest(
            identifier: "breakfastReminderTest",
            content: content,
            trigger: trigger
        )
        
        // 添加通知请求
        center.add(request) { error in
            if let error = error {
                self.handleTestNotificationError(error)
            } else {
                self.handleTestNotificationSuccess()
            }
        }
    }
    
    /// 创建测试通知内容
    private func createTestNotificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "测试通知 - 该吃早餐啦！🍳"
        content.body = "这是一条测试通知。实际提醒将在每天 \(formatTime(self.reminderTime)) 发送。"
        content.sound = .default
        return content
    }
    
    /// 处理测试通知错误
    private func handleTestNotificationError(_ error: Error) {
        print("添加测试通知请求时出错: \(error.localizedDescription)")
    }
    
    /// 处理测试通知成功
    private func handleTestNotificationSuccess() {
        print("测试通知已发送，将在5秒后显示")
        DispatchQueue.main.async {
            // 显示成功提示
            showTestNotificationSent = true
            
            // 3秒后自动隐藏提示
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showTestNotificationSent = false
            }
        }
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
                        
                        // 添加一个提示卡片
                        if isReminderEnabled {
                            NotificationPreviewCardView(
                                sendTestNotification: sendTestNotification,
                                animationDuration: animationDuration,
                                isReminderEnabled: isReminderEnabled
                            )
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("早餐提醒设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(accentColor)
                    .fontWeight(.medium)
                }
            }
            .alert("需要通知权限", isPresented: $showNotificationAlert) {
                Button("取消", role: .cancel) { }
                Button("去设置") {
                    // 打开系统设置
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("要接收早餐提醒，请在设置中允许通知权限。")
            }
            // 添加自定义的权限说明弹窗
            .alert("允许发送通知", isPresented: $showPermissionExplanationAlert) {
                Button("取消", role: .cancel) {
                    // 用户取消，恢复开关状态
                    isReminderEnabled = false
                    showTimePickerAnimation = false
                    isRequestingPermission = false
                }
                Button("允许") {
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
                Text("我们需要发送通知来提醒您吃早餐。这将帮助您养成健康的早餐习惯。")
            }
            // 添加测试通知发送成功提示
            .overlay(
                ZStack {
                    if showTestNotificationSent {
                        VStack {
                            Spacer()
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("测试通知已发送，请等待5秒")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ? Color(hex: "2A2A2A") : Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            .padding(.bottom, 30)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        .animation(.spring(), value: showTestNotificationSent)
                    }
                }
            )
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
                        
                        Text("提醒时间")
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
                            .onChange(of: reminderTime) { newValue in
                                // 当用户更改时间时更新提醒设置
                                breakfastTracker.setReminder(enabled: isReminderEnabled, time: newValue)
                            }
                            .padding(.horizontal, 8)
                    }
                    
                    // 显示当前选择的时间
                    Text("每天 \(formatTime(reminderTime)) 提醒您吃早餐")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
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
            
            Text("启用早餐提醒")
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            Toggle("", isOn: $isReminderEnabled)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: accentColor))
                .disabled(isRequestingPermission) // 在请求权限时禁用开关
                .onChange(of: isReminderEnabled) { newValue in
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
                
                Text("关于早餐提醒")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(accentColor)
            }
            
            Text("每天按时吃早餐有助于建立健康的生活习惯。我们会在您设定的时间发送提醒，帮助您坚持这个好习惯。")
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

/// 通知预览卡片视图
private struct NotificationPreviewCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let sendTestNotification: () -> Void
    let animationDuration: Double
    let isReminderEnabled: Bool
    
    private let accentColor = Color(hex: "5E72E4")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bell.badge.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 18))
                
                Text("提醒内容预览")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
            }
            
            // 通知预览
            VStack(alignment: .leading, spacing: 8) {
                Text("该吃早餐啦！🍳")
                    .font(.system(size: 16, weight: .bold))
                
                Text("早上好！记得吃早餐，健康的一天从现在开始。不要错过今天的能量补充！")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(hex: "333333") : Color(hex: "F5F5F5"))
            )
            
            // 添加测试通知按钮
            Button(action: {
                sendTestNotification()
            }) {
                HStack {
                    Image(systemName: "bell.and.waveform.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    
                    Text("测试通知")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(accentColor)
                )
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(hex: "2A2A2A") : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
        .transition(.opacity)
        .animation(.easeInOut(duration: animationDuration), value: isReminderEnabled)
    }
}

// Helper function to format time
fileprivate func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
}