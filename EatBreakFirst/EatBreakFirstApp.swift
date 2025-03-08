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
        
        #if DEBUG
        // 在调试模式下生成图标
        generateAppIcons()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(breakfastTracker)
        }
    }
    
    // 生成应用图标
    private func generateAppIcons() {
        // 定义所有需要的图标尺寸
        let iconSizes: [(name: String, size: CGSize)] = [
            ("AppIcon-1024x1024", CGSize(width: 1024, height: 1024)),
            ("AppIcon-20x20", CGSize(width: 20, height: 20)),
            ("AppIcon-20x20@2x", CGSize(width: 40, height: 40)),
            ("AppIcon-20x20@3x", CGSize(width: 60, height: 60)),
            ("AppIcon-29x29", CGSize(width: 29, height: 29)),
            ("AppIcon-29x29@2x", CGSize(width: 58, height: 58)),
            ("AppIcon-29x29@3x", CGSize(width: 87, height: 87)),
            ("AppIcon-40x40", CGSize(width: 40, height: 40)),
            ("AppIcon-40x40@2x", CGSize(width: 80, height: 80)),
            ("AppIcon-40x40@3x", CGSize(width: 120, height: 120)),
            ("AppIcon-60x60@2x", CGSize(width: 120, height: 120)),
            ("AppIcon-60x60@3x", CGSize(width: 180, height: 180)),
            ("AppIcon-76x76", CGSize(width: 76, height: 76)),
            ("AppIcon-76x76@2x", CGSize(width: 152, height: 152)),
            ("AppIcon-83.5x83.5@2x", CGSize(width: 167, height: 167))
        ]
        
        // 获取应用包路径
        let bundleURL = Bundle.main.bundleURL
        
        // 获取文档目录路径
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let iconsDirectory = documentsDirectory.appendingPathComponent("AppIcons")
        
        // 创建目录（如果不存在）
        try? FileManager.default.createDirectory(at: iconsDirectory, withIntermediateDirectories: true)
        
        // 为每个尺寸生成图标
        for (name, size) in iconSizes {
            generateIcon(name: name, size: size, saveURL: iconsDirectory)
        }
        
        print("所有图标已生成并保存到: \(iconsDirectory.path)")
        print("请将这些图标手动添加到 Xcode 的 Assets.xcassets/AppIcon.appiconset 目录中")
    }
    
    // 生成单个图标
    private func generateIcon(name: String, size: CGSize, saveURL: URL) {
        // 创建一个渲染器
        let renderer = UIGraphicsImageRenderer(size: size)
        
        // 渲染图标
        let image = renderer.image { context in
            // 背景 - 使用早晨的天空蓝色
            let backgroundColor = UIColor(red: 0.53, green: 0.81, blue: 0.98, alpha: 1.0) // 天空蓝
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // 添加太阳
            let sunColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // 阳光黄
            sunColor.setFill()
            
            let sunRadius = size.width * 0.2
            let sunCenter = CGPoint(x: size.width * 0.75, y: size.width * 0.25)
            let sunPath = UIBezierPath(arcCenter: sunCenter, radius: sunRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            sunPath.fill()
            
            // 添加太阳光芒
            let rayLength = sunRadius * 0.5
            let rayCount = 8
            let rayWidth = sunRadius * 0.15
            
            for i in 0..<rayCount {
                let angle = CGFloat(i) * CGFloat.pi * 2 / CGFloat(rayCount)
                let rayPath = UIBezierPath()
                
                let startX = sunCenter.x + sunRadius * cos(angle)
                let startY = sunCenter.y + sunRadius * sin(angle)
                let endX = sunCenter.x + (sunRadius + rayLength) * cos(angle)
                let endY = sunCenter.y + (sunRadius + rayLength) * sin(angle)
                
                rayPath.move(to: CGPoint(x: startX, y: startY))
                rayPath.addLine(to: CGPoint(x: endX, y: endY))
                rayPath.lineWidth = rayWidth
                sunColor.setStroke()
                rayPath.stroke()
            }
            
            // 添加早餐元素
            let breakfastEmojis = ["🍳", "🥐", "☕️"]
            let emojiSize = size.width * 0.25
            let font = UIFont.systemFont(ofSize: emojiSize)
            
            for (index, emoji) in breakfastEmojis.enumerated() {
                let xPos = size.width * 0.25 + CGFloat(index) * emojiSize * 0.6
                let yPos = size.height * 0.6
                
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: font
                ]
                
                emoji.draw(at: CGPoint(x: xPos, y: yPos), withAttributes: textAttributes)
            }
            
            // 添加闹钟提醒元素
            let clockEmoji = "⏰"
            let clockSize = size.width * 0.2
            let clockFont = UIFont.systemFont(ofSize: clockSize)
            let clockAttributes: [NSAttributedString.Key: Any] = [
                .font: clockFont
            ]
            
            clockEmoji.draw(at: CGPoint(x: size.width * 0.15, y: size.height * 0.25), withAttributes: clockAttributes)
            
            // 如果图标足够大，添加文字
            if size.width >= 60 {
                let text = "记得吃早饭"
                let fontSize = size.width * 0.15
                let textFont = UIFont.boldSystemFont(ofSize: fontSize)
                let textColor = UIColor.white
                
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: textFont,
                    .foregroundColor: textColor
                ]
                
                let textSize = text.size(withAttributes: textAttributes)
                let textRect = CGRect(
                    x: (size.width - textSize.width) / 2,
                    y: size.height * 0.85,
                    width: textSize.width,
                    height: textSize.height
                )
                
                text.draw(in: textRect, withAttributes: textAttributes)
            }
        }
        
        // 保存图标到文件
        let fileURL = saveURL.appendingPathComponent("\(name).png")
        if let data = image.pngData() {
            try? data.write(to: fileURL)
            print("图标已保存到: \(fileURL.path)")
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
