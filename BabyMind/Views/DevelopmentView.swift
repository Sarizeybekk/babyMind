//
//  DevelopmentView.swift
//
//  Gelişim ekranı
//

import SwiftUI

struct DevelopmentView: View {
    let baby: Baby
    @ObservedObject var aiService: AIService
    
    var body: some View {
        DevelopmentalMilestonesView(baby: baby)
    }
}

#Preview {
    DevelopmentView(
        baby: Baby(
            name: "Bebek",
            birthDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
            gender: .male,
            birthWeight: 3.2,
            birthHeight: 50
        ),
        aiService: AIService()
    )
}
