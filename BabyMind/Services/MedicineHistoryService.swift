//
//  MedicineHistoryService.swift
//  BabyMind
//
//  İlaç geçmişi servisi
//

import Foundation
import Combine

class MedicineHistoryService: ObservableObject {
    @Published var medicines: [MedicineHistory] = []
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadMedicines()
    }
    
    func addMedicine(_ medicine: MedicineHistory) {
        medicines.append(medicine)
        medicines.sort { $0.startDate > $1.startDate }
        saveMedicines()
    }
    
    func updateMedicine(_ medicine: MedicineHistory) {
        if let index = medicines.firstIndex(where: { $0.id == medicine.id }) {
            medicines[index] = medicine
            medicines.sort { $0.startDate > $1.startDate }
            saveMedicines()
        }
    }
    
    func deleteMedicine(_ medicine: MedicineHistory) {
        medicines.removeAll { $0.id == medicine.id }
        saveMedicines()
    }
    
    func getActiveMedicines() -> [MedicineHistory] {
        return medicines.filter { $0.isActive }
    }
    
    func getMedicinesForDateRange(start: Date, end: Date) -> [MedicineHistory] {
        return medicines.filter { $0.startDate >= start && ($0.endDate ?? Date()) <= end }
    }
    
    private func saveMedicines() {
        if let encoded = try? JSONEncoder().encode(medicines) {
            UserDefaults.standard.set(encoded, forKey: "medicineHistory_\(babyId.uuidString)")
        }
    }
    
    private func loadMedicines() {
        if let data = UserDefaults.standard.data(forKey: "medicineHistory_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([MedicineHistory].self, from: data) {
            medicines = decoded.sorted { $0.startDate > $1.startDate }
        }
    }
}





