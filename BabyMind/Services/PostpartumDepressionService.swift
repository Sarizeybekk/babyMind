//
//  PostpartumDepressionService.swift
//
//  Doğum sonrası depresyon risk analizi servisi (AI destekli)
//

import Foundation
import Combine

class PostpartumDepressionService: ObservableObject {
    @Published var records: [PostpartumDepressionRecord] = []
    @Published var currentAnalysis: DepressionRiskAnalysis?
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadRecords()
        analyzeRisk()
    }
    
    func addRecord(_ record: PostpartumDepressionRecord) {
        records.append(record)
        records.sort { $0.date > $1.date }
        saveRecords()
        analyzeRisk()
    }
    
    func deleteRecord(_ record: PostpartumDepressionRecord) {
        records.removeAll { $0.id == record.id }
        saveRecords()
        analyzeRisk()
    }
    
    func analyzeRisk() {
        guard !records.isEmpty else {
            currentAnalysis = nil
            return
        }
        
        // Son 14 günlük verileri al
        let calendar = Calendar.current
        let fourteenDaysAgo = calendar.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        let recentRecords = records.filter { $0.date >= fourteenDaysAgo }.sorted { $0.date < $1.date }
        
        guard !recentRecords.isEmpty else {
            currentAnalysis = nil
            return
        }
        
        // Zaman serisi analizi
        let scores = recentRecords.map { $0.overallScore }
        let averageScore = scores.reduce(0, +) / Double(scores.count)
        let latestScore = recentRecords.last!.overallScore
        
        // Trend analizi
        let trend = calculateTrend(scores: scores)
        
        // Risk seviyesi belirleme
        let riskLevel: DepressionRiskAnalysis.RiskLevel
        let riskScore: Double
        
        if averageScore >= 0.7 && latestScore >= 0.65 {
            riskLevel = .normal
            riskScore = 1.0 - averageScore
        } else if averageScore >= 0.5 || (averageScore >= 0.6 && trend == .declining) {
            riskLevel = .monitor
            riskScore = 1.0 - averageScore
        } else {
            riskLevel = .highRisk
            riskScore = 1.0 - averageScore
        }
        
        // Mesaj oluşturma
        let message = generateMessage(
            riskLevel: riskLevel,
            trend: trend,
            days: recentRecords.count,
            averageScore: averageScore
        )
        
        // Öneriler
        let recommendations = generateRecommendations(riskLevel: riskLevel, trend: trend)
        
        currentAnalysis = DepressionRiskAnalysis(
            riskLevel: riskLevel,
            score: riskScore,
            trend: trend,
            message: message,
            recommendations: recommendations,
            analysisDate: Date()
        )
    }
    
    private func calculateTrend(scores: [Double]) -> DepressionRiskAnalysis.Trend {
        guard scores.count >= 3 else { return .stable }
        
        // İlk yarı ve son yarı karşılaştırması
        let midPoint = scores.count / 2
        let firstHalf = Array(scores.prefix(midPoint))
        let secondHalf = Array(scores.suffix(scores.count - midPoint))
        
        let firstAvg = firstHalf.reduce(0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.reduce(0, +) / Double(secondHalf.count)
        
        let difference = secondAvg - firstAvg
        
        if difference > 0.1 {
            return .improving
        } else if difference < -0.15 {
            return .critical
        } else if difference < -0.05 {
            return .declining
        } else {
            return .stable
        }
    }
    
    private func generateMessage(
        riskLevel: DepressionRiskAnalysis.RiskLevel,
        trend: DepressionRiskAnalysis.Trend,
        days: Int,
        averageScore: Double
    ) -> String {
        switch (riskLevel, trend) {
        case (.normal, _):
            return "Genel durumunuz normal görünüyor. Kendinize iyi bakmaya devam edin."
            
        case (.monitor, .declining):
            return "Son \(days) gündür ruh hali düşüş eğilimi gösteriyor. Destek almanız önerilir."
            
        case (.monitor, .stable):
            return "Durumunuz takip edilmeli. Düzenli kontrol ve destek önemlidir."
            
        case (.monitor, .improving):
            return "Durumunuz iyileşme eğiliminde. Bu olumlu bir gelişme."
            
        case (.highRisk, .critical):
            return "Kritik düşüş tespit edildi. Derhal profesyonel destek almanız önerilir."
            
        case (.highRisk, .declining):
            return "Yüksek risk seviyesi tespit edildi. Profesyonel yardım almanız önerilir."
            
        case (.highRisk, _):
            return "Yüksek risk seviyesi. Mutlaka bir sağlık uzmanına danışın."
            
        default:
            return "Durumunuz değerlendiriliyor."
        }
    }
    
    private func generateRecommendations(
        riskLevel: DepressionRiskAnalysis.RiskLevel,
        trend: DepressionRiskAnalysis.Trend
    ) -> [String] {
        var recommendations: [String] = []
        
        switch riskLevel {
        case .normal:
            recommendations.append("Düzenli egzersiz yapın (hafif yürüyüş)")
            recommendations.append("Yeterli uyku almaya çalışın")
            recommendations.append("Sosyal destek ağınızı koruyun")
            
        case .monitor:
            recommendations.append("Bir sağlık uzmanına danışın")
            recommendations.append("Aile ve arkadaşlardan destek isteyin")
            recommendations.append("Günlük rutinler oluşturun")
            recommendations.append("Kendinize zaman ayırın")
            
        case .highRisk:
            recommendations.append("Derhal bir doktora veya psikologa başvurun")
            recommendations.append("Acil durum hattını arayın: 112 veya 182")
            recommendations.append("Yakınlarınızdan destek isteyin")
            recommendations.append("Yalnız kalmamaya çalışın")
            recommendations.append("Profesyonel yardım alın")
        }
        
        if trend == .declining || trend == .critical {
            recommendations.insert("Durumunuz kötüleşiyor - acil destek alın", at: 0)
        }
        
        return recommendations
    }
    
    func getWeeklyTrend() -> [Date: Double] {
        var trend: [Date: Double] = [:]
        let calendar = Calendar.current
        
        for record in records {
            let dayStart = calendar.startOfDay(for: record.date)
            if trend[dayStart] == nil {
                trend[dayStart] = record.overallScore
            } else {
                // Aynı gün için ortalama al
                trend[dayStart] = (trend[dayStart]! + record.overallScore) / 2.0
            }
        }
        
        return trend
    }
    
    func hasRecordToday() -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return records.contains { calendar.startOfDay(for: $0.date) == today }
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: "ppdRecords_\(babyId.uuidString)")
        }
    }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: "ppdRecords_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([PostpartumDepressionRecord].self, from: data) {
            records = decoded.sorted { $0.date > $1.date }
        }
    }
}
