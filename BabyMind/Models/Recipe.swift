//
//  Recipe.swift
//  BabyMind
//
//  Bebek tarifleri modeli
//

import Foundation

struct Recipe: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let ageRange: String // "4-6 ay", "6-8 ay", vb.
    let ingredients: [String]
    let instructions: [String]
    let prepTime: Int // dakika
    let category: RecipeCategory
    let imageName: String?
    
    enum RecipeCategory: String, Codable, CaseIterable {
        case puree = "Püre"
        case soup = "Çorba"
        case fingerFood = "Parmak Gıda"
        case snack = "Ara Öğün"
        case main = "Ana Yemek"
    }
    
    init(id: UUID = UUID(),
         title: String,
         description: String,
         ageRange: String,
         ingredients: [String],
         instructions: [String],
         prepTime: Int,
         category: RecipeCategory,
         imageName: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.ageRange = ageRange
        self.ingredients = ingredients
        self.instructions = instructions
        self.prepTime = prepTime
        self.category = category
        self.imageName = imageName
    }
}



