//
//  FeverRecord.swift
//  BabyMind
//
//  Ateş kaydı modeli
//

import Foundation

struct FeverRecord: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let temperature: Double // Celsius
    let measurementLocation: MeasurementLocation
    let date: Date
    let notes: String?
    let medicationGiven: Bool
    let medicationName: String?
    let medicationTime: Date?
    
    enum MeasurementLocation: String, Codable, CaseIterable {
        case armpit = "Koltuk Altı"
        case ear = "Kulak"
        case forehead = "Alın"
        case mouth = "Ağız"
        case rectum = "Rektal"
    }
    
    var isHighFever: Bool {
        temperature >= 38.5
    }
    
    var severity: FeverSeverity {
        switch temperature {
        case ..<37.5:
            return .normal
        case 37.5..<38.0:
            return .low
        case 38.0..<38.5:
            return .moderate
        case 38.5..<39.5:
            return .high
        default:
            return .veryHigh
        }
    }
    
    enum FeverSeverity {
        case normal
        case low
        case moderate
        case high
        case veryHigh
        
        var color: String {
            switch self {
            case .normal: return "green"
            case .low: return "yellow"
            case .moderate: return "orange"
            case .high: return "red"
            case .veryHigh: return "darkRed"
            }
        }
        
        var description: String {
            switch self {
            case .normal: return "Normal"
            case .low: return "Hafif Ateş"
            case .moderate: return "Orta Ateş"
            case .high: return "Yüksek Ateş"
            case .veryHigh: return "Çok Yüksek Ateş"
            }
        }
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         temperature: Double,
         measurementLocation: MeasurementLocation,
         date: Date = Date(),
         notes: String? = nil,
         medicationGiven: Bool = false,
         medicationName: String? = nil,
         medicationTime: Date? = nil) {
        self.id = id
        self.babyId = babyId
        self.temperature = temperature
        self.measurementLocation = measurementLocation
        self.date = date
        self.notes = notes
        self.medicationGiven = medicationGiven
        self.medicationName = medicationName
        self.medicationTime = medicationTime
    }
}





