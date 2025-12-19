//
//  ColorTheme.swift
//  BabyMind
//
//  Bebeğin cinsiyetine göre renk teması
//

import SwiftUI

struct ColorTheme {
    let primary: Color
    let primaryLight: Color
    let primaryDark: Color
    let secondary: Color
    let accent: Color
    let backgroundGradient: [Color]
    let cardGradient: [Color]
    let text: Color
    let cardShadow: Color
    
    static func theme(for gender: Baby.Gender) -> ColorTheme {
        switch gender {
        case .male:
            return ColorTheme(
                primary: Color(red: 0.0, green: 0.48, blue: 1.0), // Mavi (belirgin mavi)
                primaryLight: Color(red: 0.3, green: 0.7, blue: 1.0),
                primaryDark: Color(red: 0.0, green: 0.35, blue: 0.85),
                secondary: Color(red: 0.3, green: 0.7, blue: 0.95),
                accent: Color(red: 0.2, green: 0.6, blue: 1.0),
                backgroundGradient: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.92, green: 0.95, blue: 0.98),
                    Color.white
                ],
                cardGradient: [
                    Color(red: 0.4, green: 0.7, blue: 1.0),
                    Color(red: 0.3, green: 0.6, blue: 0.95)
                ],
                text: Color(red: 0.2, green: 0.3, blue: 0.4),
                cardShadow: Color.blue.opacity(0.1)
            )
        case .female:
            return ColorTheme(
                primary: Color(red: 1.0, green: 0.18, blue: 0.58), // Pembe (belirgin pembe)
                primaryLight: Color(red: 1.0, green: 0.6, blue: 0.8),
                primaryDark: Color(red: 0.85, green: 0.1, blue: 0.45),
                secondary: Color(red: 0.95, green: 0.6, blue: 0.8),
                accent: Color(red: 1.0, green: 0.5, blue: 0.7),
                backgroundGradient: [
                    Color(red: 1.0, green: 0.95, blue: 0.98),
                    Color(red: 0.98, green: 0.92, blue: 0.96),
                    Color.white
                ],
                cardGradient: [
                    Color(red: 1.0, green: 0.7, blue: 0.85),
                    Color(red: 0.95, green: 0.6, blue: 0.8)
                ],
                text: Color(red: 0.3, green: 0.2, blue: 0.25),
                cardShadow: Color.pink.opacity(0.1)
            )
        }
    }
}

extension View {
    func themeColors(for gender: Baby.Gender) -> ColorTheme {
        ColorTheme.theme(for: gender)
    }
}

