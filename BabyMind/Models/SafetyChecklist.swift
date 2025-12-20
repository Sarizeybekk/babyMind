//
//  SafetyChecklist.swift
//
//  Güvenlik kontrol listesi modeli
//

import Foundation

struct SafetyChecklist: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let category: Category
    let item: String
    var isChecked: Bool
    var checkedDate: Date?
    var notes: String?
    
    enum Category: String, Codable, CaseIterable {
        case home = "Ev Güvenliği"
        case toys = "Oyuncak Güvenliği"
        case sleep = "Uyku Ortamı Güvenliği"
        case products = "Bebek Bakım Ürünleri"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .toys: return "gamecontroller.fill"
            case .sleep: return "bed.double.fill"
            case .products: return "cube.box.fill"
            }
        }
        
        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .home: return (0.2, 0.7, 0.9) // Mavi
            case .toys: return (1.0, 0.5, 0.7) // Pembe
            case .sleep: return (0.6, 0.6, 1.0) // Mor
            case .products: return (0.9, 0.6, 0.3) // Turuncu
            }
        }
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         category: Category,
         item: String,
         isChecked: Bool = false,
         checkedDate: Date? = nil,
         notes: String? = nil) {
        self.id = id
        self.babyId = babyId
        self.category = category
        self.item = item
        self.isChecked = isChecked
        self.checkedDate = checkedDate
        self.notes = notes
    }
}
