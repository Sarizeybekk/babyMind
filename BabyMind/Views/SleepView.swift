//
//  SleepView.swift
//  BabyMind
//
//  Uyku ekranı
//

import SwiftUI

struct SleepView: View {
    let baby: Baby
    @ObservedObject var aiService: AIService
    @StateObject private var sleepService: SleepAnalysisService
    @State private var recommendation: Recommendation?
    @State private var isLoading = false
    @State private var showContent = false
    @State private var selectedDate = Date()
    @Environment(\.colorScheme) var colorScheme
    
    init(baby: Baby, aiService: AIService) {
        self.baby = baby
        self.aiService = aiService
        _sleepService = StateObject(wrappedValue: SleepAnalysisService(babyId: baby.id))
    }
    
    var body: some View {
        let theme = ColorTheme.theme(for: baby.gender)
        
        ZStack {
            // Beyaz arka plan (VisionAnalysisView stili)
            Color.white
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Uyku")
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
                    
                    // Uyku Kalitesi Skoru
                    SleepQualityScoreCard(sleepService: sleepService, theme: theme)
                        .padding(.horizontal, 20)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
                    
                    // Uyku Desenleri Grafiği
                    SleepPatternChart(sleepService: sleepService, theme: theme)
                        .padding(.horizontal, 20)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: showContent)
                    
                    // Optimal Uyku Saatleri
                    OptimalSleepHoursCard(baby: baby, sleepService: sleepService, theme: theme)
                        .padding(.horizontal, 20)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: showContent)
                    
