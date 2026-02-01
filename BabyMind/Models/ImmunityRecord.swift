//
//  ImmunityRecord.swift
//
//  Bağışıklık sistemi kayıt modeli
//

import Foundation

struct ImmunityRecord: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let date: Date
    let type: RecordType
    let details: String
    let severity: Severity?
    let notes: String?
    
    enum RecordType: String, Codable, CaseIterable {
        case vaccination = "Aşı"
        case illness = "Hastalık"
        case supplement = "Takviye"
        case checkup = "Kontrol"
        
        var icon: String {
            switch self {
            case .vaccination: return "syringe.fill"
            case .illness: return "cross.case.fill"
            case .supplement: return "pills.fill"
            case .checkup: return "stethoscope"
            }
        }
        
        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .vaccination: return (0.2, 0.7, 0.9) // Mavi
            case .illness: return (1.0, 0.4, 0.4) // Kırmızı
            case .supplement: return (0.9, 0.6, 0.3) // Turuncu
            case .checkup: return (0.3, 0.8, 0.5) // Yeşil
            }
        }
    }
    
    enum Severity: String, Codable {
        case mild = "Hafif"
        case moderate = "Orta"
        case severe = "Şiddetli"
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         date: Date = Date(),
         type: RecordType,
         details: String,
         severity: Severity? = nil,
         notes: String? = nil) {
        self.id = id
        self.babyId = babyId
        self.date = date
        self.type = type
        self.details = details
        self.severity = severity
        self.notes = notes
    }
}

struct VaccinationSchedule {
    let name: String
    let recommendedAge: String
    let doses: [String]
    let isCompleted: Bool
    let completedDate: Date?
    
    init(name: String, recommendedAge: String, doses: [String], isCompleted: Bool = false, completedDate: Date? = nil) {
        self.name = name
        self.recommendedAge = recommendedAge
        self.doses = doses
        self.isCompleted = isCompleted
        self.completedDate = completedDate
    }
}


