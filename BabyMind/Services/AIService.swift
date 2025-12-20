//
//  AIService.swift
//  BabyMind
//
//  Yapay zekâ servis katmanı
//

import Foundation
import Combine

class AIService: ObservableObject {
    // API anahtarı buraya eklenecek
    private let apiKey: String? = nil
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    // Geçici olarak yerel öneriler döndürüyoruz
    // Gerçek AI entegrasyonu için OpenAI, Anthropic veya başka bir servis kullanılabilir
    
    func getRecommendation(for baby: Baby, category: Recommendation.Category) async throws -> Recommendation {
        // Simüle edilmiş AI yanıtı
        // Gerçek implementasyonda API çağrısı yapılacak
        
        let recommendations = generateLocalRecommendations(for: baby, category: category)
        return recommendations.randomElement() ?? Recommendation(
            category: category,
            title: "Öneri",
            description: "Bebeğiniz için özel öneriler hazırlanıyor..."
        )
    }
    
    private func generateLocalRecommendations(for baby: Baby, category: Recommendation.Category) -> [Recommendation] {
        let ageInWeeks = baby.ageInWeeks
        
        switch category {
        case .feeding:
            if ageInWeeks < 4 {
                return [
                    Recommendation(
                        category: .feeding,
                        title: "Sık Beslenme Önemli",
                        description: "Yenidoğan bebekler genellikle 2-3 saatte bir beslenmeye ihtiyaç duyar. Bebeğinizin açlık belirtilerini (ağlama, elini ağzına götürme) takip edin. Günde 8-12 kez beslenme normaldir.",
                        priority: .high
                    ),
                    Recommendation(
                        category: .feeding,
                        title: "Emzirme Teknikleri",
                        description: "Doğru emzirme pozisyonu hem sizin hem bebeğinizin rahatı için önemlidir. Bebeğin ağzı tamamen meme ucunu kavramalıdır.",
                        priority: .medium
                    )
                ]
            } else if ageInWeeks < 12 {
                return [
                    Recommendation(
                        category: .feeding,
                        title: "Beslenme Düzeni Oluşturun",
                        description: "Bebeğiniz artık daha düzenli beslenme saatleri geliştirebilir. Günde yaklaşık 6-8 kez beslenme normaldir. Beslenme aralıkları 3-4 saate çıkabilir.",
                        priority: .medium
                    ),
                    Recommendation(
                        category: .feeding,
                        title: "Ek Gıdaya Hazırlık",
                        description: "4-6 ay arası bebekler ek gıdaya hazır olabilir. Doktorunuzla görüşerek yavaş yavaş başlayabilirsiniz.",
                        priority: .low
                    )
                ]
            } else {
                return [
                    Recommendation(
                        category: .feeding,
                        title: "Çeşitli Besinler",
                        description: "Bebeğinizin beslenmesinde çeşitlilik önemlidir. Farklı tatlar ve dokular deneyerek bebeğinizin damak zevkini geliştirin.",
                        priority: .medium
                    )
                ]
            }
            
        case .sleep:
            if ageInWeeks < 4 {
                return [
                    Recommendation(
                        category: .sleep,
                        title: "Uyku Düzeni",
                        description: "Yenidoğan bebekler günde 14-17 saat uyur. Uyku saatleri düzensiz olabilir, bu normaldir. Bebeğinizin uyku işaretlerini (esneme, göz ovuşturma) takip edin.",
                        priority: .high
                    ),
                    Recommendation(
                        category: .sleep,
                        title: "Güvenli Uyku",
                        description: "Bebeğinizi sırt üstü yatırın. Yatakta yastık, oyuncak veya gevşek battaniye bulundurmayın. Oda sıcaklığı 18-22°C arasında olmalıdır.",
                        priority: .high
                    )
                ]
            } else if ageInWeeks < 12 {
                return [
                    Recommendation(
                        category: .sleep,
                        title: "Gece Uykusu Gelişiyor",
                        description: "Bebeğiniz gece daha uzun süre uyuyabilir (4-6 saat). Uyku rutini oluşturmaya başlayabilirsiniz. Banyo, masaj ve ninni gibi aktiviteler uyku rutinini güçlendirir.",
                        priority: .medium
                    ),
                    Recommendation(
                        category: .sleep,
                        title: "Gündüz Uykuları",
                        description: "Gündüz 2-3 kısa uyku normaldir. Gündüz uykuları gece uykusunu bozmaz, aksine destekler.",
                        priority: .low
                    )
                ]
            } else {
                return [
                    Recommendation(
                        category: .sleep,
                        title: "Uyku Rutini",
                        description: "Düzenli bir uyku rutini oluşturun. Aynı saatlerde yatırmak ve kaldırmak bebeğinizin biyolojik saatini düzenler.",
                        priority: .medium
                    )
                ]
            }
            
        case .development:
            if ageInWeeks < 12 {
                return [
                    Recommendation(
                        category: .development,
                        title: "Erken Gelişim",
                        description: "Bebeğiniz \(ageInWeeks) haftalık. Bu dönemde başını kaldırma, göz teması ve gülümseme gibi önemli kilometre taşları görülür. Bebeğinizle bol bol konuşun ve göz teması kurun.",
                        priority: .high
                    ),
                    Recommendation(
                        category: .development,
                        title: "Tummy Time",
                        description: "Günde birkaç kez bebeğinizi yüzükoyun yatırın (tummy time). Bu, boyun ve omuz kaslarının gelişimini destekler.",
                        priority: .medium
                    )
                ]
            } else if ageInWeeks < 24 {
                let ageInMonths = baby.ageInMonths
                return [
                    Recommendation(
                        category: .development,
                        title: "Motor Gelişim",
                        description: "Bebeğiniz \(ageInMonths) aylık. Bu dönemde destekle oturma, nesnelere uzanma gibi motor beceriler gelişir. Güvenli oyuncaklarla oyun oynayın.",
                        priority: .medium
                    ),
                    Recommendation(
                        category: .development,
                        title: "Dil Gelişimi",
                        description: "Bebeğinizle sık sık konuşun. Agulama ve hecelemeler başlayabilir. Onun çıkardığı sesleri taklit edin.",
                        priority: .medium
                    )
                ]
            } else {
                let ageInMonths = baby.ageInMonths
                return [
                    Recommendation(
                        category: .development,
                        title: "Aktif Gelişim",
                        description: "Bebeğiniz \(ageInMonths) aylık. Emekleme, ayakta durma gibi büyük motor beceriler gelişiyor. Güvenli bir ortam sağlayın ve keşfetmesine izin verin.",
                        priority: .medium
                    )
                ]
            }
            
        case .health:
            return [
                Recommendation(
                    category: .health,
                    title: "Düzenli Sağlık Kontrolleri",
                    description: "Bebeğinizin düzenli sağlık kontrollerini yaptırmayı unutmayın. Aşı takvimini takip edin ve doktorunuzun önerilerine uyun.",
                    priority: .high
                ),
                Recommendation(
                    category: .health,
                    title: "Ateş Yönetimi",
                    description: "Bebeğinizde ateş varsa (38°C üzeri), özellikle 3 ay altı bebeklerde derhal doktora başvurun. Ilık su ile banyo yaptırabilirsiniz.",
                    priority: .high
                ),
                Recommendation(
                    category: .health,
                    title: "Hijyen",
                    description: "Ellerinizi sık sık yıkayın. Bebeğinizin eşyalarını temiz tutun. Ziyaretçilerden önce el yıkamasını isteyin.",
                    priority: .medium
                )
            ]
            
        case .general:
            return [
                Recommendation(
                    category: .general,
                    title: "Genel Bakım",
                    description: "Bebeğinizin temel ihtiyaçlarını karşıladığınızdan emin olun: beslenme, uyku, temizlik ve sevgi. Her bebek farklıdır, kendi ritmini bulun.",
                    priority: .medium
                ),
                Recommendation(
                    category: .general,
                    title: "Kendinize de İyi Bakın",
                    description: "Bebek bakımı yorucu olabilir. Kendinize zaman ayırın, yeterli uyku alın ve destek isteyin. Mutlu anne = mutlu bebek.",
                    priority: .medium
                ),
                Recommendation(
                    category: .general,
                    title: "Güvenli Ortam",
                    description: "Ev ortamını bebek için güvenli hale getirin. Keskin köşeler, küçük nesneler ve tehlikeli maddeleri bebeğin erişemeyeceği yerlere koyun.",
                    priority: .high
                )
            ]
        }
        
        return []
    }
    