                    // Gece Uyanma Takibi
                    NightWakeTrackingCard(sleepService: sleepService, theme: theme)
                        .padding(.horizontal, 20)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: showContent)
                    
                    // Uyku Bilgileri Kartı
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Uyku Bilgileri")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        VStack(spacing: 16) {
                            ProfessionalInfoRow(
                                icon: "moon.stars.fill",
                                iconColor: Color(red: 0.5, green: 0.5, blue: 0.9),
                                title: "Günlük Toplam Uyku",
                                value: getDailySleepHours(),
                                subtitle: "24 saat içinde"
                            )
                            
                            Divider()
                                .background(Color.pink.opacity(0.2))
                            
                            ProfessionalInfoRow(
                                icon: "bed.double.fill",
                                iconColor: Color(red: 0.6, green: 0.6, blue: 1.0),
                                title: "Gece Uykusu",
                                value: getNightSleepHours(),
                                subtitle: "Gece saatleri"
                            )
                            
                            Divider()
                                .background(Color.pink.opacity(0.2))
                            
                            ProfessionalInfoRow(
                                icon: "sun.max.fill",
                                iconColor: Color(red: 1.0, green: 0.7, blue: 0.3),
                                title: "Gündüz Uykusu",
                                value: getDaySleepHours(),
                                subtitle: "Gün içinde"
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
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: showContent)
                }
                .padding(.vertical)
            }
            .refreshable {
                HapticManager.shared.impact(style: .light)
                await loadRecommendation()
            }
        }
        .navigationTitle("Uyku")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            _Concurrency.Task {
                await loadRecommendation()
            }
            withAnimation {
                showContent = true
            }
        }
    }
    
    private func loadRecommendation() async {
        isLoading = true
        HapticManager.shared.impact(style: .light)
        
        do {
            let rec = try await aiService.getRecommendation(for: baby, category: .sleep)
            try await _Concurrency.Task.sleep(nanoseconds: 500_000_000)
            
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
    
    private func getDailySleepHours() -> String {
        let ageInWeeks = baby.ageInWeeks
        if ageInWeeks < 4 {
            return "14-17 saat"
        } else if ageInWeeks < 12 {
            return "12-16 saat"
        } else {
            return "11-14 saat"
        }
    }
    
    private func getNightSleepHours() -> String {
        let ageInWeeks = baby.ageInWeeks
        if ageInWeeks < 4 {
            return "8-9 saat (kesintili)"
        } else if ageInWeeks < 12 {
            return "9-10 saat"
        } else {
            return "10-12 saat"
        }
    }
    
    private func getDaySleepHours() -> String {
        let ageInWeeks = baby.ageInWeeks
        if ageInWeeks < 4 {
            return "6-8 saat (kısa uykular)"
        } else if ageInWeeks < 12 {
            return "3-5 saat"
        } else {
            return "2-3 saat"
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

// MARK: - Uyku Kalitesi Skoru Kartı
struct SleepQualityScoreCard: View {
    @ObservedObject var sleepService: SleepAnalysisService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var qualityScore: Double {
        sleepService.getAverageSleepQuality()
    }
    
    var qualityColor: Color {
        if qualityScore >= 80 {
            return Color(red: 0.2, green: 0.8, blue: 0.4)
        } else if qualityScore >= 60 {
            return Color(red: 0.4, green: 0.7, blue: 0.9)
        } else if qualityScore >= 40 {
            return Color(red: 1.0, green: 0.7, blue: 0.3)
        } else {
            return Color(red: 1.0, green: 0.4, blue: 0.4)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundColor(qualityColor)
                
                Text("Uyku Kalitesi Skoru")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(qualityColor.opacity(0.2), lineWidth: 12)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: qualityScore / 100)
                        .stroke(qualityColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 4) {
                        Text("\(Int(qualityScore))")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(qualityColor)
                        
                        Text("/100")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(qualityScore >= 80 ? "Mükemmel" : qualityScore >= 60 ? "İyi" : qualityScore >= 40 ? "Orta" : "Geliştirilmeli")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    Text("Son 7 günün ortalaması")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
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

// MARK: - Uyku Desenleri Grafiği
struct SleepPatternChart: View {
    @ObservedObject var sleepService: SleepAnalysisService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("Son 7 Gün Uyku Desenleri")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            let pattern = sleepService.getWeeklySleepPattern()
            let maxHours = pattern.values.max() ?? 1.0
            
            VStack(spacing: 12) {
                ForEach(Array(pattern.keys.sorted()), id: \.self) { date in
                    let hours = pattern[date] ?? 0
                    HStack(spacing: 12) {
                        Text(formatDate(date))
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.secondary)
                            .frame(width: 60, alignment: .leading)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.secondary.opacity(0.1))
                                    .frame(height: 20)
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(LinearGradient(
                                        colors: [theme.primary, theme.primary.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(width: geometry.size.width * (hours / maxHours), height: 20)
                            }
                        }
                        .frame(height: 20)
                        
                        Text(String(format: "%.1f", hours))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                .shadow(color: theme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "E d"
        return formatter.string(from: date)
    }
}

// MARK: - Optimal Uyku Saatleri Kartı
struct OptimalSleepHoursCard: View {
    let baby: Baby
    @ObservedObject var sleepService: SleepAnalysisService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var optimalHours: (start: Int, end: Int) {
        sleepService.getOptimalSleepHours()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("Optimal Uyku Saatleri")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Yatış")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%02d:00", optimalHours.start))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(theme.primary)
                }
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Kalkış")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%02d:00", optimalHours.end))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(theme.primary)
                }
                
                Spacer()
            }
            
            Text("\(baby.ageInWeeks) haftalık bebekler için önerilen uyku saatleri")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                .shadow(color: theme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Gece Uyanma Takibi Kartı
struct NightWakeTrackingCard: View {
    @ObservedObject var sleepService: SleepAnalysisService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var averageWakes: Double {
        sleepService.getAverageNightWakeCount()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "eye.fill")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("Gece Uyanma Takibi")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ortalama")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%.1f", averageWakes))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(theme.primary)
                    
                    Text("kez/gece")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Son 7 gün")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    if averageWakes < 2 {
                        Label("İyi", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                    } else if averageWakes < 4 {
                        Label("Normal", systemImage: "info.circle.fill")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.4, green: 0.7, blue: 0.9))
                    } else {
                        Label("Yüksek", systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                    }
                }
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

#Preview {
    SleepView(
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
