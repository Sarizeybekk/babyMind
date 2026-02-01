//
//  Routine.swift
//
//  Rutin modeli
//

import Foundation

struct Routine: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let type: RoutineType
    let time: Date
    var isCompleted: Bool
    var completionDate: Date?
    var notes: String?
    
    enum RoutineType: String, Codable, CaseIterable {
        case sleep = "Uyku"
        case feeding = "Beslenme"
        case play = "Oyun"
        case bath = "Banyo"
        case nap = "Kısa Uyku"
        
        var icon: String {
            switch self {
            case .sleep: return "moon.stars.fill"
            case .feeding: return "fork.knife"
            case .play: return "gamecontroller.fill"
            case .bath: return "drop.fill"
            case .nap: return "bed.double.fill"
            }
        }
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         type: RoutineType,
         time: Date,
         isCompleted: Bool = false,
         completionDate: Date? = nil,
         notes: String? = nil) {
        self.id = id
        self.babyId = babyId
        self.type = type
        self.time = time
        self.isCompleted = isCompleted
        self.completionDate = completionDate
        self.notes = notes
    }
}

struct RoutineSchedule {
    let type: Routine.RoutineType
    let times: [Date]
    let ageRange: String
    let description: String
}


