//
//  MilestoneAlbumService.swift
//  BabyMind
//
//  Milestone albüm servisi
//

import Foundation
import Combine
import UIKit
import AVFoundation

class MilestoneAlbumService: ObservableObject {
    @Published var photos: [MilestonePhoto] = []
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadPhotos()
    }
    
    func addPhoto(_ photo: MilestonePhoto) {
        photos.append(photo)
        photos.sort { $0.date > $1.date }
        savePhotos()
    }
    
    func updatePhoto(_ photo: MilestonePhoto) {
        if let index = photos.firstIndex(where: { $0.id == photo.id }) {
            photos[index] = photo
            photos.sort { $0.date > $1.date }
            savePhotos()
        }
    }
    
    func deletePhoto(_ photo: MilestonePhoto) {
        photos.removeAll { $0.id == photo.id }
        savePhotos()
    }
    
    func getPhotosByCategory(_ category: MilestonePhoto.MilestoneCategory) -> [MilestonePhoto] {
        photos.filter { $0.category == category }
    }
    
    func getPhotosByMonth() -> [String: [MilestonePhoto]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        
        var grouped: [String: [MilestonePhoto]] = [:]
        for photo in photos {
            let key = formatter.string(from: photo.date)
            grouped[key, default: []].append(photo)
        }
        return grouped
    }
    
    func getTimelinePhotos() -> [MilestonePhoto] {
        photos.sorted { $0.date < $1.date }
    }
    
    private func savePhotos() {
        if let encoded = try? JSONEncoder().encode(photos) {
            UserDefaults.standard.set(encoded, forKey: "milestonePhotos_\(babyId.uuidString)")
        }
    }
    
    private func loadPhotos() {
        if let data = UserDefaults.standard.data(forKey: "milestonePhotos_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([MilestonePhoto].self, from: data) {
            photos = decoded.sorted { $0.date > $1.date }
        }
    }
}

