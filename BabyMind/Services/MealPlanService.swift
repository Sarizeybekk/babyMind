//
//  MealPlanService.swift
//
//  Beslenme menü planlayıcı servisi
//

import Foundation
import Combine

class MealPlanService: ObservableObject {
    @Published var mealPlans: [MealPlan] = []
    @Published var allergies: [FoodAllergy] = []
    let babyId: UUID
    private let recipeService: RecipeService
    
    init(babyId: UUID, recipeService: RecipeService = RecipeService()) {
        self.babyId = babyId
        self.recipeService = recipeService
        loadData()
    }
    
    func generateWeeklyMealPlan(ageInMonths: Int) -> MealPlan {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today
        
        var dailyMeals: [MealPlan.DailyMeal] = []
        
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                let meals = generateDailyMeals(for: date, ageInMonths: ageInMonths)
                dailyMeals.append(MealPlan.DailyMeal(date: date, breakfast: meals.breakfast, lunch: meals.lunch, dinner: meals.dinner, snacks: meals.snacks))
            }
        }
        
        let plan = MealPlan(babyId: babyId, weekStartDate: weekStart, meals: dailyMeals)
        addMealPlan(plan)
        return plan
    }
    
    // AI destekli haftalık menü oluşturma
    func generateAIWeeklyMealPlan(
        for baby: Baby,
        aiService: AIService,
        recipeService: RecipeService
    ) async throws -> MealPlan {
        let recipes = recipeService.getRecipes(for: baby)
        let plan = try await aiService.generateWeeklyMealPlan(
            for: baby,
            allergies: allergies,
            existingRecipes: recipes
        )
        addMealPlan(plan)
        return plan
    }
    
    private func generateDailyMeals(for date: Date, ageInMonths: Int) -> (breakfast: [MealPlan.MealItem]?, lunch: [MealPlan.MealItem]?, dinner: [MealPlan.MealItem]?, snacks: [MealPlan.MealItem]?) {
        // Geçici Baby objesi oluştur (sadece yaş için)
        let tempBaby = Baby(name: "", birthDate: Calendar.current.date(byAdding: .month, value: -ageInMonths, to: Date()) ?? Date(), gender: .male)
        let recipes = recipeService.getRecipes(for: tempBaby)
        
        // Yaşa göre menü oluştur
        if ageInMonths < 4 {
            // Sadece anne sütü/formül
            return (nil, nil, nil, nil)
        } else if ageInMonths < 6 {
            // Püreler
            let purees = recipes.filter { $0.category == .puree }
            let breakfast = purees.randomElement().map { [MealPlan.MealItem(name: $0.title, amount: "1 porsiyon")] }
            return (breakfast, nil, nil, nil)
        } else if ageInMonths < 8 {
            // Püreler ve çorbalar
            let breakfast = recipes.filter { $0.category == .puree }.randomElement().map { [MealPlan.MealItem(name: $0.title, amount: "1 porsiyon")] }
            let lunch = recipes.filter { $0.category == .soup }.randomElement().map { [MealPlan.MealItem(name: $0.title, amount: "1 porsiyon")] }
            return (breakfast, lunch, nil, nil)
        } else {
            // Tam menü
            let breakfast = recipes.filter { $0.category == .puree || $0.category == .snack }.randomElement().map { [MealPlan.MealItem(name: $0.title, amount: "1 porsiyon")] }
            let lunch = recipes.filter { $0.category == .soup || $0.category == .main }.randomElement().map { [MealPlan.MealItem(name: $0.title, amount: "1 porsiyon")] }
            let dinner = recipes.filter { $0.category == .main || $0.category == .soup }.randomElement().map { [MealPlan.MealItem(name: $0.title, amount: "1 porsiyon")] }
            let snacks = recipes.filter { $0.category == .snack || $0.category == .fingerFood }.prefix(2).map { MealPlan.MealItem(name: $0.title, amount: "1 porsiyon") }
            return (breakfast, lunch, dinner, snacks.isEmpty ? nil : snacks)
        }
    }
    
    func addMealPlan(_ plan: MealPlan) {
        mealPlans.append(plan)
        saveData()
    }
    
    func updateMealPlan(_ plan: MealPlan) {
        if let index = mealPlans.firstIndex(where: { $0.id == plan.id }) {
            mealPlans[index] = plan
            saveData()
        }
    }
    
    func getCurrentWeekPlan() -> MealPlan? {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today
        
        return mealPlans.first { plan in
            calendar.isDate(plan.weekStartDate, equalTo: weekStart, toGranularity: .weekOfYear)
        }
    }
    
    func addAllergy(_ allergy: FoodAllergy) {
        allergies.append(allergy)
        saveData()
    }
    
    func deleteAllergy(_ allergy: FoodAllergy) {
        allergies.removeAll { $0.id == allergy.id }
        saveData()
    }
    
    func checkAllergyWarning(for recipe: Recipe) -> String? {
        let recipeIngredients = recipe.ingredients.joined(separator: " ").lowercased()
        
        for allergy in allergies {
            if recipeIngredients.contains(allergy.allergen.lowercased()) {
                return "⚠️ Bu tarif \(allergy.allergen) içeriyor. \(allergy.severity.rawValue) alerji riski!"
            }
        }
        
        return nil
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(mealPlans) {
            UserDefaults.standard.set(encoded, forKey: "mealPlans_\(babyId.uuidString)")
        }
        if let encoded = try? JSONEncoder().encode(allergies) {
            UserDefaults.standard.set(encoded, forKey: "allergies_\(babyId.uuidString)")
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "mealPlans_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([MealPlan].self, from: data) {
            mealPlans = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "allergies_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([FoodAllergy].self, from: data) {
            allergies = decoded
        }
    }
}


