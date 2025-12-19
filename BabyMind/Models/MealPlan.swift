//
//  MealPlan.swift
//
//  Beslenme menü planı modeli
//

import Foundation

struct MealPlan: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let weekStartDate: Date
    var meals: [DailyMeal]
    
    struct DailyMeal: Identifiable, Codable {
        let id: UUID
        let date: Date
        var breakfast: [MealItem]?
        var lunch: [MealItem]?
        var dinner: [MealItem]?
        var snacks: [MealItem]?
        
        init(id: UUID = UUID(),
             date: Date,
             breakfast: [MealItem]? = nil,
             lunch: [MealItem]? = nil,
             dinner: [MealItem]? = nil,
             snacks: [MealItem]? = nil) {
            self.id = id
            self.date = date
            self.breakfast = breakfast
            self.lunch = lunch
            self.dinner = dinner
            self.snacks = snacks
        }
    }
    
    struct MealItem: Identifiable, Codable {
        let id: UUID
        let recipeId: UUID?
        let name: String
        let amount: String? // "100ml", "1 porsiyon", vb.
        let notes: String?
        
        init(id: UUID = UUID(),
             recipeId: UUID? = nil,
             name: String,
             amount: String? = nil,
             notes: String? = nil) {
            self.id = id
            self.recipeId = recipeId
            self.name = name
            self.amount = amount
            self.notes = notes
        }
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         weekStartDate: Date,
         meals: [DailyMeal] = []) {
        self.id = id
        self.babyId = babyId
        self.weekStartDate = weekStartDate
        self.meals = meals
    }
}

struct FoodAllergy: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let allergen: String // "Süt", "Yumurta", "Fındık", vb.
    let severity: Severity
    let notes: String?
    
    enum Severity: String, Codable {
        case mild = "Hafif"
        case moderate = "Orta"
        case severe = "Şiddetli"
        
        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .mild: return (1.0, 0.8, 0.3) // Sarı
            case .moderate: return (1.0, 0.6, 0.3) // Turuncu
            case .severe: return (1.0, 0.3, 0.3) // Kırmızı
            }
        }
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         allergen: String,
         severity: Severity,
         notes: String? = nil) {
        self.id = id
        self.babyId = babyId
        self.allergen = allergen
        self.severity = severity
        self.notes = notes
    }
}
