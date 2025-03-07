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
        // 设置通知代理
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(breakfastTracker)
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
