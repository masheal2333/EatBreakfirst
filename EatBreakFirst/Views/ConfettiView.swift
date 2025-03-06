//
//  ConfettiView.swift
//  EatBreakFirst
//
//  Created on 3/6/25.
//

import SwiftUI

public struct ConfettiView: View {
    @State private var confettiPieces = [ConfettiPiece]()
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    public var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                Circle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
                    .position(piece.position)
                    .opacity(piece.opacity)
            }
        }
        .onAppear {
            generateConfetti()
        }
        .onReceive(timer) { _ in
            updateConfetti()
        }
    }
    
    public func generateConfetti() {
        for _ in 0..<100 {
            let randomX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
            let randomY = CGFloat.random(in: 0...100)
            let randomSize = CGFloat.random(in: 5...15)
            let randomColor = colors.randomElement() ?? .red
            let randomVelocity = CGFloat.random(in: 2...5)
            let randomRotationSpeed = CGFloat.random(in: -0.1...0.1)
            
            let piece = ConfettiPiece(
                position: CGPoint(x: randomX, y: randomY),
                size: randomSize,
                color: randomColor,
                velocity: randomVelocity,
                rotationSpeed: randomRotationSpeed
            )
            confettiPieces.append(piece)
        }
    }
    
    public func updateConfetti() {
        for i in 0..<confettiPieces.count {
            if i < confettiPieces.count {
                var piece = confettiPieces[i]
                piece.position.y += piece.velocity
                piece.rotation += piece.rotationSpeed
                
                if piece.position.y > UIScreen.main.bounds.height {
                    piece.opacity -= 0.02
                }
                
                confettiPieces[i] = piece
                
                if piece.opacity <= 0 {
                    confettiPieces.remove(at: i)
                }
            }
        }
    }
}

public struct ConfettiPiece: Identifiable {
    public let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var velocity: CGFloat
    var rotation: CGFloat = 0
    var rotationSpeed: CGFloat
    var opacity: CGFloat = 1.0
}