    // Gerçek AI API çağrısı için hazır fonksiyon (şimdilik kullanılmıyor)
    private func callAIAPI(prompt: String) async throws -> String {
        // OpenAI API entegrasyonu buraya eklenecek
        // Örnek yapı:
        /*
        guard let apiKey = apiKey else {
            throw AIError.missingAPIKey
        }
        
        // API çağrısı yapılacak
        */
        
        return ""
    }
    
    // MARK: - AI Destekli Haftalık Menü Oluşturma
    
    func generateWeeklyMealPlan(
        for baby: Baby,
        allergies: [FoodAllergy],
        existingRecipes: [Recipe]
    ) async throws -> MealPlan {
        // AI ile haftalık menü oluştur
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today
        
        // Alerji bilgilerini string'e çevir
        let allergyList = allergies.map { $0.allergen }.joined(separator: ", ")
        let allergyInfo = allergies.isEmpty ? "Alerji yok" : "Alerjiler: \(allergyList)"
        
        // Yaşa göre özel öneriler
        let ageRecommendations = getAgeBasedMealRecommendations(ageInMonths: baby.ageInMonths)
        
        // AI ile menü oluştur (şimdilik yerel mantık, gerçek AI entegrasyonu için hazır)
        var dailyMeals: [MealPlan.DailyMeal] = []
        
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                let meals = await generateAIMealForDay(
                    date: date,
                    ageInMonths: baby.ageInMonths,
                    allergies: allergies,
                    existingRecipes: existingRecipes,
                    dayOfWeek: dayOffset
                )
                dailyMeals.append(MealPlan.DailyMeal(
                    date: date,
                    breakfast: meals.breakfast,
                    lunch: meals.lunch,
                    dinner: meals.dinner,
                    snacks: meals.snacks
                ))
            }
        }
        
        return MealPlan(
            babyId: baby.id,
            weekStartDate: weekStart,
            meals: dailyMeals
        )
    }
    
    private func getAgeBasedMealRecommendations(ageInMonths: Int) -> String {
        switch ageInMonths {
        case 0..<4:
            return "Sadece anne sütü veya formül mama. Ek gıdaya başlanmamalı."
        case 4..<6:
            return "Püreler ve yumuşak gıdalar. Tek malzemeden başla, 3-5 gün bekle."
        case 6..<8:
            return "Püreler, çorbalar ve yumuşak parmak gıdalar. Çeşitlilik artırılabilir."
        case 8..<12:
            return "Yumuşak parmak gıdalar, çorbalar ve püreler. Aile sofrasına uyum başlar."
        default:
            return "Çeşitli gıdalar, aile sofrasına uyum. Besin değeri yüksek gıdalar."
        }
    }
    
    private func generateAIMealForDay(
        date: Date,
        ageInMonths: Int,
        allergies: [FoodAllergy],
        existingRecipes: [Recipe],
        dayOfWeek: Int
    ) async -> (
        breakfast: [MealPlan.MealItem]?,
        lunch: [MealPlan.MealItem]?,
        dinner: [MealPlan.MealItem]?,
        snacks: [MealPlan.MealItem]?
    ) {
        // Alerji kontrolü için fonksiyon
        func isSafeRecipe(_ recipe: Recipe) -> Bool {
            let recipeText = (recipe.title + " " + recipe.ingredients.joined(separator: " ")).lowercased()
            for allergy in allergies {
                if recipeText.contains(allergy.allergen.lowercased()) {
                    return false
                }
            }
            return true
        }
        
        // Yaşa göre filtrele
        var availableRecipes = existingRecipes.filter { isSafeRecipe($0) }
        
        if ageInMonths < 4 {
            return (nil, nil, nil, nil)
        } else if ageInMonths < 6 {
            // Sadece püreler
            let purees = availableRecipes.filter { $0.category == .puree }
            let breakfast = purees.randomElement().map { [MealPlan.MealItem(name: $0.title, amount: "1 porsiyon", notes: "Alerji kontrolü yapıldı")] }
            return (breakfast, nil, nil, nil)
        } else if ageInMonths < 8 {
            // Püreler ve çorbalar
            let purees = availableRecipes.filter { $0.category == .puree }
            let soups = availableRecipes.filter { $0.category == .soup }
            
            // Hafta içi çeşitlilik için gün bazlı seçim
            let breakfastIndex = dayOfWeek % purees.count
            let lunchIndex = dayOfWeek % soups.count
            
            let breakfast = purees.indices.contains(breakfastIndex) ? [MealPlan.MealItem(name: purees[breakfastIndex].title, amount: "1 porsiyon", notes: "Alerji kontrolü yapıldı")] : nil
            let lunch = soups.indices.contains(lunchIndex) ? [MealPlan.MealItem(name: soups[lunchIndex].title, amount: "1 porsiyon", notes: "Alerji kontrolü yapıldı")] : nil
            
            return (breakfast, lunch, nil, nil)
        } else {
            // Tam menü - çeşitlilik için gün bazlı rotasyon
            let purees = availableRecipes.filter { $0.category == .puree || $0.category == .snack }
            let soups = availableRecipes.filter { $0.category == .soup }
            let mains = availableRecipes.filter { $0.category == .main }
            let snacks = availableRecipes.filter { $0.category == .snack || $0.category == .fingerFood }
            
            // Gün bazlı rotasyon
            let breakfast = purees.indices.contains(dayOfWeek % max(purees.count, 1)) ? [MealPlan.MealItem(name: purees[dayOfWeek % max(purees.count, 1)].title, amount: "1 porsiyon", notes: "Alerji kontrolü yapıldı")] : nil
            let lunch = soups.indices.contains(dayOfWeek % max(soups.count, 1)) ? [MealPlan.MealItem(name: soups[dayOfWeek % max(soups.count, 1)].title, amount: "1 porsiyon", notes: "Alerji kontrolü yapıldı")] : nil
            let dinner = mains.indices.contains(dayOfWeek % max(mains.count, 1)) ? [MealPlan.MealItem(name: mains[dayOfWeek % max(mains.count, 1)].title, amount: "1 porsiyon", notes: "Alerji kontrolü yapıldı")] : nil
            let snackItems = Array(snacks.prefix(2)).map { MealPlan.MealItem(name: $0.title, amount: "1 porsiyon", notes: "Alerji kontrolü yapıldı") }
            
            return (breakfast, lunch, dinner, snackItems.isEmpty ? nil : snackItems)
        }
    }
}

enum AIError: Error {
    case missingAPIKey
    case networkError
    case invalidResponse
}





