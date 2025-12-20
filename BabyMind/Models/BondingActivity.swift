//
//  BondingActivity.swift
//
//  Anne-bebek bağlanma aktivitesi modeli
//

import Foundation

struct BondingActivity: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let activityType: ActivityType
    let date: Date
    let duration: TimeInterval? // dakika
    var notes: String?
    var isCompleted: Bool
    
    enum ActivityType: String, Codable, CaseIterable {
        case play = "Oyun"
        case massage = "Masaj"
        case reading = "Okuma"
        case music = "Müzik/Ses Terapisi"
        case skinToSkin = "Ten Tene Temas"
        case bath = "Banyo"
        case feeding = "Beslenme (Bağlanma)"
        case eyeContact = "Göz Teması"
        case talking = "Konuşma"
        case cuddling = "Kucaklaşma"
        
        var icon: String {
            switch self {
            case .play: return "gamecontroller.fill"
            case .massage: return "hand.raised.fill"
            case .reading: return "book.fill"
            case .music: return "music.note"
            case .skinToSkin: return "heart.fill"
            case .bath: return "drop.fill"
            case .feeding: return "fork.knife"
            case .eyeContact: return "eye.fill"
            case .talking: return "bubble.left.and.bubble.right.fill"
            case .cuddling: return "heart.circle.fill"
            }
        }
        
        var recommendedAge: String {
            switch self {
            case .skinToSkin: return "Doğumdan itibaren"
            case .eyeContact: return "Doğumdan itibaren"
            case .talking: return "Doğumdan itibaren"
            case .cuddling: return "Doğumdan itibaren"
            case .massage: return "2 hafta+"
            case .bath: return "Göbek bağı düştükten sonra"
            case .feeding: return "Doğumdan itibaren"
            case .music: return "Doğumdan itibaren"
            case .reading: return "3 ay+"
            case .play: return "3 ay+"
            }
        }
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         activityType: ActivityType,
         date: Date = Date(),
         duration: TimeInterval? = nil,
         notes: String? = nil,
         isCompleted: Bool = false) {
        self.id = id
        self.babyId = babyId
        self.activityType = activityType
        self.date = date
        self.duration = duration
        self.notes = notes
        self.isCompleted = isCompleted
    }
}

struct PlaySuggestion {
    let ageRange: String
    let activities: [String]
    let benefits: [String]
}
