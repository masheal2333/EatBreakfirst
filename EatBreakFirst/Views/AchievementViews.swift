//
//  AchievementViews.swift
//  EatBreakFirst
//
//  Created on 3/6/25.
//

import SwiftUI

// Achievement Views
public struct AchievementsView: View {
    let achievements: [Achievement]
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationView {
            List {
                ForEach(achievements) { achievement in
                    HStack {
                        ZStack {
                            Circle()
                                .fill(achievement.isUnlocked ? Color.accentColor : Color.gray.opacity(0.3))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: achievement.icon)
                                .font(.system(size: 20))
                                .foregroundColor(achievement.isUnlocked ? .white : .gray)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(achievement.name)
                                .font(.headline)
                            
                            Text(achievement.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if achievement.isUnlocked {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Text("连续\(achievement.requirement)天")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    .opacity(achievement.isUnlocked ? 1.0 : 0.6)
                }
            }
            .navigationTitle("成就")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

public struct AchievementUnlockedView: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("成就解锁！")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 80, height: 80)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 8)
            
            Text(achievement.name)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(achievement.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onDismiss) {
                Text("很好!")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 40)
    }
}
