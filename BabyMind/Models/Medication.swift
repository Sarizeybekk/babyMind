//
//  Medication.swift
//
//  İlaç takip modeli
//

import Foundation

struct Medication: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    var name: String
    var dosage: String // Dozaj (örn: "5ml", "1 tablet")
    var frequency: Frequency // Sıklık
    var startDate: Date
    var endDate: Date?
    var notes: String?
    var isActive: Bool
    
    enum Frequency: String, Codable, CaseIterable {
        case once = "Günde 1 kez"
        case twice = "Günde 2 kez"
        case threeTimes = "Günde 3 kez"
        case fourTimes = "Günde 4 kez"
        case asNeeded = "Gerektiğinde"
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         name: String = "",
         dosage: String = "",
         frequency: Frequency = .once,
         startDate: Date = Date(),
         endDate: Date? = nil,
         notes: String? = nil,
         isActive: Bool = true) {
        self.id = id
        self.babyId = babyId
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.isActive = isActive
    }
}


