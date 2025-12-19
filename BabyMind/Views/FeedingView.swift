//
//  FeedingView.swift
//  BabyMind
//
//  Beslenme ekranı
//

import SwiftUI

struct FeedingView: View {
    let baby: Baby
    @ObservedObject var aiService: AIService
    private let recipeService = RecipeService()
    @StateObject private var mealPlanService: MealPlanService
    @State private var recommendation: Recommendation?
    @State private var recipes: [Recipe] = []
    @State private var isLoading = false
    @State private var showContent = false
    @State private var selectedRecipe: Recipe? = nil
    @State private var showAddAllergy = false
    
    @Environment(\.colorScheme) var colorScheme
    
    init(baby: Baby, aiService: AIService) {
        self.baby = baby
        self.aiService = aiService
        _mealPlanService = StateObject(wrappedValue: MealPlanService(babyId: baby.id))
    }
    
    var body: some View {
        let theme = ColorTheme.theme(for: baby.gender)
        return ZStack {
            // Beyaz arka plan (VisionAnalysisView stili)
            Color.white
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Beslenme")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // AI Önerisi
                    if isLoading {
                        simpleLoadingCard
                            .padding(.horizontal, 20)
                    } else if let recommendation = recommendation {
                        simpleRecommendationCard(recommendation: recommendation)
                            .padding(.horizontal, 20)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
                    }
                    
                    // Beslenme Bilgileri Kartı
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Beslenme Bilgileri")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        VStack(spacing: 16) {
                            ProfessionalInfoRow(
                            icon: "clock.fill",
                                iconColor: theme.primary,
                            title: "Önerilen Beslenme Sıklığı",
                                value: getFeedingFrequency(),
                                subtitle: "Yaşa göre önerilen"
                        )
                        
                            Divider()
                                .background(theme.primary.opacity(0.2))
                            
                            ProfessionalInfoRow(
                            icon: "drop.fill",
                                iconColor: Color(red: 0.6, green: 0.8, blue: 1.0),
                            title: "Günlük Beslenme Miktarı",
                                value: getDailyFeedingAmount(),
                                subtitle: "Toplam beslenme sayısı"
                            )
                            
                            Divider()
                                .background(theme.primary.opacity(0.2))
                            
                            ProfessionalInfoRow(
                                icon: "chart.bar.fill",
                                iconColor: Color(red: 0.9, green: 0.7, blue: 0.5),
                                title: "Bebek Yaşı",
                                value: "\(baby.ageInWeeks) hafta",
                                subtitle: "Gelişim aşaması"
                            )
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                            .shadow(color: theme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
                    
                    // Haftalık Menü Planlayıcı
                    WeeklyMealPlanSection(mealPlanService: mealPlanService, baby: baby, theme: theme)
                        .padding(.horizontal, 20)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: showContent)
                    
                    // Beslenme Çizelgesi
                    FeedingScheduleCard(baby: baby, theme: theme)
                        .padding(.horizontal, 20)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: showContent)
                    
                    // Alerji Uyarıları
                    if !mealPlanService.allergies.isEmpty {
                        AllergyWarningsSection(mealPlanService: mealPlanService, theme: theme, showAddAllergy: $showAddAllergy)
                            .padding(.horizontal, 20)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: showContent)
                    } else {
                        AddAllergyButton(showAddAllergy: $showAddAllergy, theme: theme)
                            .padding(.horizontal, 20)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: showContent)
                    }
                    
                    // Tarifler Bölümü
                    if !recipes.isEmpty {
                        RecipesSection(recipes: recipes, theme: theme, onRecipeTap: { recipe in
                            selectedRecipe = recipe
                        })
                        .padding(.horizontal)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: showContent)
                    } else if baby.ageInMonths >= 4 {
                        // 4 aydan küçük bebekler için tarif yok mesajı
                        VStack(spacing: 12) {
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                            
                            Text("Tarifler yakında eklenecek")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.45))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: theme.primary.opacity(0.05), radius: 10, x: 0, y: 3)
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .refreshable {
                HapticManager.shared.impact(style: .light)
                await loadRecommendation()
            }
            }
            .navigationTitle("Beslenme")
            .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedRecipe) { recipe in
            RecipeDetailView(recipe: recipe, theme: theme, allergyWarning: mealPlanService.checkAllergyWarning(for: recipe))
        }
        .sheet(isPresented: $showAddAllergy) {
            AddFoodAllergyView(mealPlanService: mealPlanService, theme: theme)
        }
            .onAppear {
            Task {
                await loadRecommendation()
            }
            loadRecipes()
            withAnimation {
                showContent = true
            }
        }
    }
    
    private func loadRecommendation() async {
        isLoading = true
        HapticManager.shared.impact(style: .light)
        
            do {
                let rec = try await aiService.getRecommendation(for: baby, category: .feeding)
            try await Task.sleep(nanoseconds: 500_000_000)
            
                await MainActor.run {
                    recommendation = rec
                    isLoading = false
                HapticManager.shared.notification(type: .success)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                HapticManager.shared.notification(type: .error)
            }
        }
    }
    
    private func loadRecipes() {
        recipes = recipeService.getRecipes(for: baby)
    }
    
    private func getFeedingFrequency() -> String {
        let ageInWeeks = baby.ageInWeeks
        if ageInWeeks < 4 {
            return "2-3 saatte bir"
        } else if ageInWeeks < 12 {
            return "3-4 saatte bir"
        } else {
            return "4-5 saatte bir"
        }
    }
    
    private func getDailyFeedingAmount() -> String {
        let ageInWeeks = baby.ageInWeeks
        if ageInWeeks < 4 {
            return "8-12 kez"
        } else if ageInWeeks < 12 {
            return "6-8 kez"
        } else {
            return "4-6 kez"
        }
    }
    
    // MARK: - Simple Loading Card
    @ViewBuilder
    private var simpleLoadingCard: some View {
        let theme = ColorTheme.theme(for: baby.gender)
        HStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: theme.primary))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Yükleniyor...")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Text("AI önerileri hazırlanıyor")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                .shadow(color: theme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Simple Recommendation Card
    @ViewBuilder
    private func simpleRecommendationCard(recommendation: Recommendation) -> some View {
        let theme = ColorTheme.theme(for: baby.gender)
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundColor(theme.primary)
                
                Text("AI Önerisi")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            ScrollView {
                Text(recommendation.description)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.3, green: 0.3, blue: 0.35))
                    .lineSpacing(4)
            }
            .frame(maxHeight: 200)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                .shadow(color: theme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct ProfessionalInfoRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
            Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
            Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.4))
                
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0.6, green: 0.5, blue: 0.55))
            }
            
            Spacer()
        }
    }
}

