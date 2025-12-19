//
//  DiaryService.swift
//  BabyMind
//
//  Günlük yönetim servisi
//

import Foundation
import Combine

class DiaryService: ObservableObject {
    @Published var entries: [DiaryEntry] = []
    
    private let entriesKey = "savedDiaryEntries"
    
    init() {
        loadEntries()
    }
    
    func addEntry(_ entry: DiaryEntry) {
        entries.append(entry)
        saveEntries()
    }
    
    func updateEntry(_ entry: DiaryEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            saveEntries()
        }
    }
    
    func deleteEntry(_ entry: DiaryEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    func entries(for babyId: UUID) -> [DiaryEntry] {
        entries.filter { $0.babyId == babyId }
            .sorted { $0.date > $1.date }
    }
    
    func entries(for babyId: UUID, date: Date) -> [DiaryEntry] {
        let calendar = Calendar.current
        return entries(for: babyId).filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
    }
    
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([DiaryEntry].self, from: data) {
            entries = decoded
        }
    }
}

