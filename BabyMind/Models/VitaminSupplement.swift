//
//  VitaminSupplement.swift
//
//  Vitamin ve takviye modeli
//

import Foundation

struct VitaminSupplement: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let name: String
    let type: SupplementType
    let dosage: String
    let frequency: Frequency
    let startDate: Date
    var endDate: Date?
    var notes: String?
    var isActive: Bool
    
    enum SupplementType: String, Codable, CaseIterable {
        case vitaminD = "D Vitamini"
        case iron = "Demir"
        case zinc = "Çinko"
        case multivitamin = "Multivitamin"
        case probiotic = "Probiyotik"
        case omega3 = "Omega-3"
        case other = "Diğer"
        
        var icon: String {
            switch self {
            case .vitaminD: return "sun.max.fill"
            case .iron: return "drop.fill"
            case .zinc: return "circle.fill"
            case .multivitamin: return "pills.fill"
            case .probiotic: return "leaf.fill"
            case .omega3: return "fish.fill"
            case .other: return "pills"
            }
        }
        
        var recommendedAge: String {
            switch self {
            case .vitaminD: return "Doğumdan itibaren"
            case .iron: return "4-6 ay"
            case .zinc: return "6 ay+"
            case .multivitamin: return "Doktor önerisi"
            case .probiotic: return "Doktor önerisi"
            case .omega3: return "6 ay+"
            case .other: return "Doktor önerisi"
            }
        }
    }
    
    enum Frequency: String, Codable, CaseIterable {
        case daily = "Günlük"
        case twiceDaily = "Günde 2 kez"
        case weekly = "Haftalık"
        case asNeeded = "İhtiyaç halinde"
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         name: String,
         type: SupplementType,
         dosage: String,
         frequency: Frequency,
         startDate: Date = Date(),
         endDate: Date? = nil,
         notes: String? = nil,
         isActive: Bool = true) {
        self.id = id
        self.babyId = babyId
        self.name = name
        self.type = type
        self.dosage = dosage
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.isActive = isActive
    }
}

struct DeficiencyAlert {
    let type: VitaminSupplement.SupplementType
    let message: String
    let severity: AlertSeverity
    
    enum AlertSeverity {
        case low
        case moderate
        case high
    }
}