struct RecipesSection: View {
    let recipes: [Recipe]
    let theme: ColorTheme
    let onRecipeTap: (Recipe) -> Void
    @State private var showItems = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.7, blue: 0.4).opacity(0.3),
                                        Color(red: 0.95, green: 0.6, blue: 0.3).opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "book.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.4))
                    }
                    
                    Text("Bebek Tarifleri")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                }
                
                Spacer()
            }
            
            ForEach(Array(recipes.enumerated()), id: \.element.id) { index, recipe in
                RecipeCard(recipe: recipe, theme: theme)
                    .onTapGesture {
                        HapticManager.shared.impact(style: .light)
                        onRecipeTap(recipe)
                    }
                    .opacity(showItems ? 1 : 0)
                    .offset(y: showItems ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: showItems)
            }
        }
        .onAppear {
            withAnimation {
                showItems = true
            }
        }
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    let theme: ColorTheme
    
    var categoryColor: Color {
        switch recipe.category {
        case .puree: return Color(red: 1.0, green: 0.6, blue: 0.4)
        case .soup: return Color(red: 0.5, green: 0.7, blue: 1.0)
        case .fingerFood: return Color(red: 0.6, green: 0.8, blue: 0.5)
        case .snack: return Color(red: 1.0, green: 0.7, blue: 0.3)
        case .main: return Color(red: 0.6, green: 0.6, blue: 0.6) // Neutral for main category
        }
    }
    
    var categoryIcon: String {
        switch recipe.category {
        case .puree: return "spoon.fill"
        case .soup: return "bowl.fill"
        case .fingerFood: return "hand.point.up.left.fill"
        case .snack: return "leaf.fill"
        case .main: return "fork.knife"
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // İkon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 70, height: 70)
                
                Image(systemName: categoryIcon)
                    .font(.system(size: 30))
                    .foregroundColor(categoryColor)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(recipe.category.rawValue)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(categoryColor.opacity(0.15))
                        .foregroundColor(categoryColor)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                        Text("\(recipe.prepTime) dk")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.45))
                }
                
                Text(recipe.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                
                Text(recipe.description)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.45))
                    .lineLimit(2)
                
                Text(recipe.ageRange)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.6, green: 0.5, blue: 0.55))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: theme.primary.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
}

