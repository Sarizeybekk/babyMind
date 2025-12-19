//
//  MilestonePhoto.swift
//  BabyMind
//
//  Milestone fotoğraf modeli
//

import Foundation
import SwiftUI
import UIKit

struct MilestonePhoto: Identifiable, Codable {
    let id: UUID
    let milestoneId: UUID?
    let title: String
    let description: String?
    let date: Date
    let photoData: Data? // Fotoğraf verisi
    let videoURL: String? // Video dosya yolu
    let audioURL: String? // Ses dosya yolu
    let mediaType: MediaType // Medya tipi
    let category: MilestoneCategory
    let tags: [String]
    
    enum MediaType: String, Codable {
        case photo = "Fotoğraf"
        case video = "Video"
        case audio = "Ses"
        case photoWithAudio = "Fotoğraf + Ses"
    }
    
    enum MilestoneCategory: String, Codable, CaseIterable {
        case firstSmile = "İlk Gülümseme"
        case firstLaugh = "İlk Kahkaha"
        case firstWord = "İlk Kelime"
        case firstStep = "İlk Adım"
        case sitting = "Oturma"
        case crawling = "Emekleme"
        case standing = "Ayakta Durma"
        case walking = "Yürüme"
        case feeding = "Beslenme"
        case sleep = "Uyku"
        case play = "Oyun"
        case bath = "Banyo"
        case other = "Diğer"
    }
    
    init(id: UUID = UUID(),
         milestoneId: UUID? = nil,
         title: String,
         description: String? = nil,
         date: Date = Date(),
         photoData: Data? = nil,
         videoURL: String? = nil,
         audioURL: String? = nil,
         mediaType: MediaType = .photo,
         category: MilestoneCategory,
         tags: [String] = []) {
        self.id = id
        self.milestoneId = milestoneId
        self.title = title
        self.description = description
        self.date = date
        self.photoData = photoData
        self.videoURL = videoURL
        self.audioURL = audioURL
        self.mediaType = mediaType
        self.category = category
        self.tags = tags
    }
    
    var image: Image? {
        guard let photoData = photoData,
              let uiImage = UIImage(data: photoData) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}

