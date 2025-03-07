//
//  AchievementViews.swift
//  EatBreakFirst
//
//  Created on 3/6/25.
//

import SwiftUI
// 确保可以使用ColorExtensions.swift中定义的Color扩展

// Achievement Views
public struct AchievementsView: View {
    let achievements: [Achievement]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedAchievement: Achievement? = nil
    @State private var animateCards = false
    @State private var selectedCategory: AchievementCategory? = nil
    @EnvironmentObject private var breakfastTracker: BreakfastTracker
    
    // 按类别分组成就
    private var achievementsByCategory: [AchievementCategory: [Achievement]] {
        Dictionary(grouping: achievements) { $0.category }
    }
    
    // 获取所有类别
    private var categories: [AchievementCategory] {
        Array(achievementsByCategory.keys).sorted { $0.rawValue < $1.rawValue }
    }
    
    // 获取要显示的成就
    private var achievementsToShow: [Achievement] {
        if let selectedCategory = selectedCategory {
            return achievementsByCategory[selectedCategory] ?? []
        } else {
            return achievements
        }
    }
    
    public var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(hex: "1A1A1A") : Color(hex: "F8F9FA"),
                    colorScheme == .dark ? Color(hex: "2D2D2D") : Color(hex: "FFFFFF")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with title and close button
                HStack {
                    Text("成就")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 10)
                
                // Progress summary
                let unlockedCount = achievements.filter { $0.isUnlocked }.count
                let totalCount = achievements.count
                let progressPercentage = Double(unlockedCount) / Double(totalCount)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("解锁进度")
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                        Text("\(unlockedCount)/\(totalCount)")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.progressBackground)
                            .frame(height: 8)
                        
                        // Progress bar with gradient
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.progressForeground, Color.progressForeground.opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: animateCards ? CGFloat(progressPercentage) * UIScreen.main.bounds.width - 40 : 0, height: 8)
                            .animation(.easeOut(duration: 1.0), value: animateCards)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        CategoryButton(title: "全部", icon: "square.grid.2x2.fill", isSelected: selectedCategory == nil) {
                            withAnimation {
                                selectedCategory = nil
                            }
                        }
                        
                        ForEach(categories, id: \.self) { category in
                            CategoryButton(
                                title: category.rawValue,
                                icon: category.icon,
                                color: getColorForCategory(category),
                                isSelected: selectedCategory == category
                            ) {
                                withAnimation {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
                
                // Achievements grid
                ScrollView {
                    // 如果没有选择类别，显示分组成就
                    if selectedCategory == nil {
                        VStack(spacing: 25) {
                            ForEach(categories, id: \.self) { category in
                                if let categoryAchievements = achievementsByCategory[category], !categoryAchievements.isEmpty {
                                    CategorySection(category: category, achievements: categoryAchievements, animateCards: animateCards) { achievement in
                                        selectedAchievement = achievement
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    } else {
                        // 如果选择了类别，只显示该类别的成就
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(achievementsToShow) { achievement in
                                AchievementCard(achievement: achievement)
                                    .onTapGesture {
                                        selectedAchievement = achievement
                                    }
                                    .scaleEffect(animateCards ? 1.0 : 0.8)
                                    .opacity(animateCards ? 1.0 : 0)
                                    .animation(
                                        .spring(response: 0.5, dampingFraction: 0.7)
                                        .delay(Double(achievementsToShow.firstIndex(of: achievement) ?? 0) * 0.1),
                                        value: animateCards
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailView(achievement: achievement)
                .environmentObject(breakfastTracker)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    animateCards = true
                }
            }
        }
    }
    
    // 根据类别获取颜色
    private func getColorForCategory(_ category: AchievementCategory) -> Color {
        return Color.forCategory(category)
    }
}

// 类别按钮组件
public struct CategoryButton: View {
    let title: String
    let icon: String
    var color: Color = .accentColor
    let isSelected: Bool
    let action: () -> Void
    
    public init(title: String, icon: String, color: Color = .accentColor, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color.opacity(0.15) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? color : Color.clear, lineWidth: 1)
            )
            .foregroundColor(isSelected ? color : .secondary)
        }
    }
}

// 类别分区组件
public struct CategorySection: View {
    let category: AchievementCategory
    let achievements: [Achievement]
    let animateCards: Bool
    let onTap: (Achievement) -> Void
    @EnvironmentObject private var breakfastTracker: BreakfastTracker
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 类别标题
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 18))
                    .foregroundColor(getCategoryColor())
                
                Text(category.rawValue)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                
                Spacer()
                
                Button(action: {
                    // 查看全部逻辑可以在这里添加
                }) {
                    Text("查看全部")
                        .font(.system(size: 14))
                        .foregroundColor(getCategoryColor())
                }
            }
            
            // 成就卡片水平滚动视图
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(achievements) { achievement in
                        AchievementCard(achievement: achievement)
                            .frame(width: 160)
                            .onTapGesture {
                                onTap(achievement)
                            }
                            .scaleEffect(animateCards ? 1.0 : 0.8)
                            .opacity(animateCards ? 1.0 : 0)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                .delay(Double(achievements.firstIndex(of: achievement) ?? 0) * 0.1),
                                value: animateCards
                            )
                    }
                }
                .padding(.vertical, 8)
            }
            
            Divider()
                .padding(.top, 8)
        }
    }
    
    private func getCategoryColor() -> Color {
        return Color.forCategory(category)
    }
}

