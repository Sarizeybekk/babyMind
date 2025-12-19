//
//  SleepAnalysisService.swift
//
//  Uyku analizi servisi
//

import Foundation
import Combine

class SleepAnalysisService: ObservableObject {
    @Published var sleepRecords: [SleepRecord] = []
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadRecords()
    }
    
    func addRecord(_ record: SleepRecord) {
        sleepRecords.append(record)
        sleepRecords.sort { $0.startTime > $1.startTime }
        saveRecords()
    }
    
    func updateRecord(_ record: SleepRecord) {
        if let index = sleepRecords.firstIndex(where: { $0.id == record.id }) {
            sleepRecords[index] = record
            sleepRecords.sort { $0.startTime > $1.startTime }
            saveRecords()
        }
    }
    
    func deleteRecord(_ record: SleepRecord) {
        sleepRecords.removeAll { $0.id == record.id }
        saveRecords()
    }
    
    func endCurrentSleep(endTime: Date = Date(), quality: SleepRecord.SleepQuality? = nil, wakeCount: Int = 0, notes: String? = nil) {
        if let index = sleepRecords.firstIndex(where: { $0.endTime == nil }) {
            var record = sleepRecords[index]
            record.endTime = endTime
            record.quality = quality
            record.wakeCount = wakeCount
            record.notes = notes
            sleepRecords[index] = record
            saveRecords()
        }
    }
    
    // MARK: - Analiz Fonksiyonları
    
    func getAverageSleepQuality() -> Double {
        let completedRecords = sleepRecords.filter { $0.endTime != nil && $0.quality != nil }
        guard !completedRecords.isEmpty else { return 0 }
        
        let totalScore = completedRecords.compactMap { $0.quality?.score }.reduce(0, +)
        return Double(totalScore) / Double(completedRecords.count)
    }
    
    func getWeeklySleepPattern() -> [Date: Double] {
        let calendar = Calendar.current
        var pattern: [Date: Double] = [:]
        
        let last7Days = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentRecords = sleepRecords.filter { $0.startTime >= last7Days && $0.endTime != nil }
        
        for record in recentRecords {
            guard let endTime = record.endTime,
                  let duration = record.durationInHours else { continue }
            
            let day = calendar.startOfDay(for: record.startTime)
            pattern[day, default: 0] += duration
        }
        
        return pattern
    }
    
    func getOptimalSleepHours() -> (start: Int, end: Int) {
        // Yaşa göre optimal uyku saatleri
        let ageInWeeks = getBabyAgeInWeeks()
        
        if ageInWeeks < 4 {
            return (20, 7) // 20:00 - 07:00
        } else if ageInWeeks < 12 {
            return (19, 6) // 19:00 - 06:00
        } else if ageInWeeks < 24 {
            return (19, 7) // 19:00 - 07:00
        } else {
            return (20, 7) // 20:00 - 07:00
        }
    }
    
    func getNightWakeCount(day: Date = Date()) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: day)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        
        let nightRecords = sleepRecords.filter { record in
            record.sleepType == .night &&
            record.startTime >= startOfDay &&
            record.startTime < endOfDay &&
            record.endTime != nil
        }
        
        return nightRecords.reduce(0) { $0 + $1.wakeCount }
    }
    
    func getAverageNightWakeCount(days: Int = 7) -> Double {
        let calendar = Calendar.current
        var totalWakes = 0
        var dayCount = 0
        
        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                totalWakes += getNightWakeCount(day: date)
                dayCount += 1
            }
        }
        
        return dayCount > 0 ? Double(totalWakes) / Double(dayCount) : 0
    }
    
    func getDailySleepTotal(day: Date = Date()) -> Double {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: day)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        
        let dayRecords = sleepRecords.filter { record in
            record.startTime >= startOfDay &&
            record.startTime < endOfDay &&
            record.endTime != nil
        }
        
        return dayRecords.compactMap { $0.durationInHours }.reduce(0, +)
    }
    
    func getRecommendedDailySleep() -> (min: Double, max: Double) {
        let ageInWeeks = getBabyAgeInWeeks()
        
        if ageInWeeks < 4 {
            return (14, 17)
        } else if ageInWeeks < 12 {
            return (12, 16)
        } else {
            return (11, 14)
        }
    }
    
    func setBabyAge(_ ageInWeeks: Int) {
        // Baby yaşını set etmek için (opsiyonel)
    }
    
    private func getBabyAgeInWeeks() -> Int {
        // Bu fonksiyon Baby modelinden yaş bilgisini almalı
        // Şimdilik varsayılan değer döndürüyoruz
        return 8
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(sleepRecords) {
            UserDefaults.standard.set(encoded, forKey: "sleepRecords_\(babyId.uuidString)")
        }
    }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: "sleepRecords_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([SleepRecord].self, from: data) {
            sleepRecords = decoded.sorted { $0.startTime > $1.startTime }
        }
    }
}
