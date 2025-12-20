//
//  GrowthPercentileService.swift
//
//  Büyüme persentil servisi
//

import Foundation
import Combine

class GrowthPercentileService: ObservableObject {
    @Published var growthRecords: [GrowthRecord] = []
    private let babyId: UUID
    private let isMale: Bool
    
    init(babyId: UUID, isMale: Bool) {
        self.babyId = babyId
        self.isMale = isMale
        loadRecords()
    }
    
    func addRecord(_ record: GrowthRecord) {
        growthRecords.append(record)
        growthRecords.sort { $0.date < $1.date }
        saveRecords()
    }
    
    func deleteRecord(_ record: GrowthRecord) {
        growthRecords.removeAll { $0.id == record.id }
        saveRecords()
    }
    
    func getGrowthTrend(metric: GrowthMetric) -> [Date: Double] {
        var trend: [Date: Double] = [:]
        
        for record in growthRecords {
            let value: Double
            switch metric {
            case .weight:
                value = record.weight
            case .height:
                value = record.height
            case .headCircumference:
                value = record.headCircumference ?? 0
            }
            trend[record.date] = value
        }
        
        return trend
    }
    
    func getGrowthRate(metric: GrowthMetric, days: Int = 30) -> Double? {
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) else {
            return nil
        }
        
        let recentRecords = growthRecords.filter { $0.date >= cutoffDate }.sorted { $0.date < $1.date }
        guard recentRecords.count >= 2 else { return nil }
        
        let first = recentRecords.first!
        let last = recentRecords.last!
        
        let valueDiff: Double
        let dayDiff = calendar.dateComponents([.day], from: first.date, to: last.date).day ?? 1
        
        switch metric {
        case .weight:
            valueDiff = last.weight - first.weight
        case .height:
            valueDiff = last.height - first.height
        case .headCircumference:
            guard let firstHC = first.headCircumference, let lastHC = last.headCircumference else { return nil }
            valueDiff = lastHC - firstHC
        }
        
        return dayDiff > 0 ? (valueDiff / Double(dayDiff)) * 30.0 : nil // Aylık büyüme hızı
    }
    
    func checkAbnormalGrowth() -> [GrowthAlert] {
        var alerts: [GrowthAlert] = []
        
        guard let latest = growthRecords.last else { return alerts }
        
        // Persentil kontrolü
        let weightPercentile = latest.getWeightPercentile(isMale: isMale)
        if weightPercentile < 5 {
            alerts.append(GrowthAlert(
                type: .lowWeight,
                message: "Ağırlık persentili düşük (%\(Int(weightPercentile))). Doktorunuzla görüşmeniz önerilir."
            ))
        } else if weightPercentile > 95 {
            alerts.append(GrowthAlert(
                type: .highWeight,
                message: "Ağırlık persentili yüksek (%\(Int(weightPercentile))). Doktorunuzla görüşmeniz önerilir."
            ))
        }
        
        let heightPercentile = latest.getHeightPercentile(isMale: isMale)
        if heightPercentile < 5 {
            alerts.append(GrowthAlert(
                type: .lowHeight,
                message: "Boy persentili düşük (%\(Int(heightPercentile))). Doktorunuzla görüşmeniz önerilir."
            ))
        }
        
        // Büyüme hızı kontrolü
        if let weightRate = getGrowthRate(metric: .weight) {
            if weightRate < 0 {
                alerts.append(GrowthAlert(
                    type: .slowGrowth,
                    message: "Ağırlık artışı yavaş. Doktorunuzla görüşmeniz önerilir."
                ))
            }
        }
        
        return alerts
    }
    
    enum GrowthMetric {
        case weight
        case height
        case headCircumference
    }
    
    struct GrowthAlert {
        let type: AlertType
        let message: String
        
        enum AlertType {
            case lowWeight
            case highWeight
            case lowHeight
            case slowGrowth
        }
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(growthRecords) {
            UserDefaults.standard.set(encoded, forKey: "growthRecords_\(babyId.uuidString)")
        }
    }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: "growthRecords_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([GrowthRecord].self, from: data) {
            growthRecords = decoded.sorted { $0.date < $1.date }
        }
    }
}
