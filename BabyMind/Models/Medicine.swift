//
//  Medicine.swift
//  BabyMind
//
//  İlaç modeli
//

import Foundation

struct Medicine: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var dosage: String // Örn: "5ml", "1 tablet"
    var frequency: Frequency
    var startDate: Date
    var endDate: Date?
    var notes: String
    var isActive: Bool
    var reminderIds: [UUID] // Birden fazla hatırlatıcı olabilir
    var babyId: UUID
    
    enum Frequency: String, Codable, CaseIterable {
        case once = "Günde 1 kez"
        case twice = "Günde 2 kez"
        case threeTimes = "Günde 3 kez"
        case fourTimes = "Günde 4 kez"
        case every6Hours = "6 saatte bir"
        case every8Hours = "8 saatte bir"
        case every12Hours = "12 saatte bir"
        case asNeeded = "İhtiyaç halinde"
        
        var timesPerDay: Int {
            switch self {
            case .once: return 1
            case .twice: return 2
            case .threeTimes: return 3
            case .fourTimes: return 4
            case .every6Hours: return 4
            case .every8Hours: return 3
            case .every12Hours: return 2
            case .asNeeded: return 0
            }
        }
        
        var intervalHours: Int? {
            switch self {
            case .every6Hours: return 6
            case .every8Hours: return 8
            case .every12Hours: return 12
            default: return nil
            }
        }
    }
    
    init(id: UUID = UUID(),
         name: String = "",
         dosage: String = "",
         frequency: Frequency = .once,
         startDate: Date = Date(),
         endDate: Date? = nil,
         notes: String = "",
         isActive: Bool = true,
         reminderIds: [UUID] = [],
         babyId: UUID) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.isActive = isActive
        self.reminderIds = reminderIds
        self.babyId = babyId
    }
    
    var isExpired: Bool {
        guard let endDate = endDate else { return false }
        return Date() > endDate
    }
}

