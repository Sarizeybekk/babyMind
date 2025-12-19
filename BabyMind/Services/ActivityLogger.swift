//
//  ActivityLogger.swift
//  BabyMind
//
//  Aktivite loglama servisi
//

import Foundation
import Combine

class ActivityLogger: ObservableObject {
    @Published var logs: [ActivityLog] = []
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadLogs()
    }
    
    func addLog(_ log: ActivityLog) {
        logs.append(log)
        logs.sort { $0.date > $1.date }
        saveLogs()
        updateWidget(for: log.type, date: log.date)
    }
    
    private func updateWidget(for type: ActivityLog.ActivityType, date: Date) {
        // Sadece beslenme ve uyku için widget güncelle
        if type == .feeding || type == .sleep {
            WidgetDataService.shared.saveLastActivity(type: type, date: date)
        }
    }
    
    func deleteLog(_ log: ActivityLog) {
        logs.removeAll { $0.id == log.id }
        saveLogs()
    }
    
    func getTodayLogs() -> [ActivityLog] {
        let today = Calendar.current.startOfDay(for: Date())
        return logs.filter { Calendar.current.startOfDay(for: $0.date) == today }
    }
    
    func getLogs(for date: Date) -> [ActivityLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return logs.filter { $0.date >= startOfDay && $0.date < endOfDay }
            .sorted { $0.date > $1.date }
    }
    
    func getLogs(for type: ActivityLog.ActivityType, days: Int = 7) -> [ActivityLog] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return logs.filter { $0.type == type && $0.date >= cutoffDate }
    }
    
    func getTotalFeedingToday() -> Double {
        let todayLogs = getTodayLogs()
        return todayLogs
            .filter { $0.type == .feeding }
            .compactMap { $0.amount }
            .reduce(0, +)
    }
    
    func getTotalSleepToday() -> TimeInterval {
        let todayLogs = getTodayLogs()
        return todayLogs
            .filter { $0.type == .sleep }
            .compactMap { $0.duration }
            .reduce(0, +)
    }
    
    private func saveLogs() {
        if let encoded = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(encoded, forKey: "activityLogs_\(babyId.uuidString)")
        }
    }
    
    private func loadLogs() {
        if let data = UserDefaults.standard.data(forKey: "activityLogs_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([ActivityLog].self, from: data) {
            logs = decoded.sorted { $0.date > $1.date }
        }
    }
}

