//
//  StyleComponents.swift
//  EatBreakFirst
//
//  Created on 3/6/25.
//

import SwiftUI

public struct ScaleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

public struct BackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    public var body: some View {
        ZStack {
            // Base color that respects light/dark mode
            Color(UIColor.systemBackground)
            
            // Morning sunrise gradient
            GeometryReader { geometry in
                ZStack {
                    if colorScheme == .dark {
                        // Dark mode sunrise colors (more subdued)
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.1, green: 0.1, blue: 0.2),      // Deep night blue
                                Color(red: 0.2, green: 0.12, blue: 0.18),    // Deep purple
                                Color(red: 0.25, green: 0.15, blue: 0.12),   // Deep amber
                                Color(red: 0.2, green: 0.1, blue: 0.05)      // Deep orange
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        // Light mode sunrise colors (vibrant)
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.7, green: 0.85, blue: 0.98),    // Light blue sky
                                Color(red: 0.82, green: 0.9, blue: 0.95),    // Pale blue
                                Color(red: 0.98, green: 0.82, blue: 0.7),    // Pale orange
                                Color(red: 0.98, green: 0.75, blue: 0.52)    // Warm orange
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    
                    // Sun glow effect (positioned near bottom in both modes)
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    colorScheme == .dark ? 
                                        Color(red: 0.6, green: 0.3, blue: 0.1).opacity(0.7) : 
                                        Color(red: 1.0, green: 0.9, blue: 0.6).opacity(0.8),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: geometry.size.width * 0.05,
                                endRadius: geometry.size.width * 0.6
                            )
                        )
                        .frame(width: geometry.size.width * 1.2, height: geometry.size.width * 1.2)
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.85)
                    
                    // Cloud-like elements (subtle in both modes)
                    Group {
                        Ellipse()
                            .fill(colorScheme == .dark ? 
                                 Color.white.opacity(0.04) : 
                                 Color.white.opacity(0.5))
                            .frame(width: geometry.size.width * 0.45, height: geometry.size.width * 0.15)
                            .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.32)
                            .blur(radius: 15)
                        
                        Ellipse()
                            .fill(colorScheme == .dark ? 
                                 Color.white.opacity(0.03) : 
                                 Color.white.opacity(0.4))
                            .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.18)
                            .position(x: geometry.size.width * 0.3, y: geometry.size.height * 0.25)
                            .blur(radius: 18)
                    }
                }
            }
        }
    }
}
