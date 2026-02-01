//
//  FeverService.swift
//  BabyMind
//
//  Ateş takip servisi
//

import Foundation
import Combine

class FeverService: ObservableObject {
    @Published var records: [FeverRecord] = []
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadRecords()
    }
    
    func addRecord(_ record: FeverRecord) {
        records.append(record)
        records.sort { $0.date > $1.date }
        saveRecords()
        
        // Yüksek ateş uyarısı
        if record.isHighFever {
            NotificationCenter.default.post(
                name: NSNotification.Name("HighFeverAlert"),
                object: nil,
                userInfo: ["record": record]
            )
        }
    }
    
    func deleteRecord(_ record: FeverRecord) {
        records.removeAll { $0.id == record.id }
        saveRecords()
    }
    
    func getRecordsForDateRange(start: Date, end: Date) -> [FeverRecord] {
        return records.filter { $0.date >= start && $0.date <= end }
    }
    
    func getTodayRecords() -> [FeverRecord] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return getRecordsForDateRange(start: today, end: tomorrow)
    }
    
    func getLast7DaysRecords() -> [FeverRecord] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return getRecordsForDateRange(start: sevenDaysAgo, end: Date())
    }
    
    func getAverageTemperature(for days: Int = 7) -> Double? {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let recentRecords = records.filter { $0.date >= cutoffDate }
        
        guard !recentRecords.isEmpty else { return nil }
        let sum = recentRecords.reduce(0.0) { $0 + $1.temperature }
        return sum / Double(recentRecords.count)
    }
    
    func getHighestTemperature(for days: Int = 7) -> FeverRecord? {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let recentRecords = records.filter { $0.date >= cutoffDate }
        return recentRecords.max { $0.temperature < $1.temperature }
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: "feverRecords_\(babyId.uuidString)")
        }
    }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: "feverRecords_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([FeverRecord].self, from: data) {
            records = decoded.sorted { $0.date > $1.date }
        }
    }
}