// MARK: - Haftalık Menü Planlayıcı
struct WeeklyMealPlanSection: View {
    @ObservedObject var mealPlanService: MealPlanService
    let baby: Baby
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    @State private var currentPlan: MealPlan?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("Haftalık Menü Planlayıcı")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            Button(action: {
                HapticManager.shared.impact(style: .medium)
                currentPlan = mealPlanService.generateWeeklyMealPlan(ageInMonths: baby.ageInMonths)
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text("Yeni Haftalık Menü Oluştur")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [theme.primary, theme.primary.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            
            if let plan = currentPlan ?? mealPlanService.getCurrentWeekPlan() {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Bu Haftanın Menüsü")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(plan.meals) { meal in
                                DailyMealCard(meal: meal, theme: theme)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(theme.primary.opacity(0.5))
                    
                    Text("Henüz menü planı oluşturulmamış")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("Yukarıdaki butona tıklayarak haftalık menü planı oluşturabilirsiniz")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                .shadow(color: theme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .onAppear {
            currentPlan = mealPlanService.getCurrentWeekPlan()
        }
    }
}

struct DailyMealCard: View {
    let meal: MealPlan.DailyMeal
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(formatDate(meal.date))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(theme.primary)
            
            if let breakfast = meal.breakfast {
                MealItemRow(title: "Kahvaltı", items: breakfast, theme: theme)
            }
            
            if let lunch = meal.lunch {
                MealItemRow(title: "Öğle", items: lunch, theme: theme)
            }
            
            if let dinner = meal.dinner {
                MealItemRow(title: "Akşam", items: dinner, theme: theme)
            }
            
            if let snacks = meal.snacks {
                MealItemRow(title: "Ara Öğün", items: snacks, theme: theme)
            }
        }
        .padding(16)
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(uiColor: .systemGray5) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "E d MMM"
        return formatter.string(from: date)
    }
}

struct MealItemRow: View {
    let title: String
    let items: [MealPlan.MealItem]
    let theme: ColorTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            
            ForEach(items) { item in
                Text("• \(item.name)")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
            }
        }
    }
}

// MARK: - Beslenme Çizelgesi
struct FeedingScheduleCard: View {
    let baby: Baby
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("Beslenme Çizelgesi")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ScheduleRow(time: "07:00", meal: "Kahvaltı", ageInMonths: baby.ageInMonths)
                ScheduleRow(time: "10:00", meal: "Ara Öğün", ageInMonths: baby.ageInMonths)
                ScheduleRow(time: "13:00", meal: "Öğle Yemeği", ageInMonths: baby.ageInMonths)
                ScheduleRow(time: "16:00", meal: "Ara Öğün", ageInMonths: baby.ageInMonths)
                ScheduleRow(time: "19:00", meal: "Akşam Yemeği", ageInMonths: baby.ageInMonths)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                .shadow(color: theme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct ScheduleRow: View {
    let time: String
    let meal: String
    let ageInMonths: Int
    
    var body: some View {
        HStack {
            Text(time)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                .frame(width: 60, alignment: .leading)
            
            Text(meal)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(getRecommendation(for: meal))
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
    
    private func getRecommendation(for meal: String) -> String {
        if ageInMonths < 4 {
            return "Anne sütü/Formül"
        } else if ageInMonths < 6 {
            return meal == "Ara Öğün" ? "Anne sütü" : "Püre"
        } else if ageInMonths < 8 {
            return meal == "Ara Öğün" ? "Meyve" : "Püre/Çorba"
        } else {
            return "Tam menü"
        }
    }
}

// MARK: - Alerji Uyarıları
struct AllergyWarningsSection: View {
    @ObservedObject var mealPlanService: MealPlanService
    let theme: ColorTheme
    @Binding var showAddAllergy: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                
                Text("Alerji Uyarıları")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
                
                Button(action: {
                    showAddAllergy = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(theme.primary)
                }
            }
            
            ForEach(mealPlanService.allergies) { allergy in
                FoodAllergyCard(allergy: allergy, onDelete: {
                    mealPlanService.deleteAllergy(allergy)
                })
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                .shadow(color: theme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct FoodAllergyCard: View {
    let allergy: FoodAllergy
    let onDelete: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color(
                        red: allergy.severity.color.red,
                        green: allergy.severity.color.green,
                        blue: allergy.severity.color.blue
                    ).opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(
                        red: allergy.severity.color.red,
                        green: allergy.severity.color.green,
                        blue: allergy.severity.color.blue
                    ))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(allergy.allergen)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Text(allergy.severity.rawValue)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(uiColor: .systemGray5) : Color(red: 1.0, green: 0.95, blue: 0.95))
        )
    }
}

struct AddAllergyButton: View {
    @Binding var showAddAllergy: Bool
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            showAddAllergy = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("Alerji Ekle")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                    .shadow(color: theme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
            )
        }
    }
}

struct AddFoodAllergyView: View {
    @ObservedObject var mealPlanService: MealPlanService
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var allergen: String = ""
    @State private var severity: FoodAllergy.Severity = .mild
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Alerjen")) {
                    TextField("Örn: Süt, Yumurta, Fındık", text: $allergen)
                }
                
