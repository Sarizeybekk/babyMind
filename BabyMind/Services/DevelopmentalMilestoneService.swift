//
//  DevelopmentalMilestoneService.swift
//
//  Gelişimsel kilometre taşları servisi
//

import Foundation
import Combine

class DevelopmentalMilestoneService: ObservableObject {
    @Published var milestones: [DevelopmentalMilestone] = []
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadMilestones()
        if milestones.isEmpty {
            initializeDefaultMilestones()
        }
    }
    
    func initializeDefaultMilestones() {
        let defaultMilestones = getDefaultMilestones()
        milestones = defaultMilestones
        saveMilestones()
    }
    
    private func getDefaultMilestones() -> [DevelopmentalMilestone] {
        return [
            // Motor Gelişim
            DevelopmentalMilestone(
                babyId: babyId,
                category: .motor,
                milestone: "Başını kaldırma",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 1, maxMonths: 3)
            ),
            DevelopmentalMilestone(
                babyId: babyId,
                category: .motor,
                milestone: "Destekle oturma",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 4, maxMonths: 6)
            ),
            DevelopmentalMilestone(
                babyId: babyId,
                category: .motor,
                milestone: "Desteksiz oturma",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 6, maxMonths: 8)
            ),
            DevelopmentalMilestone(
                babyId: babyId,
                category: .motor,
                milestone: "Emekleme",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 7, maxMonths: 10)
            ),
            DevelopmentalMilestone(
                babyId: babyId,
                category: .motor,
                milestone: "Ayakta durma (destekle)",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 8, maxMonths: 11)
            ),
            DevelopmentalMilestone(
                babyId: babyId,
                category: .motor,
                milestone: "Yürüme",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 10, maxMonths: 15)
            ),
            
            // Dil Gelişimi
            DevelopmentalMilestone(
                babyId: babyId,
                category: .language,
                milestone: "Agulama",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 2, maxMonths: 4)
            ),
            DevelopmentalMilestone(
                babyId: babyId,
                category: .language,
                milestone: "Hecelemeler (ba-ba, ma-ma)",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 6, maxMonths: 9)
            ),
            DevelopmentalMilestone(
                babyId: babyId,
                category: .language,
                milestone: "İlk kelime",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 9, maxMonths: 12)
            ),
            DevelopmentalMilestone(
                babyId: babyId,
                category: .language,
                milestone: "2-3 kelimelik cümleler",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 18, maxMonths: 24)
            ),
            
            // Sosyal Gelişim
            DevelopmentalMilestone(
                babyId: babyId,
                category: .social,
                milestone: "Gülümseme",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 1, maxMonths: 3)
            ),
            DevelopmentalMilestone(
                babyId: babyId,
                category: .social,
                milestone: "Yabancı kaygısı",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 6, maxMonths: 9)
            ),
            DevelopmentalMilestone(
                babyId: babyId,
                category: .social,
                milestone: "El sallama",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 9, maxMonths: 12)
            ),
            DevelopmentalMilestone(
                babyId: babyId,
                category: .social,
                milestone: "Taklit etme",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 12, maxMonths: 18)
            ),
            
            // Bilişsel Gelişim
            DevelopmentalMilestone(
                babyId: babyId,
                category: .cognitive,
                milestone: "Nesneleri takip etme",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 2, maxMonths: 4)
            ),
            DevelopmentalMilestone(
                babyId: babyId,
                category: .cognitive,
                milestone: "Nesneleri ağza götürme",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 4, maxMonths: 6)
            ),
            DevelopmentalMilestone(
                babyId: babyId,
                category: .cognitive,
                milestone: "Neden-sonuç ilişkisi",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 6, maxMonths: 9)
            ),
            DevelopmentalMilestone(
                babyId: babyId,
                category: .cognitive,
                milestone: "İşaret etme",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 9, maxMonths: 12)
            ),
            DevelopmentalMilestone(
                babyId: babyId,
                category: .cognitive,
                milestone: "Basit komutları anlama",
                expectedAgeRange: DevelopmentalMilestone.AgeRange(minMonths: 12, maxMonths: 15)
            )
        ]
    }
    
    func markMilestoneAchieved(_ milestone: DevelopmentalMilestone, date: Date = Date(), notes: String? = nil) {
        if let index = milestones.firstIndex(where: { $0.id == milestone.id }) {
            var updated = milestone
            updated.achievedDate = date
            updated.notes = notes
            updated.isDelayed = false
            milestones[index] = updated
            saveMilestones()
        }
    }
    
    func getDelayedMilestones(ageInMonths: Int) -> [DevelopmentalMilestone] {
        return milestones.filter { milestone in
            milestone.achievedDate == nil && ageInMonths > milestone.expectedAgeRange.maxMonths
        }
    }
    
    func getUpcomingMilestones(ageInMonths: Int) -> [DevelopmentalMilestone] {
        return milestones.filter { milestone in
            milestone.achievedDate == nil && 
            ageInMonths >= milestone.expectedAgeRange.minMonths - 1 &&
            ageInMonths <= milestone.expectedAgeRange.maxMonths
        }
    }
    
    func getProgressByCategory() -> [DevelopmentalMilestone.Category: (achieved: Int, total: Int)] {
        var progress: [DevelopmentalMilestone.Category: (achieved: Int, total: Int)] = [:]
        
        for category in DevelopmentalMilestone.Category.allCases {
            let categoryMilestones = milestones.filter { $0.category == category }
            let achieved = categoryMilestones.filter { $0.achievedDate != nil }.count
            progress[category] = (achieved, categoryMilestones.count)
        }
        
        return progress
    }
    
    private func saveMilestones() {
        if let encoded = try? JSONEncoder().encode(milestones) {
            UserDefaults.standard.set(encoded, forKey: "milestones_\(babyId.uuidString)")
        }
    }
    
    private func loadMilestones() {
        if let data = UserDefaults.standard.data(forKey: "milestones_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([DevelopmentalMilestone].self, from: data) {
            milestones = decoded
        }
    }
}


