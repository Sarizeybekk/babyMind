//
//  EmergencyGuide.swift
//
//  Acil durum rehberi modeli
//

import Foundation

struct EmergencyGuide: Identifiable {
    let id: UUID
    let category: Category
    let title: String
    let description: String
    let steps: [String]
    let whenToCallDoctor: String?
    
    enum Category: String, Codable, CaseIterable {
        case fever = "Ateş"
        case choking = "Boğulma"
        case poisoning = "Zehirlenme"
        case breathing = "Nefes Alma Sorunları"
        case firstAid = "İlk Yardım"
        case whenToCall = "Ne Zaman Doktora Gidilmeli?"
        
        var icon: String {
            switch self {
            case .fever: return "thermometer"
            case .choking: return "exclamationmark.triangle.fill"
            case .poisoning: return "exclamationmark.octagon.fill"
            case .breathing: return "lungs.fill"
            case .firstAid: return "cross.case.fill"
            case .whenToCall: return "phone.fill"
            }
        }
        
        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .fever: return (1.0, 0.4, 0.4) // Kırmızı
            case .choking: return (1.0, 0.3, 0.3) // Koyu kırmızı
            case .poisoning: return (1.0, 0.5, 0.2) // Turuncu
            case .breathing: return (0.3, 0.7, 0.9) // Mavi
            case .firstAid: return (0.2, 0.8, 0.4) // Yeşil
            case .whenToCall: return (0.9, 0.3, 0.3) // Kırmızı
            }
        }
    }
    
    init(id: UUID = UUID(),
         category: Category,
         title: String,
         description: String,
         steps: [String],
         whenToCallDoctor: String? = nil) {
        self.id = id
        self.category = category
        self.title = title
        self.description = description
        self.steps = steps
        self.whenToCallDoctor = whenToCallDoctor
    }
}


