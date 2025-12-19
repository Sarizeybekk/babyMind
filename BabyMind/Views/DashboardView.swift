//
//  DashboardView.swift
//  BabyMind
//
//  Ana dashboard ekranı
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var babyManager: BabyManager
    @ObservedObject var aiService: AIService
    @State private var recommendation: Recommendation?
    @State private var showContent = false
    @State private var showAddBaby = false
    @State private var showBabySelection = false
    @StateObject private var activityLogger: ActivityLogger
    @Environment(\.colorScheme) var colorScheme
    
    init(babyManager: BabyManager, aiService: AIService) {
        self.babyManager = babyManager
        self.aiService = aiService
        if let baby = babyManager.selectedBaby {
            _activityLogger = StateObject(wrappedValue: ActivityLogger(babyId: baby.id))
        } else {
            _activityLogger = StateObject(wrappedValue: ActivityLogger(babyId: UUID()))
        }
    }
    
    var body: some View {
        Group {
            if let baby = babyManager.selectedBaby {
                let theme = ColorTheme.theme(for: baby.gender)
                
                ZStack {
                    // Cinsiyete göre hafif renkli gradient arka plan (sağlık sayfasındaki gibi)
                    LinearGradient(
                        colors: getBackgroundGradient(for: baby.gender),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Bebek Profil Kartı (Pembe arka plan)
                            BabyInfoCard(
                                baby: baby,
                                theme: theme,
                                babyManager: babyManager,
                                showAddBaby: $showAddBaby,
                                showBabySelection: $showBabySelection
                            )
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                            
                            // Üst 3 Kart (Takvim, Ağırlık, Boy)
                            TopMetricsRow(baby: baby)
                                .padding(.horizontal, 20)
                            
                            // Bugünün Özeti
                            TodaySummarySection(activityLogger: activityLogger)
                                .padding(.horizontal, 20)
                            
                            // Hızlı Aksiyonlar
                            QuickAccessSection(baby: baby, theme: theme, aiService: aiService)
                                .padding(.horizontal, 20)
                            
                            Spacer(minLength: 20)
                        }
                        .padding(.vertical, 10)
                    }
                }
                .navigationTitle("Ana Sayfa")
                .navigationBarTitleDisplayMode(.large)
                .sheet(isPresented: $showAddBaby) {
                    BabyInfoView(babyManager: babyManager, isFirstBaby: false)
                }
                .sheet(isPresented: $showBabySelection) {
                    BabySelectionView(babyManager: babyManager)
                }
                .onAppear {
                    loadRecommendation(for: baby)
                    withAnimation {
                        showContent = true
                    }
                }
            } else {
                EmptyDashboardView()
            }
        }
    }
    
    private func loadRecommendation(for baby: Baby) {
        Task {
            do {
                let rec = try await aiService.getRecommendation(for: baby, category: .general)
                await MainActor.run {
                    recommendation = rec
                }
            } catch {
                // Hata durumunda sessizce devam et
            }
        }
    }
    
    private func getBackgroundGradient(for gender: Baby.Gender) -> [Color] {
        if colorScheme == .dark {
            let theme = ColorTheme.theme(for: gender)
            return theme.backgroundGradient
        } else {
            // Light mode için cinsiyete göre hafif renkli gradient
            switch gender {
            case .female:
                // Kız bebek için hafif pembe tonları
                return [
                    Color(red: 1.0, green: 0.98, blue: 0.99),
                    Color(red: 0.99, green: 0.96, blue: 0.98),
                    Color.white
                ]
            case .male:
                // Erkek bebek için hafif mavi tonları
                return [
                    Color(red: 0.98, green: 0.99, blue: 1.0),
                    Color(red: 0.97, green: 0.98, blue: 0.99),
                    Color.white
                ]
            }
        }
    }
}

