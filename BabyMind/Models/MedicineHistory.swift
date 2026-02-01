//
//  MedicineHistory.swift
//  BabyMind
//
//  İlaç geçmişi modeli
//

import Foundation

struct MedicineHistory: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let name: String // İlaç adı
    let dosage: String // Dozaj (örn: 5ml, 1 tablet)
    let frequency: String // Sıklık (örn: Günde 3 kez)
    let startDate: Date
    let endDate: Date?
    let reason: String? // Kullanım nedeni
    let doctorName: String? // Reçete eden doktor
    let sideEffects: [String] // Yan etkiler
    let notes: String?
    let prescriptionPhoto: Data? // Reçete fotoğrafı
    
    var isActive: Bool {
        endDate == nil || endDate! > Date()
    }
    
    var duration: Int? {
        guard let endDate = endDate else { return nil }
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         name: String,
         dosage: String,
         frequency: String,
         startDate: Date = Date(),
         endDate: Date? = nil,
         reason: String? = nil,
         doctorName: String? = nil,
         sideEffects: [String] = [],
         notes: String? = nil,
         prescriptionPhoto: Data? = nil) {
        self.id = id
        self.babyId = babyId
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.reason = reason
        self.doctorName = doctorName
        self.sideEffects = sideEffects
        self.notes = notes
        self.prescriptionPhoto = prescriptionPhoto
    }
}







