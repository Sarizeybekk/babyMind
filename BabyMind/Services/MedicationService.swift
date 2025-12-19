//
//  MedicationService.swift
//
//  İlaç takip servisi
//

import Foundation
import Combine

class MedicationService: ObservableObject {
    @Published var medications: [Medication] = []
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadMedications()
    }
    
    func addMedication(_ medication: Medication) {
        medications.append(medication)
        medications.sort { $0.startDate > $1.startDate }
        saveMedications()
    }
    
    func updateMedication(_ medication: Medication) {
        if let index = medications.firstIndex(where: { $0.id == medication.id }) {
            medications[index] = medication
            medications.sort { $0.startDate > $1.startDate }
            saveMedications()
        }
    }
    
    func deleteMedication(_ medication: Medication) {
        medications.removeAll { $0.id == medication.id }
        saveMedications()
    }
    
    func activeMedications() -> [Medication] {
        let now = Date()
        return medications.filter { medication in
            medication.isActive &&
            medication.startDate <= now &&
            (medication.endDate == nil || medication.endDate! >= now)
        }
    }
    
    private func saveMedications() {
        if let encoded = try? JSONEncoder().encode(medications) {
            UserDefaults.standard.set(encoded, forKey: "medications_\(babyId.uuidString)")
        }
    }
    
    private func loadMedications() {
        if let data = UserDefaults.standard.data(forKey: "medications_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([Medication].self, from: data) {
            medications = decoded.sorted { $0.startDate > $1.startDate }
        }
    }
}
