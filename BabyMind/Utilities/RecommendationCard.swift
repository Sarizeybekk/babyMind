//
//  RecommendationCard.swift
//  BabyMind
//
//  AI öneri kartı component'i
//

import SwiftUI

struct RecommendationCard: View {
    let recommendation: Recommendation
    
    private var priorityColor: Color {
        switch recommendation.priority {
        case .low:
            return .green
        case .medium:
            return .blue
        case .high:
            return .orange
        case .urgent:
            return .red
        }
    }
    
    private var categoryIcon: String {
        switch recommendation.category {
        case .feeding:
            return "fork.knife"
        case .sleep:
            return "bed.double.fill"
        case .development:
            return "chart.line.uptrend.xyaxis"
        case .health:
            return "heart.text.square.fill"
        case .general:
            return "lightbulb.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: categoryIcon)
                    .font(.title2)
                    .foregroundColor(priorityColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(recommendation.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Öncelik göstergesi
                Circle()
                    .fill(priorityColor)
                    .frame(width: 12, height: 12)
            }
            
            Text(recommendation.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    RecommendationCard(
        recommendation: Recommendation(
            category: .feeding,
            title: "Beslenme Önerisi",
            description: "Bebeğiniz için özel beslenme önerileri hazırlandı.",
            priority: .high
        )
    )
    .padding()
}
