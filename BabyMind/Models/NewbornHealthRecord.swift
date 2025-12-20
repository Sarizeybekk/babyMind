//
//  NewbornHealthRecord.swift
//
//  Yenidoğan sağlık kaydı modeli (SDG 3.2 hedefleri için)
//

import Foundation

struct NewbornHealthRecord: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let date: Date
    let ageInDays: Int
    let category: HealthCategory
    let value: Double?
    let status: HealthStatus
    let notes: String?
    
    enum HealthCategory: String, Codable, CaseIterable {
        case weight = "Ağırlık"
        case temperature = "Ateş"
        case feeding = "Beslenme"
        case breathing = "Nefes Alma"
        case jaundice = "Sarılık"
        case umbilicalCord = "Göbek Bağı"
        case sleep = "Uyku"
        case alertness = "Uyanıklık"
        
        var icon: String {
            switch self {
            case .weight: return "scalemass.fill"
            case .temperature: return "thermometer"
            case .feeding: return "drop.fill"
            case .breathing: return "lungs.fill"
            case .jaundice: return "eye.fill"
            case .umbilicalCord: return "circle.fill"
            case .sleep: return "moon.fill"
            case .alertness: return "eye.circle.fill"
            }
        }
        
        var normalRange: (min: Double, max: Double)? {
            switch self {
            case .temperature: return (36.5, 37.5) // °C
            case .breathing: return (30, 60) // nefes/dakika
            case .feeding: return (6, 12) // günlük beslenme sayısı
            default: return nil
            }
        }
        
        var criticalThreshold: Double? {
            switch self {
            case .temperature: return 38.0 // Yüksek ateş
            case .breathing: return 20.0 // Düşük nefes
            default: return nil
            }
        }
    }
    
    enum HealthStatus: String, Codable {
        case normal = "Normal"
        case warning = "Dikkat"
        case critical = "Acil"
        
        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .normal: return (0.2, 0.8, 0.4) // Yeşil
            case .warning: return (1.0, 0.7, 0.3) // Turuncu
            case .critical: return (1.0, 0.3, 0.3) // Kırmızı
            }
        }
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         date: Date = Date(),
         ageInDays: Int,
         category: HealthCategory,
         value: Double? = nil,
         status: HealthStatus = .normal,
         notes: String? = nil) {
        self.id = id
        self.babyId = babyId
        self.date = date
        self.ageInDays = ageInDays
        self.category = category
        self.value = value
        self.status = status
        self.notes = notes
    }
}

struct HealthScreening: Identifiable {
    let id: UUID
    let ageInDays: Int
    let screeningType: ScreeningType
    var isCompleted: Bool
    let recommendedDate: Date
    let description: String
    
    init(id: UUID = UUID(), ageInDays: Int, screeningType: ScreeningType, isCompleted: Bool = false, recommendedDate: Date, description: String) {
        self.id = id
        self.ageInDays = ageInDays
        self.screeningType = screeningType
        self.isCompleted = isCompleted
        self.recommendedDate = recommendedDate
        self.description = description
    }
    
    enum ScreeningType: String, Codable {
        case newbornExam = "Yenidoğan Muayenesi"
        case hearingTest = "İşitme Testi"
        case metabolicScreening = "Metabolik Tarama"
        case hipUltrasound = "Kalça Ultrasonu"
        case eyeExam = "Göz Muayenesi"
        case vaccination = "Aşı"
        
        var icon: String {
            switch self {
            case .newbornExam: return "stethoscope"
            case .hearingTest: return "ear.fill"
            case .metabolicScreening: return "testtube.2"
            case .hipUltrasound: return "waveform.path"
            case .eyeExam: return "eye.fill"
            case .vaccination: return "syringe.fill"
            }
        }
    }
}
