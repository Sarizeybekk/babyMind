//
//  IllnessService.swift
//  BabyMind
//
//  Hastalık takip servisi
//

import Foundation
import Combine

class IllnessService: ObservableObject {
    @Published var illnesses: [Illness] = []
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadIllnesses()
    }
    
    func addIllness(_ illness: Illness) {
        illnesses.append(illness)
        illnesses.sort { $0.startDate > $1.startDate }
        saveIllnesses()
    }
    
    func updateIllness(_ illness: Illness) {
        if let index = illnesses.firstIndex(where: { $0.id == illness.id }) {
            illnesses[index] = illness
            illnesses.sort { $0.startDate > $1.startDate }
            saveIllnesses()
        }
    }
    
    func deleteIllness(_ illness: Illness) {
        illnesses.removeAll { $0.id == illness.id }
        saveIllnesses()
    }
    
    func getActiveIllnesses() -> [Illness] {
        return illnesses.filter { $0.isActive }
    }
    
    func getIllnessesForDateRange(start: Date, end: Date) -> [Illness] {
        return illnesses.filter { $0.startDate >= start && ($0.endDate ?? Date()) <= end }
    }
    
    private func saveIllnesses() {
        if let encoded = try? JSONEncoder().encode(illnesses) {
            UserDefaults.standard.set(encoded, forKey: "illnesses_\(babyId.uuidString)")
        }
    }
    
    private func loadIllnesses() {
        if let data = UserDefaults.standard.data(forKey: "illnesses_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([Illness].self, from: data) {
            illnesses = decoded.sorted { $0.startDate > $1.startDate }
        }
    }
}







