//
//  ContentView.swift
//  EatBreakFirst
//
//  Created by Sheng Ma on 3/6/25.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @StateObject private var breakfastTracker = BreakfastTracker()
    @State private var hasEatenBreakfast: Bool? = nil
    @State private var showConfetti = false
    @State private var showStats = false
    @State private var showAchievements = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                    .ignoresSafeArea()
                    
                // These sheet modifiers need to be attached to a view, not floating in the ZStack
                
                VStack(spacing: 20) {
                    // Top toolbar using Apple's modern style
                    HStack {
                        Button(action: {
                            showStats.toggle()
                        }) {
                            Image(systemName: "chart.bar.fill")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.primary)
                                .font(.system(size: 22, weight: .medium))
                                .frame(width: 36, height: 36)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Button(action: {
                            showAchievements.toggle()
                        }) {
                            Image(systemName: "trophy.fill")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.primary)
                                .font(.system(size: 22, weight: .medium))
                                .frame(width: 36, height: 36)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    if hasEatenBreakfast == nil {
                        // Question View
                        VStack(spacing: 30) {
                            Text("今天吃了早餐吗？")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 5) {
                                Text("🥐 🍞 🥖")
                                    .font(.system(size: 60))
                                    .padding(.vertical, 20)
                            }
                            .padding(.bottom, 20)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 14) {
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    hasEatenBreakfast = true
                                    showConfetti = true
                                    breakfastTracker.recordBreakfast(eaten: true)
                                }
                            }) {
                                Label("吃了", systemImage: "checkmark.circle.fill")
                                    .font(.system(size: 17, weight: .semibold))
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .tint(.accentColor)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    hasEatenBreakfast = false
                                    breakfastTracker.recordBreakfast(eaten: false)
                                }
                            }) {
                                Label("没吃", systemImage: "x.circle.fill")
                                    .font(.system(size: 17, weight: .semibold))
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                            .tint(.primary)
                        }
                        .padding(.horizontal, 30)
                    } else if hasEatenBreakfast == true {
                        // Success View
                        VStack(spacing: 30) {
                            // Streak counter
                            VStack(spacing: 5) {
                                Text("连续 \(breakfastTracker.streakCount) 天吃了早饭")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1.5)
                                    )
                            }
                            .padding(.bottom, 10)
                            
                            HStack(spacing: 35) {
                                Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .font(.system(size: 65, weight: .medium))
                                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                                
                                Image(systemName: "face.smiling.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .foregroundStyle(.yellow)
                                    .font(.system(size: 65, weight: .medium))
                                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            }
                            .padding(.top, 5)
                            
                            Text("恭喜你！")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                            
                            Text("保持健康的早餐习惯")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            // Calendar view with card-like design
                            CalendarView(breakfastTracker: breakfastTracker)
                                .frame(height: 280)
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
                                )
                                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                                .padding(.top, 10)
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        hasEatenBreakfast = nil
                                        showConfetti = false
                                    }
                                }) {
                                    Text("返回")
                                        .font(.system(size: 17, weight: .medium))
                                        .frame(width: 120)
                                        .padding(.vertical, 12)
                                        .background(.ultraThinMaterial)
                                        .foregroundColor(.primary)
                                        .cornerRadius(18)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
                                        )
                                        .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                            .padding(.top, 10)
                        }
                        .padding(.horizontal)
                    } else {
                        // Reminder View
                        VStack(spacing: 30) {
                            HStack(spacing: 35) {
                                Image(systemName: "clock.badge.exclamationmark.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .font(.system(size: 65, weight: .medium))
                                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                                
                                Image(systemName: "carrot.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.orange)
                                    .font(.system(size: 65, weight: .medium))
                                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            }
                            
                            Text("明天要记得吃早饭")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                            
                            Text("健康的一天从早餐开始")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    hasEatenBreakfast = nil
                                }
                            }) {
                                Text("返回")
                                    .font(.system(size: 17, weight: .medium))
                                    .frame(width: 120)
                                    .padding(.vertical, 12)
                                    .background(.ultraThinMaterial)
                                    .foregroundColor(.primary)
                                    .cornerRadius(18)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
                                    )
                                    .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .padding(.top, 20)
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
                            withAnimation {
                                breakfastTracker.showAchievementUnlocked = false
                            }
                        }
                        Spacer()
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: breakfastTracker.showAchievementUnlocked)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showStats) {
            StatsView(stats: breakfastTracker.calculateStats())
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView(achievements: breakfastTracker.achievements)
        }

    }
}

#Preview {
    ContentView()
}


