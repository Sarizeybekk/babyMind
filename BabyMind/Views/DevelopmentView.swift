//
//  DevelopmentView.swift
//  BabyMind
//
//  Gelişim ekranı
//

import SwiftUI

struct DevelopmentView: View {
    let baby: Baby
    @ObservedObject var aiService: AIService
    @State private var recommendation: Recommendation?
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let recommendation = recommendation {
                        RecommendationCard(recommendation: recommendation)
                            .padding()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Gelişim Aşamaları")
                            .font(.headline)
                        
                        DevelopmentMilestoneCard(
                            title: "Fiziksel Gelişim",
                            milestones: getPhysicalMilestones()
                        )
                        
                        DevelopmentMilestoneCard(
                            title: "Bilişsel Gelişim",
                            milestones: getCognitiveMilestones()
                        )
                        
                        DevelopmentMilestoneCard(
                            title: "Sosyal Gelişim",
                            milestones: getSocialMilestones()
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Gelişim")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadRecommendation()
            }
        }
    }
    
    private func loadRecommendation() {
        isLoading = true
        Task {
            do {
                let rec = try await aiService.getRecommendation(for: baby, category: .development)
                await MainActor.run {
                    recommendation = rec
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    private func getPhysicalMilestones() -> [String] {
        let ageInWeeks = baby.ageInWeeks
        if ageInWeeks < 4 {
            return ["Başını kaldırabilir", "Yüzükoyun yatarken başını çevirebilir"]
        } else if ageInWeeks < 8 {
            return ["Başını daha iyi kontrol eder", "Kollarını hareket ettirebilir"]
        } else {
            return ["Oturma pozisyonuna geçmeye çalışır", "Nesnelere uzanabilir"]
        }
    }
    
    private func getCognitiveMilestones() -> [String] {
        let ageInWeeks = baby.ageInWeeks
        if ageInWeeks < 4 {
            return ["Yüzlere odaklanır", "Seslere tepki verir"]
        } else if ageInWeeks < 8 {
            return ["Renkleri ayırt edebilir", "Nesneleri takip edebilir"]
        } else {
            return ["Neden-sonuç ilişkisi kurmaya başlar", "Oyuncaklarla oynar"]
        }
    }
    
    private func getSocialMilestones() -> [String] {
        let ageInWeeks = baby.ageInWeeks
        if ageInWeeks < 4 {
            return ["Gülümser", "Seslere tepki verir"]
        } else if ageInWeeks < 8 {
            return ["Tanıdık yüzlere gülümser", "Farklı sesler çıkarır"]
        } else {
            return ["Yabancıları ayırt eder", "İletişim kurmaya çalışır"]
        }
    }
}

struct DevelopmentMilestoneCard: View {
    let title: String
    let milestones: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
            
            ForEach(milestones, id: \.self) { milestone in
                HStack(alignment: .top) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text(milestone)
                        .font(.subheadline)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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

