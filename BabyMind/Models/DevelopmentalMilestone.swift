//
//  DevelopmentalMilestone.swift
//
//  Gelişimsel kilometre taşları modeli
//

import Foundation

struct DevelopmentalMilestone: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let category: Category
    let milestone: String
    let expectedAgeRange: AgeRange
    var achievedDate: Date?
    var notes: String?
    var isDelayed: Bool
    
    enum Category: String, Codable, CaseIterable {
        case motor = "Motor Gelişim"
        case language = "Dil Gelişimi"
        case social = "Sosyal Gelişim"
        case cognitive = "Bilişsel Gelişim"
        
        var icon: String {
            switch self {
            case .motor: return "figure.walk"
            case .language: return "bubble.left.and.bubble.right.fill"
            case .social: return "person.2.fill"
            case .cognitive: return "brain.head.profile"
            }
        }
        
        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .motor: return (0.2, 0.7, 0.9) // Mavi
            case .language: return (1.0, 0.5, 0.7) // Pembe
            case .social: return (0.3, 0.8, 0.5) // Yeşil
            case .cognitive: return (0.9, 0.6, 0.3) // Turuncu
            }
        }
    }
    
    struct AgeRange: Codable {
        let minMonths: Int
        let maxMonths: Int
        
        var description: String {
            if minMonths == maxMonths {
                return "\(minMonths) ay"
            }
            return "\(minMonths)-\(maxMonths) ay"
        }
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         category: Category,
         milestone: String,
         expectedAgeRange: AgeRange,
         achievedDate: Date? = nil,
         notes: String? = nil,
         isDelayed: Bool = false) {
        self.id = id
        self.babyId = babyId
        self.category = category
        self.milestone = milestone
        self.expectedAgeRange = expectedAgeRange
        self.achievedDate = achievedDate
        self.notes = notes
        self.isDelayed = isDelayed
    }
    
    var status: MilestoneStatus {
        if let achievedDate = achievedDate {
            return .achieved
        }
        
        let currentAge = Calendar.current.dateComponents([.month], from: Date(), to: Date()).month ?? 0
        // Bu hesaplama düzeltilmeli, baby'den alınmalı
        if currentAge > expectedAgeRange.maxMonths {
            return .delayed
        } else if currentAge >= expectedAgeRange.minMonths {
            return .expected
        } else {
            return .upcoming
        }
    }
}

enum MilestoneStatus {
    case upcoming
    case expected
    case achieved
    case delayed
    
    var color: (red: Double, green: Double, blue: Double) {
        switch self {
        case .upcoming: return (0.6, 0.6, 0.6) // Gri
        case .expected: return (1.0, 0.7, 0.3) // Turuncu
        case .achieved: return (0.2, 0.8, 0.4) // Yeşil
        case .delayed: return (1.0, 0.3, 0.3) // Kırmızı
        }
    }
    
    var text: String {
        switch self {
        case .upcoming: return "Yaklaşıyor"
        case .expected: return "Bekleniyor"
        case .achieved: return "Tamamlandı"
        case .delayed: return "Gecikme"
        }
    }
}


