//
//  SleepRecord.swift
//
//  Uyku kaydı modeli
//

import Foundation

struct SleepRecord: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    var startTime: Date
    var endTime: Date?
    var sleepType: SleepType
    var quality: SleepQuality?
    var wakeCount: Int // Gece uyanma sayısı
    var notes: String?
    
    enum SleepType: String, Codable, CaseIterable {
        case night = "Gece"
        case day = "Gündüz"
        case nap = "Kısa Uyku"
    }
    
    enum SleepQuality: String, Codable {
        case excellent = "Mükemmel"
        case good = "İyi"
        case fair = "Orta"
        case poor = "Zayıf"
        
        var score: Int {
            switch self {
            case .excellent: return 100
            case .good: return 75
            case .fair: return 50
            case .poor: return 25
            }
        }
        
        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .excellent: return (0.2, 0.8, 0.4) // Yeşil
            case .good: return (0.4, 0.7, 0.9) // Mavi
            case .fair: return (1.0, 0.7, 0.3) // Turuncu
            case .poor: return (1.0, 0.4, 0.4) // Kırmızı
            }
        }
    }
    
    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    var durationInHours: Double? {
        guard let duration = duration else { return nil }
        return duration / 3600.0
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         startTime: Date = Date(),
         endTime: Date? = nil,
         sleepType: SleepType,
         quality: SleepQuality? = nil,
         wakeCount: Int = 0,
         notes: String? = nil) {
        self.id = id
        self.babyId = babyId
        self.startTime = startTime
        self.endTime = endTime
        self.sleepType = sleepType
        self.quality = quality
        self.wakeCount = wakeCount
        self.notes = notes
    }
}


