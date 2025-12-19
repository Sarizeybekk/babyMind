//
//  CryAnalysis.swift
//
//  Ağlama analizi modeli
//

import Foundation

struct CryAnalysis: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let date: Date
    let audioFileName: String? // Ses dosyası adı
    let cryType: CryType
    let confidence: Double // Güven skoru (0-1)
    let duration: TimeInterval // Ağlama süresi (saniye)
    let notes: String?
    let aiRecommendation: String?
    
    enum CryType: String, Codable, CaseIterable {
        case hunger = "Açlık"
        case tired = "Yorgunluk"
        case pain = "Ağrı"
        case discomfort = "Rahatsızlık"
        case attention = "İlgi İhtiyacı"
        case unknown = "Bilinmiyor"
        
        var icon: String {
            switch self {
            case .hunger: return "fork.knife"
            case .tired: return "moon.fill"
            case .pain: return "exclamationmark.triangle.fill"
            case .discomfort: return "hand.raised.fill"
            case .attention: return "heart.fill"
            case .unknown: return "questionmark.circle"
            }
        }
        
        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .hunger: return (0.5, 0.7, 1.0) // Mavi
            case .tired: return (0.6, 0.6, 1.0) // Mor
            case .pain: return (1.0, 0.4, 0.4) // Kırmızı
            case .discomfort: return (1.0, 0.7, 0.4) // Turuncu
            case .attention: return (1.0, 0.5, 0.7) // Pembe
            case .unknown: return (0.6, 0.6, 0.6) // Gri
            }
        }
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         date: Date = Date(),
         audioFileName: String? = nil,
         cryType: CryType,
         confidence: Double,
         duration: TimeInterval,
         notes: String? = nil,
         aiRecommendation: String? = nil) {
        self.id = id
        self.babyId = babyId
        self.date = date
        self.audioFileName = audioFileName
        self.cryType = cryType
        self.confidence = confidence
        self.duration = duration
        self.notes = notes
        self.aiRecommendation = aiRecommendation
    }
}
