//
//  PostpartumDepressionRecord.swift
//
//  Doğum sonrası depresyon risk analizi modeli
//

import Foundation

struct PostpartumDepressionRecord: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let date: Date
    let moodScore: Int // 1-5 (1: Çok kötü, 5: Çok iyi)
    let sleepHours: Double
    let cryingUrge: Int // 1-5 (1: Hiç yok, 5: Çok fazla)
    let anxietyLevel: Int // 1-5 (1: Hiç yok, 5: Çok yüksek)
    let hopelessnessLevel: Int // 1-5 (1: Hiç yok, 5: Çok yüksek)
    let socialSupport: Int // 1-5 (1: Çok az, 5: Çok iyi)
    let notes: String?
    
    var overallScore: Double {
        // Ters skorlar: mood ve socialSupport yüksek olmalı, diğerleri düşük
        let normalizedMood = Double(moodScore) / 5.0
        let normalizedSocial = Double(socialSupport) / 5.0
        let normalizedCrying = (6.0 - Double(cryingUrge)) / 5.0
        let normalizedAnxiety = (6.0 - Double(anxietyLevel)) / 5.0
        let normalizedHopelessness = (6.0 - Double(hopelessnessLevel)) / 5.0
        
        // Ağırlıklı ortalama
        return (normalizedMood * 0.25) +
               (normalizedSocial * 0.20) +
               (normalizedCrying * 0.20) +
               (normalizedAnxiety * 0.20) +
               (normalizedHopelessness * 0.15)
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         date: Date = Date(),
         moodScore: Int,
         sleepHours: Double,
         cryingUrge: Int,
         anxietyLevel: Int,
         hopelessnessLevel: Int,
         socialSupport: Int,
         notes: String? = nil) {
        self.id = id
        self.babyId = babyId
        self.date = date
        self.moodScore = moodScore
        self.sleepHours = sleepHours
        self.cryingUrge = cryingUrge
        self.anxietyLevel = anxietyLevel
        self.hopelessnessLevel = hopelessnessLevel
        self.socialSupport = socialSupport
        self.notes = notes
    }
}

struct DepressionRiskAnalysis {
    let riskLevel: RiskLevel
    let score: Double // 0-1 (1 = en yüksek risk)
    let trend: Trend
    let message: String
    let recommendations: [String]
    let analysisDate: Date
    
    enum RiskLevel: String {
        case normal = "Normal"
        case monitor = "Takip Edilmeli"
        case highRisk = "Yüksek Risk"
        
        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .normal: return (0.2, 0.8, 0.4) // Yeşil
            case .monitor: return (1.0, 0.7, 0.3) // Turuncu
            case .highRisk: return (1.0, 0.3, 0.3) // Kırmızı
            }
        }
        
        var emoji: String {
            switch self {
            case .normal: return "🟢"
            case .monitor: return "🟡"
            case .highRisk: return "🔴"
            }
        }
    }
    
    enum Trend: String {
        case improving = "İyileşiyor"
        case stable = "Stabil"
        case declining = "Düşüş Eğilimi"
        case critical = "Kritik Düşüş"
    }
}
