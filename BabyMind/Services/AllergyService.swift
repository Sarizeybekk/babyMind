//
//  AllergyService.swift
//  BabyMind
//
//  Alerji takip servisi
//

import Foundation
import Combine

class AllergyService: ObservableObject {
    @Published var allergies: [Allergy] = []
    @Published var reactions: [AllergyReaction] = []
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadAllergies()
        loadReactions()
    }
    
    func addAllergy(_ allergy: Allergy) {
        allergies.append(allergy)
        saveAllergies()
    }
    
    func updateAllergy(_ allergy: Allergy) {
        if let index = allergies.firstIndex(where: { $0.id == allergy.id }) {
            allergies[index] = allergy
            saveAllergies()
        }
    }
    
    func deleteAllergy(_ allergy: Allergy) {
        allergies.removeAll { $0.id == allergy.id }
        reactions.removeAll { $0.allergyId == allergy.id }
        saveAllergies()
        saveReactions()
    }
    
    func addReaction(_ reaction: AllergyReaction) {
        reactions.append(reaction)
        reactions.sort { $0.date > $1.date }
        saveReactions()
    }
    
    func getReactions(for allergy: Allergy) -> [AllergyReaction] {
        return reactions.filter { $0.allergyId == allergy.id }
            .sorted { $0.date > $1.date }
    }
    
    func getAllergiesByCategory(_ category: Allergy.AllergyCategory) -> [Allergy] {
        return allergies.filter { $0.category == category }
    }
    
    private func saveAllergies() {
        if let encoded = try? JSONEncoder().encode(allergies) {
            UserDefaults.standard.set(encoded, forKey: "allergies_\(babyId.uuidString)")
        }
    }
    
    private func loadAllergies() {
        if let data = UserDefaults.standard.data(forKey: "allergies_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([Allergy].self, from: data) {
            allergies = decoded
        }
    }
    
    private func saveReactions() {
        if let encoded = try? JSONEncoder().encode(reactions) {
            UserDefaults.standard.set(encoded, forKey: "allergyReactions_\(babyId.uuidString)")
        }
    }
    
    private func loadReactions() {
        if let data = UserDefaults.standard.data(forKey: "allergyReactions_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([AllergyReaction].self, from: data) {
            reactions = decoded.sorted { $0.date > $1.date }
        }
    }
}