                Section(header: Text("Şiddet")) {
                    Picker("Şiddet", selection: $severity) {
                        ForEach([FoodAllergy.Severity.mild, .moderate, .severe], id: \.self) { sev in
                            Text(sev.rawValue).tag(sev)
                        }
                    }
                }
                
                Section(header: Text("Notlar (Opsiyonel)")) {
                    TextField("Notlar", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Yeni Alerji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let allergy = FoodAllergy(
                            babyId: mealPlanService.babyId,
                            allergen: allergen,
                            severity: severity,
                            notes: notes.isEmpty ? nil : notes
                        )
                        mealPlanService.addAllergy(allergy)
                        dismiss()
                    }
                    .disabled(allergen.isEmpty)
                }
            }
        }
    }
}

struct RecipeDetailView: View {
    let recipe: Recipe
    let theme: ColorTheme
    let allergyWarning: String?
    @Environment(\.dismiss) var dismiss
    
    var categoryColor: Color {
        switch recipe.category {
        case .puree: return Color(red: 1.0, green: 0.6, blue: 0.4)
        case .soup: return Color(red: 0.5, green: 0.7, blue: 1.0)
        case .fingerFood: return Color(red: 0.6, green: 0.8, blue: 0.5)
        case .snack: return Color(red: 1.0, green: 0.7, blue: 0.3)
        case .main: return Color(red: 0.6, green: 0.6, blue: 0.6) // Neutral for main category
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: theme.backgroundGradient,
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Alerji Uyarısı
                        if let warning = allergyWarning {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                                
                                Text(warning)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 1.0, green: 0.95, blue: 0.95))
                            )
                        }
                        
                        // Başlık
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(recipe.category.rawValue)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(categoryColor.opacity(0.15))
                                    .foregroundColor(categoryColor)
                                    .cornerRadius(10)
                                
                                Spacer()
                                
                                Label("\(recipe.prepTime) dk", systemImage: "clock.fill")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.45))
                            }
                            
                            Text(recipe.title)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                            
                            Text(recipe.description)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.45))
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: theme.primary.opacity(0.1), radius: 15, x: 0, y: 5)
                        )
                        
                        // Malzemeler
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 20))
                                    .foregroundColor(theme.primary)
                                
                                Text("Malzemeler")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                            }
                            
                            ForEach(recipe.ingredients, id: \.self) { ingredient in
                                HStack(alignment: .top, spacing: 12) {
                                    Circle()
                                        .fill(theme.primary)
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 6)
                                    
                                    Text(ingredient)
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: theme.primary.opacity(0.1), radius: 15, x: 0, y: 5)
                        )
                        
                        // Yapılışı
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "list.number")
                                    .font(.system(size: 20))
                                    .foregroundColor(theme.primary)
                                
                                Text("Yapılışı")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                            }
                            
                            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        theme.primary,
                                                        Color(red: 0.9, green: 0.4, blue: 0.65)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 28, height: 28)
                                        
                                        Text("\(index + 1)")
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text(instruction)
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: theme.primary.opacity(0.1), radius: 15, x: 0, y: 5)
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Tarif Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.7))
                }
            }
        }
    }
}

#Preview {
    FeedingView(
        baby: Baby(
            name: "Bebek",
            birthDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
            gender: .male,
            birthWeight: 3.2,
            birthHeight: 50
        ),
        aiService: AIService()
    )
}
