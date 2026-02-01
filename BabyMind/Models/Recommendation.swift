//
//  Recommendation.swift
//  BabyMind
//
//  AI önerileri modeli
//

import Foundation

struct Recommendation: Identifiable, Codable, Equatable {
    let id: UUID
    let category: Category
    let title: String
    let description: String
    let priority: Priority
    let dateCreated: Date
    
    enum Category: String, Codable, CaseIterable {
        case feeding = "Beslenme"
        case sleep = "Uyku"
        case development = "Gelişim"
        case health = "Sağlık"
        case general = "Genel"
    }
    
    enum Priority: String, Codable {
        case low = "Düşük"
        case medium = "Orta"
        case high = "Yüksek"
        case urgent = "Acil"
    }
    
    init(id: UUID = UUID(),
         category: Category,
         title: String,
         description: String,
         priority: Priority = .medium,
         dateCreated: Date = Date()) {
        self.id = id
        self.category = category
        self.title = title
        self.description = description
        self.priority = priority
        self.dateCreated = dateCreated
    }
}







