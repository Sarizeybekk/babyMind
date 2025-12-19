//
//  DiaryEntry.swift
//  BabyMind
//
//  Bebek günlüğü modeli
//

import Foundation

struct DiaryEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var title: String
    var content: String
    var mood: Mood
    var photos: [Data] // UIImage'ı Data olarak sakla
    var tags: [String]
    var babyId: UUID
    
    enum Mood: String, Codable, CaseIterable {
        case happy = "Mutlu"
        case calm = "Sakin"
        case playful = "Oyuncul"
        case sleepy = "Uykulu"
        case fussy = "Huzursuz"
        case excited = "Heyecanlı"
        case neutral = "Normal"
        
        var emoji: String {
            switch self {
            case .happy: return "😊"
            case .calm: return "😌"
            case .playful: return "😄"
            case .sleepy: return "😴"
            case .fussy: return "😟"
            case .excited: return "🤩"
            case .neutral: return "😐"
            }
        }
        
        var color: String {
            switch self {
            case .happy: return "yellow"
            case .calm: return "blue"
            case .playful: return "orange"
            case .sleepy: return "purple"
            case .fussy: return "red"
            case .excited: return "pink"
            case .neutral: return "gray"
            }
        }
    }
    
    init(id: UUID = UUID(),
         date: Date = Date(),
         title: String = "",
         content: String = "",
         mood: Mood = .neutral,
         photos: [Data] = [],
         tags: [String] = [],
         babyId: UUID) {
        self.id = id
        self.date = date
        self.title = title
        self.content = content
        self.mood = mood
        self.photos = photos
        self.tags = tags
        self.babyId = babyId
    }
}