struct BabyInfoCard: View {
    let baby: Baby
    let theme: ColorTheme
    let babyManager: BabyManager
    @Binding var showAddBaby: Bool
    @Binding var showBabySelection: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Sol tarafta pembe kalp ikonu
            ZStack {
                Circle()
                    .fill(theme.primary.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 24))
                    .foregroundColor(theme.primary)
            }
            
            // Bebek Bilgileri - Tıklanabilir (bebek seçimi için)
            Button(action: {
                if babyManager.babies.count > 1 {
                    HapticManager.shared.selection()
                    showBabySelection = true
                }
            }) {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(baby.name.isEmpty ? "Bebeğiniz" : baby.name)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        HStack(spacing: 4) {
                            Text("\(baby.ageInWeeks) hafta • \(baby.ageInMonths) ay")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            if babyManager.babies.count > 1 {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if babyManager.babies.count > 1 {
                        Spacer()
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Sağ tarafta pembe + butonu (yeni bebek ekleme)
            Button(action: {
                HapticManager.shared.impact(style: .light)
                showAddBaby = true
            }) {
                ZStack {
                    Circle()
                        .fill(theme.primary.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(theme.primary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.primary.opacity(0.12))
        )
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
    }
}

struct DailyStatsCard: View {
    let baby: Baby
    @ObservedObject var activityLogger: ActivityLogger
    let theme: ColorTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bugün")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                DashboardStatCard(
                    icon: "fork.knife",
                    title: "Beslenme",
                    value: String(format: "%.0f ml", activityLogger.getTotalFeedingToday()),
                    color: Color(red: 0.2, green: 0.7, blue: 0.9)
                )
                
                DashboardStatCard(
                    icon: "bed.double.fill",
                    title: "Uyku",
                    value: formatSleepTime(activityLogger.getTotalSleepToday()),
                    color: Color(red: 0.6, green: 0.4, blue: 0.9)
                )
                
                DashboardStatCard(
                    icon: "heart.text.square.fill",
                    title: "Aktivite",
                    value: "\(activityLogger.getTodayLogs().count)",
                    color: Color(red: 1.0, green: 0.5, blue: 0.7)
                )
                
                DashboardStatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Gelişim",
                    value: "\(baby.ageInWeeks) hafta",
                    color: Color(red: 0.3, green: 0.8, blue: 0.5)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: theme.primary.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
    
    private func formatSleepTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        if hours > 0 {
            return "\(hours)s \(minutes)dk"
        } else {
            return "\(minutes)dk"
        }
    }
}

struct DashboardStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct QuickAccessSection: View {
    let baby: Baby
    let theme: ColorTheme
    @ObservedObject var aiService: AIService
    
    // Bez butonu için renk - görüntüde mavi görünüyor ama kız için pembe yapacağız
    private var bezButtonColor: Color {
        switch baby.gender {
        case .female:
            return Color(red: 1.0, green: 0.18, blue: 0.58) // PEMBE (kız için)
        case .male:
            return Color(red: 0.0, green: 0.48, blue: 1.0) // MAVI (erkek için)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hızlı Aksiyonlar")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                .padding(.horizontal, 4)
            
            HStack(spacing: 12) {
                // Beslenme butonu (mavi) - FeedingView'a navigate
                NavigationLink(destination: FeedingView(baby: baby, aiService: aiService)) {
                    QuickAccessButton(
                        icon: "drop.fill",
                        title: "Beslenme",
                        color: Color(red: 0.5, green: 0.7, blue: 1.0)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Uyku butonu (mor - ay ve yıldızlar) - SleepView'a navigate
                NavigationLink(destination: SleepView(baby: baby, aiService: aiService)) {
                    QuickAccessButton(
                        icon: "moon.stars.fill",
                        title: "Uyku",
                        color: Color(red: 0.6, green: 0.6, blue: 1.0)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Bez butonu (normal buton - turuncu renk) - ActivityLogView'a navigate
                NavigationLink(destination: ActivityLogView(baby: baby)) {
                    QuickAccessButton(
                        icon: "hand.raised.fill",
                        title: "Bez",
                        color: Color(red: 1.0, green: 0.7, blue: 0.4)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct QuickAccessButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Arka plan daire
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                // İkon
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// Bez butonu - sadece turuncu çizgili daire (renkli daire kaldırıldı)
struct BezQuickAccessButton: View {
    let title: String
    let color: Color // Kullanılmıyor ama parametre olarak kalıyor
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Sadece turuncu çizgili daire
                ZStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.7, blue: 0.4).opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    // Dikey çizgili desen
                    HStack(spacing: 1.5) {
                        ForEach(0..<6) { _ in
                            Rectangle()
                                .fill(Color(red: 1.0, green: 0.7, blue: 0.4).opacity(0.5))
                                .frame(width: 2.5)
                        }
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                }
            }
            
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

struct RecentActivitiesCard: View {
    @ObservedObject var activityLogger: ActivityLogger
    let theme: ColorTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Son Aktiviteler")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            let recentLogs = Array(activityLogger.getTodayLogs().prefix(5))
            
            if recentLogs.isEmpty {
                Text("Henüz aktivite kaydı yok")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(recentLogs) { log in
                        DashboardActivityRow(log: log, theme: theme)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: theme.primary.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
}

struct DashboardActivityRow: View {
    let log: ActivityLog
    let theme: ColorTheme
    
    private var icon: String {
        switch log.type {
        case .feeding: return "fork.knife"
        case .sleep: return "bed.double.fill"
        case .diaper: return "drop.fill"
        case .medication: return "pills.fill"
        }
    }
    
    private var color: Color {
        switch log.type {
        case .feeding: return Color(red: 0.2, green: 0.7, blue: 0.9)
        case .sleep: return Color(red: 0.6, green: 0.4, blue: 0.9)
        case .diaper: return Color(red: 0.9, green: 0.7, blue: 0.2)
        case .medication: return Color(red: 1.0, green: 0.3, blue: 0.3)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(log.type.rawValue)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(formatDate(log.date))
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let amount = log.amount {
                Text(String(format: "%.0f ml", amount))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(color)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct EmptyDashboardView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Bebek seçilmedi")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Üst 3 Metrik Kartı (Takvim, Ağırlık, Boy)
struct TopMetricsRow: View {
    let baby: Baby
    
    var body: some View {
        HStack(spacing: 12) {
            // Takvim kartı (mavi)
            MetricCard(
                icon: "calendar",
                iconColor: Color(red: 0.2, green: 0.6, blue: 1.0),
                value: "\(baby.ageInMonths)",
                unit: "ay"
            )
            
            // Ağırlık kartı (turuncu)
            MetricCard(
                icon: "scalemass.fill",
                iconColor: Color(red: 1.0, green: 0.7, blue: 0.4),
                value: String(format: "%.2f", baby.currentWeight ?? baby.birthWeight),
                unit: "kg"
            )
            
            // Boy kartı (yeşil)
            MetricCard(
                icon: "ruler.fill",
                iconColor: Color(red: 0.3, green: 0.8, blue: 0.5),
                value: String(format: "%.0f", baby.currentHeight ?? baby.birthHeight),
                unit: "cm"
            )
        }
    }
}

struct MetricCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(iconColor)
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
            
            Text(unit)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// Bugünün Özeti Bölümü
struct TodaySummarySection: View {
    @ObservedObject var activityLogger: ActivityLogger
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bugünün Özeti")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                .padding(.horizontal, 4)
            
            HStack(spacing: 12) {
                // Beslenme
                DashboardSummaryCard(
                    icon: "drop.fill",
                    iconColor: Color(red: 0.5, green: 0.7, blue: 1.0),
                    value: String(format: "%.0f", activityLogger.getTotalFeedingToday()),
                    title: "Beslenme",
                    subtitle: "kez"
                )
                
                // Uyku
                DashboardSummaryCard(
                    icon: "moon.stars.fill",
                    iconColor: Color(red: 0.6, green: 0.6, blue: 1.0),
                    value: formatSleepTime(activityLogger.getTotalSleepToday()),
                    title: "Uyku",
                    subtitle: "toplam"
                )
                
                // Bez değişim
                DashboardSummaryCard(
                    icon: "hand.raised.fill",
                    iconColor: Color(red: 1.0, green: 0.7, blue: 0.4),
                    value: "\(activityLogger.getTodayLogs().filter { $0.type == .diaper }.count)",
                    title: "Bez",
                    subtitle: "değişim"
                )
            }
        }
    }
    
    private func formatSleepTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        if hours > 0 {
            return "\(hours)d"
        } else {
            return "\(minutes)dk"
        }
    }
}

struct DashboardSummaryCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(iconColor)
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Text(subtitle)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    NavigationView {
        DashboardView(
            babyManager: BabyManager(),
            aiService: AIService()
        )
    }
}