// Achievement card component
public struct AchievementCard: View {
    let achievement: Achievement
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var breakfastTracker: BreakfastTracker
    
    public var body: some View {
        VStack(spacing: 16) {
            // Icon with background
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? 
                          achievement.gradient : 
                          LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                    .shadow(color: achievement.isUnlocked ? Color.forCategory(achievement.category).opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }
            
            // Achievement name
            Text(achievement.name)
                .font(.system(size: 16, weight: .bold))
                .multilineTextAlignment(.center)
                .lineLimit(1)
            
            // Achievement status
            HStack(spacing: 4) {
                if achievement.isUnlocked {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(Color.categoryConsistency)
                        .font(.system(size: 12))
                    
                    Text("已解锁")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.categoryConsistency)
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundColor(Color.secondaryText)
                        .font(.system(size: 12))
                    
                    Text("\(breakfastTracker.streakCount)/\(achievement.requirement)天")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.secondaryText)
                }
            }
        }
        .frame(height: 160)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(hex: "2A2A2A") : .white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(achievement.isUnlocked ? Color.forCategory(achievement.category).opacity(0.3) : Color.progressBackground.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .opacity(achievement.isUnlocked ? 1.0 : 0.8)
    }
}

// Achievement unlocked notification view
public struct AchievementUnlockedView: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    @State private var showAnimation = false
    @Environment(\.colorScheme) private var colorScheme
    
    public var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: achievement.category.icon)
                    .font(.system(size: 14))
                    .foregroundColor(Color.forCategory(achievement.category).opacity(0.8))
                
                Text(achievement.category.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.forCategory(achievement.category).opacity(0.8))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(achievement.color.opacity(0.1))
            )
            
            Text("成就解锁！")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            
            ZStack {
                // Animated rings - consistent with main app background
                ForEach(0..<3, id: \.self) { ring in
                    Circle()
                        .stroke(achievement.color.opacity(0.3), lineWidth: 2)
                        .frame(width: 80 + CGFloat(ring * 20), height: 80 + CGFloat(ring * 20))
                        .scaleEffect(showAnimation ? 1.2 : 0.8)
                        .opacity(showAnimation ? 0 : 0.6)
                        .animation(
                            Animation.easeOut(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(ring) * 0.2),
                            value: showAnimation
                        )
                }
                
                // Main circle - fixed size to match icon
                Circle()
                    .fill(achievement.gradient)
                    .frame(width: 90, height: 90)
                    .shadow(color: achievement.color.opacity(0.4), radius: 10, x: 0, y: 5)
                
                // Sun glow effect for achievement icon (inside the circle)
                if achievement.icon.contains("sun") {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.98, green: 0.75, blue: 0.52).opacity(0.7),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 5,
                                endRadius: 45
                            )
                        )
                        .frame(width: 90, height: 90)
                }
                
                // Achievement icon with clipping for sun icons
                if achievement.icon.contains("sun") {
                    // Create a mask group that contains both the icon and the clipping circle
                    ZStack {
                        // The actual sun icon with animation
                        Image(systemName: achievement.icon)
                            .font(.system(size: 52, weight: .semibold)) // Larger to be more visible
                            .foregroundColor(.white)
                            .offset(y: showAnimation ? -8 : 8) // More pronounced vertical floating animation
                            .animation(
                                Animation.easeInOut(duration: 2.5)
                                    .repeatForever(autoreverses: true),
                                value: showAnimation
                            )
                    }
                    // Use the exact circle size as the clipping boundary
                    .mask(
                        Circle()
                            .frame(width: 90, height: 90)
                    )
                } else {
                    // Standard icon display for non-sun icons
                    Image(systemName: achievement.icon)
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(.white)
                        .scaleEffect(showAnimation ? 1.05 : 1.0)
                        .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: showAnimation)
                }
            }
            .padding(.vertical, 20)
            
            Text(achievement.name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            
            if let unlockDate = achievement.unlockDate {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundColor(Color.secondaryText)
                    
                    Text("解锁时间: \(formatDate(unlockDate))")
                        .font(.system(size: 14))
                        .foregroundColor(Color.secondaryText)
                }
                .padding(.bottom, 10)
            }
            
            Button(action: onDismiss) {
                Text("很好!")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(achievement.gradient)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: achievement.color.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.top, 10)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(colorScheme == .dark ? Color(hex: "2A2A2A") : Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(achievement.color.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 40)
        .onAppear {
            withAnimation {
                showAnimation = true
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

// Achievement detail view shown when tapping on an achievement card
public struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showAnimation = false
    @EnvironmentObject private var breakfastTracker: BreakfastTracker
    
    // 格式化日期的辅助方法
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    public var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(hex: "1A1A1A") : Color(hex: "F8F9FA"),
                    colorScheme == .dark ? Color(hex: "2D2D2D") : Color(hex: "FFFFFF")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // 类别标签
                        HStack {
                            Image(systemName: achievement.category.icon)
                                .font(.system(size: 14))
                                .foregroundColor(Color.forCategory(achievement.category).opacity(0.8))
                            
                            Text(achievement.category.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.forCategory(achievement.category).opacity(0.8))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.forCategory(achievement.category).opacity(0.1))
                        )
                        
                        // Achievement icon with animation
                        ZStack {
                            if achievement.isUnlocked {
                                // Animated rings for unlocked achievements
                                ForEach(0..<2, id: \.self) { ring in
                                    Circle()
                                        .stroke(achievement.color.opacity(0.2), lineWidth: 2)
                                        .frame(width: 120 + CGFloat(ring * 30), height: 120 + CGFloat(ring * 30))
                                        .scaleEffect(showAnimation ? 1.1 : 0.9)
                                        .opacity(showAnimation ? 0.4 : 0.8)
                                        .animation(
                                            Animation.easeInOut(duration: 2.0)
                                                .repeatForever(autoreverses: true)
                                                .delay(Double(ring) * 0.3),
                                            value: showAnimation
                                        )
                                }
                            }
                            
                            // Main circle
                            Circle()
                                .fill(achievement.isUnlocked ? 
                                      achievement.gradient : 
                                      LinearGradient(
                                        gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing))
                                .frame(width: 120, height: 120)
                                .shadow(color: achievement.isUnlocked ? achievement.color.opacity(0.3) : Color.clear, radius: 10, x: 0, y: 5)
                            
                            Image(systemName: achievement.icon)
                                .font(.system(size: 50, weight: .semibold))
                                .foregroundColor(achievement.isUnlocked ? .white : .gray)
                                .opacity(achievement.isUnlocked ? 1.0 : 0.7)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        
                        // Achievement name and status
                        VStack(spacing: 8) {
                            Text(achievement.name)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 6) {
                                if achievement.isUnlocked {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(Color.categoryConsistency)
                                        .font(.system(size: 16))
                                    
                                    Text("已解锁")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color.categoryConsistency)
                                    
                                    if let unlockDate = achievement.unlockDate {
                                        Text(" • ")
                                            .foregroundColor(Color.secondaryText)
                                        
                                        Text(formatDate(unlockDate))
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Color.secondaryText)
                                    }
                                } else {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(Color.secondaryText)
                                        .font(.system(size: 16))
                                    
                                    Text("未解锁 • 需连续\(achievement.requirement)天")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color.secondaryText)
                                }
                            }
                            
                            // 进度条（如果未解锁）
                            if !achievement.isUnlocked {
                                VStack(spacing: 8) {
                                    GeometryReader { geometry in
                                        HStack {
                                            Text("当前进度")
                                                .font(.system(size: 14))
                                                .foregroundColor(Color.secondaryText)
                                            
                                            Spacer()
                                            
                                            // 使用BreakfastTracker中的实际streak值
                                            Text("\(breakfastTracker.streakCount)/\(achievement.requirement)")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(Color.forCategory(achievement.category))
                                        }
                                        .frame(width: geometry.size.width * 0.9) // Match the progress bar width (90%)
                                        .frame(width: geometry.size.width, alignment: .center) // Center within the container
                                    }
                                    .frame(height: 20)
                                    .padding(.top, 4)

                                    // 进度条 - 与卡片宽度一致
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            // 背景轨道
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.progressBackground)
                                                .frame(width: geometry.size.width * 0.9, height: 8) // 90% of the container width
                                            
                                            // 进度条
                                            // 使用BreakfastTracker中的实际streak值，确保与日历记录逻辑一致
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.forCategory(achievement.category))
                                                .frame(width: CGFloat(achievement.progressPercentage(currentStreak: breakfastTracker.streakCount)) / 100.0 * geometry.size.width * 0.9, height: 8) // 90% of the container width
                                        }
                                        .frame(width: geometry.size.width, alignment: .center) // Center the progress bar
                                    }
                                    .frame(height: 8)
                                }
                                .padding(.top, 10)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Achievement description card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("成就详情")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color.forCategory(achievement.category))
                            
                            Text(achievement.description)
                                .font(.system(size: 16))
                                .foregroundColor(Color.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(4)
                            
                            if !achievement.isUnlocked {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("如何获得")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color.forCategory(achievement.category))
                                    
                                    HStack(spacing: 10) {
                                        Image(systemName: achievement.category.icon)
                                            .foregroundColor(Color.forCategory(achievement.category))
                                        
                                        Text("连续\(achievement.requirement)天记录早餐")
                                            .font(.system(size: 15))
                                    }
                                }
                                .padding(.top, 10)
                            } else if let unlockDate = achievement.unlockDate {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("解锁信息")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color.forCategory(achievement.category))
                                    
                                    HStack(spacing: 10) {
                                        Image(systemName: "calendar.badge.clock")
                                            .foregroundColor(Color.forCategory(achievement.category))
                                        
                                        Text("解锁时间: \(formatDate(unlockDate))")
                                            .font(.system(size: 15))
                                    }
                                }
                                .padding(.top, 10)
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(colorScheme == .dark ? Color(hex: "2A2A2A") : .white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.forCategory(achievement.category).opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        
                        // Tips or congratulations message
                        VStack(alignment: .leading, spacing: 16) {
                            Text(achievement.isUnlocked ? "恭喜你!" : "小贴士")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color.forCategory(achievement.category))
                            
                            Text(achievement.isUnlocked ? 
                                 "你已经成功解锁了这个成就，继续保持良好的早餐习惯吧！" : 
                                 "每天吃早餐对健康非常重要，坚持记录并养成良好的早餐习惯。")
                                .font(.system(size: 16))
                                .foregroundColor(Color.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(4)
                            
                            // 添加分享按钮（如果已解锁）
                            if achievement.isUnlocked {
                                Button(action: {
                                    // 分享成就逻辑
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 14))
                                        
                                        Text("分享成就")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.forCategory(achievement.category).opacity(0.1))
                                    )
                                    .foregroundColor(Color.forCategory(achievement.category))
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(colorScheme == .dark ? Color(hex: "2A2A2A") : .white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.primary.opacity(0.05), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 10)
                }
            }
        }
        .onAppear {
            withAnimation {
                showAnimation = true
            }
        }
    }
}
