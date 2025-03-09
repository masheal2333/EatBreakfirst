//
//  EatBreakFirstApp.swift
//  EatBreakFirst
//
//  Created by Sheng Ma on 3/6/25.
//

import SwiftUI
import UserNotifications

@main
struct EatBreakFirstApp: App {
    @StateObject private var breakfastTracker = BreakfastTracker()
    
    init() {
        // 确保App Group正确设置
        let appGroupIdentifier = "group.com.masheal2333.EatBreakFirst"
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        if defaults == nil {
            print("警告: 无法创建带有 App Group 的 UserDefaults，可能是项目设置问题")
        } else {
            print("应用: 成功使用 App Group \(appGroupIdentifier) 初始化 UserDefaults")
        }
        
        // 设置通知代理
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        // 请求通知权限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知权限已授予")
                // 在主线程中注册远程通知
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("通知权限请求错误: \(error.localizedDescription)")
            } else {
                print("用户拒绝了通知权限")
            }
        }
        
        // 初始化用户角色管理器
        _ = UserRoleManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(breakfastTracker)
                .onAppear {
                    // 确保小组件数据与应用数据一致
                    breakfastTracker.ensureWidgetDataConsistency()
                }
        }
    }
}

// 通知代理类，处理通知响应
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    // 当应用在前台时收到通知
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 允许在前台显示通知
        completionHandler([.banner, .sound, .badge])
    }
    
    // 当用户响应通知时
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let actionIdentifier = response.actionIdentifier
        
        // 处理用户选择的操作
        switch actionIdentifier {
        case "EAT_ACTION":
            // 用户选择了"我已吃早餐"
            BreakfastTracker.recordBreakfastFromWidget(eaten: true)
            
        case "SKIP_ACTION":
            // 用户选择了"今天跳过"
            BreakfastTracker.recordBreakfastFromWidget(eaten: false)
            
        default:
            // 用户点击了通知本身
            break
        }
        
        // 完成处理
        completionHandler()
    }
}
