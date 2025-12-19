//
//  ActivityLog.swift
//  BabyMind
//
//  Beslenme ve uyku loglama modeli
//

import Foundation

struct ActivityLog: Identifiable, Codable {
    let id: UUID
    let type: ActivityType
    let date: Date
    let duration: TimeInterval? // dakika cinsinden (uyku için)
    let amount: Double? // ml cinsinden (beslenme için)
    let notes: String?
    
    enum ActivityType: String, Codable, CaseIterable {
        case feeding = "Beslenme"
        case sleep = "Uyku"
        case diaper = "Bez Değişimi"
        case medication = "İlaç"
    }
    
    init(id: UUID = UUID(),
         type: ActivityType,
         date: Date = Date(),
         duration: TimeInterval? = nil,
         amount: Double? = nil,
         notes: String? = nil) {
        self.id = id
        self.type = type
        self.date = date
        self.duration = duration
        self.amount = amount
        self.notes = notes
    }
}

struct Milestone: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: MilestoneCategory
    let expectedAge: Int // hafta cinsinden
    let achievedDate: Date?
    let photoURL: String? // Fotoğraf yolu
    let notes: String?
    
    enum MilestoneCategory: String, Codable, CaseIterable {
        case motor = "Motor Gelişim"
        case cognitive = "Bilişsel Gelişim"
        case social = "Sosyal Gelişim"
        case language = "Dil Gelişimi"
    }
    
    var isAchieved: Bool {
        achievedDate != nil
    }
    
    init(id: UUID = UUID(),
         title: String,
         description: String,
         category: MilestoneCategory,
         expectedAge: Int,
         achievedDate: Date? = nil,
         photoURL: String? = nil,
         notes: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.expectedAge = expectedAge
        self.achievedDate = achievedDate
        self.photoURL = photoURL
        self.notes = notes
    }
}

