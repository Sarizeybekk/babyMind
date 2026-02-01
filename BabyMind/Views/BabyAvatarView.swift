//
//  BabyAvatarView.swift
//  BabyMind
//
//  Kişiselleştirilmiş bebek avatarı
//

import SwiftUI

struct BabyAvatarView: View {
    let baby: Baby
    @State private var animationOffset: CGFloat = 0
    @State private var isAnimating = false
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    var avatarColor: Color {
        theme.primary
    }
    
    var body: some View {
        ZStack {
            // Arka plan daire
            Circle()
                .fill(
                    LinearGradient(
                        colors: [avatarColor.opacity(0.2), avatarColor.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // Avatar
            ZStack {
                // Baş
                Circle()
                    .fill(avatarColor.opacity(0.3))
                    .frame(width: 80, height: 80)
                
                // Gözler
                HStack(spacing: 12) {
                    Circle()
                        .fill(theme.text)
                        .frame(width: 8, height: 8)
                        .offset(y: animationOffset)
                    
                    Circle()
                        .fill(theme.text)
                        .frame(width: 8, height: 8)
                        .offset(y: animationOffset)
                }
                .offset(y: -8)
                
                // Ağız (gülümseme)
                Path { path in
                    path.move(to: CGPoint(x: -12, y: 8))
                    path.addQuadCurve(
                        to: CGPoint(x: 12, y: 8),
                        control: CGPoint(x: 0, y: 16)
                    )
                }
                .stroke(theme.text, lineWidth: 2)
                .offset(y: 8)
            }
        }
        .onAppear {
            isAnimating = true
            startEyeAnimation()
        }
    }
    
    private func startEyeAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true)
        ) {
            animationOffset = -2
        }
    }
}

struct AnimatedBabyAvatar: View {
    let baby: Baby
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    var body: some View {
        BabyAvatarView(baby: baby)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 3.0)
                        .repeatForever(autoreverses: true)
                ) {
                    rotation = 5
                    scale = 1.05
                }
            }
    }
}

// Gelişim aşamasına göre avatar
struct DevelopmentStageAvatar: View {
    let baby: Baby
    let stage: DevelopmentStage
    
    enum DevelopmentStage {
        case newborn // 0-3 ay
        case infant // 3-6 ay
        case sitting // 6-9 ay
        case crawling // 9-12 ay
        case walking // 12+ ay
    }
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    var body: some View {
        ZStack {
            BabyAvatarView(baby: baby)
            
            // Gelişim aşamasına göre ek özellikler
            switch stage {
            case .newborn:
                // Yeni doğan - küçük ve basit
                EmptyView()
            case .infant:
                // Bebek - daha aktif
                Circle()
                    .stroke(theme.primary, lineWidth: 2)
                    .frame(width: 100, height: 100)
                    .opacity(0.3)
            case .sitting:
                // Oturma - daha büyük
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.primary.opacity(0.2))
                    .frame(width: 60, height: 40)
                    .offset(y: 30)
            case .crawling:
                // Emekleme - hareketli
                HStack(spacing: 4) {
                    Circle()
                        .fill(theme.primary.opacity(0.3))
                        .frame(width: 12, height: 12)
                    Circle()
                        .fill(theme.primary.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
                .offset(y: 35)
            case .walking:
                // Yürüme - en aktif
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(theme.primary.opacity(0.4))
                            .frame(width: 10, height: 10)
                        Circle()
                            .fill(theme.primary.opacity(0.4))
                            .frame(width: 10, height: 10)
                    }
                    HStack(spacing: 4) {
                        Circle()
                            .fill(theme.primary.opacity(0.4))
                            .frame(width: 10, height: 10)
                        Circle()
                            .fill(theme.primary.opacity(0.4))
                            .frame(width: 10, height: 10)
                    }
                }
                .offset(y: 40)
            }
        }
    }
    
    static func stage(for baby: Baby) -> DevelopmentStage {
        let ageInMonths = baby.ageInMonths
        
        if ageInMonths < 3 {
            return .newborn
        } else if ageInMonths < 6 {
            return .infant
        } else if ageInMonths < 9 {
            return .sitting
        } else if ageInMonths < 12 {
            return .crawling
        } else {
            return .walking
        }
    }
}







