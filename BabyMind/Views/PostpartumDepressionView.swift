//
//  PostpartumDepressionView.swift
//
//  Doğum sonrası depresyon risk analizi görünümü
//

import SwiftUI

struct PostpartumDepressionView: View {
    let baby: Baby
    @StateObject private var ppdService: PostpartumDepressionService
    @State private var showCheckIn = false
    @Environment(\.colorScheme) var colorScheme
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    init(baby: Baby) {
        self.baby = baby
        _ppdService = StateObject(wrappedValue: PostpartumDepressionService(babyId: baby.id))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: getBackgroundGradient(),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Bugün Nasılsın?")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Risk Analizi Kartı
                    if let analysis = ppdService.currentAnalysis {
                        RiskAnalysisCard(analysis: analysis, theme: theme)
                            .padding(.horizontal, 20)
                    }
                    
                    // Hızlı Check-in Butonu
                    if !ppdService.hasRecordToday() {
                        QuickCheckInCard(theme: theme, onTap: {
                            showCheckIn = true
                        })
                        .padding(.horizontal, 20)
                    } else {
                        TodayCompletedCard(theme: theme)
                            .padding(.horizontal, 20)
                    }
                    
                    // Trend Grafiği
                    if !ppdService.records.isEmpty {
                        TrendChartView(ppdService: ppdService, theme: theme)
                            .padding(.horizontal, 20)
                    }
                    
                    // Son Kayıtlar
                    if !ppdService.records.isEmpty {
                        PPDRecentRecordsView(ppdService: ppdService, theme: theme)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Ruh Sağlığı")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showCheckIn) {
            CheckInView(ppdService: ppdService, baby: baby, theme: theme)
        }
    }
    
    private func getBackgroundGradient() -> [Color] {
        if colorScheme == .dark {
            return theme.backgroundGradient
        } else {
            switch baby.gender {
            case .female:
                return [
                    Color(red: 1.0, green: 0.98, blue: 0.99),
                    Color(red: 0.99, green: 0.96, blue: 0.98),
                    Color.white
                ]
            case .male:
                return [
                    Color(red: 0.98, green: 0.99, blue: 1.0),
                    Color(red: 0.97, green: 0.98, blue: 0.99),
                    Color.white
                ]
            }
        }
    }
}

// MARK: - Risk Analizi Kartı
struct RiskAnalysisCard: View {
    let analysis: DepressionRiskAnalysis
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(analysis.riskLevel.emoji)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(analysis.riskLevel.rawValue)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(
                            red: analysis.riskLevel.color.red,
                            green: analysis.riskLevel.color.green,
                            blue: analysis.riskLevel.color.blue
                        ))
                    
                    Text(analysis.trend.rawValue)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text(analysis.message)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                .padding(.vertical, 8)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Öneriler")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                ForEach(analysis.recommendations, id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(theme.primary)
                        
                        Text(recommendation)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
        )
    }
}

// MARK: - Hızlı Check-in Kartı
struct QuickCheckInCard: View {
    let theme: ColorTheme
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(theme.primary)
                
                Text("2 Dakikalık Check-in")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Text("Bugün nasıl hissediyorsun?")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.primary.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(theme.primary.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Bugün Tamamlandı Kartı
struct TodayCompletedCard: View {
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
            
            Text("Bugünkü check-in tamamlandı")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.95, green: 1.0, blue: 0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Trend Grafiği
struct TrendChartView: View {
    @ObservedObject var ppdService: PostpartumDepressionService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var weeklyTrend: [Date: Double] {
        ppdService.getWeeklyTrend()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Son 14 Gün Trendi")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            
            if !weeklyTrend.isEmpty {
                GeometryReader { geometry in
                    let sortedDates = weeklyTrend.keys.sorted()
                    let maxScore = 1.0
                    let minScore = 0.0
                    
                    ZStack {
                        // Grid çizgileri
                        Path { path in
                            for i in 0...4 {
                                let y = geometry.size.height / 4 * CGFloat(i)
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                            }
                        }
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        
                        // Veri çizgisi
                        if sortedDates.count > 1 {
                            Path { path in
                                for (index, date) in sortedDates.enumerated() {
                                    let score = weeklyTrend[date] ?? 0.0
                                    let x = geometry.size.width / CGFloat(sortedDates.count - 1) * CGFloat(index)
                                    let y = geometry.size.height - ((score - minScore) / (maxScore - minScore) * geometry.size.height)
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                            }
                            .stroke(theme.primary, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                            
                            // Noktalar
                            ForEach(Array(sortedDates.enumerated()), id: \.element) { index, date in
                                let score = weeklyTrend[date] ?? 0.0
                                let x = geometry.size.width / CGFloat(sortedDates.count - 1) * CGFloat(index)
                                let y = geometry.size.height - ((score - minScore) / (maxScore - minScore) * geometry.size.height)
                                
                                Circle()
                                    .fill(theme.primary)
                                    .frame(width: 8, height: 8)
                                    .position(x: x, y: y)
                            }
                        }
                    }
                }
                .frame(height: 200)
            } else {
                Text("Henüz yeterli veri yok")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
        )
    }
}

// MARK: - Son Kayıtlar
struct PPDRecentRecordsView: View {
    @ObservedObject var ppdService: PostpartumDepressionService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Son Kayıtlar")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            
            ForEach(ppdService.records.prefix(7)) { record in
                RecordRow(record: record, theme: theme)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
        )
    }
}

struct RecordRow: View {
    let record: PostpartumDepressionRecord
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(record.date, style: .date)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                HStack(spacing: 12) {
                    Label("\(record.moodScore)/5", systemImage: "face.smiling")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Label("\(Int(record.sleepHours))s", systemImage: "moon.fill")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Skor göstergesi
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 6)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: record.overallScore)
                    .stroke(theme.primary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(record.overallScore * 100))")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(theme.primary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(red: 0.25, green: 0.25, blue: 0.3) : Color(red: 0.98, green: 0.98, blue: 0.99))
        )
    }
}

// MARK: - Check-in Görünümü
struct CheckInView: View {
    @ObservedObject var ppdService: PostpartumDepressionService
    let baby: Baby
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    @State private var moodScore: Int = 3
    @State private var sleepHours: Double = 7.0
    @State private var cryingUrge: Int = 2
    @State private var anxietyLevel: Int = 2
    @State private var hopelessnessLevel: Int = 1
    @State private var socialSupport: Int = 4
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ruh Hali")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bugün genel olarak kendini nasıl hissediyorsun?")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Çok Kötü")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Picker("", selection: $moodScore) {
                                ForEach(1...5, id: \.self) { value in
                                    Text("\(value)").tag(value)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 200)
                            
                            Spacer()
                            
                            Text("Çok İyi")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Uyku")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dün gece kaç saat uyudun?")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Slider(value: $sleepHours, in: 0...12, step: 0.5)
                            Text("\(Int(sleepHours)) saat")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(theme.primary)
                                .frame(width: 70)
                        }
                    }
                }
                
                Section(header: Text("Duygusal Durum")) {
                    VStack(alignment: .leading, spacing: 16) {
                        ScoreSlider(
                            title: "Ağlama isteği",
                            value: $cryingUrge,
                            lowLabel: "Hiç yok",
                            highLabel: "Çok fazla"
                        )
                        
                        ScoreSlider(
                            title: "Kaygı seviyesi",
                            value: $anxietyLevel,
                            lowLabel: "Hiç yok",
                            highLabel: "Çok yüksek"
                        )
                        
                        ScoreSlider(
                            title: "Umutsuzluk hissi",
                            value: $hopelessnessLevel,
                            lowLabel: "Hiç yok",
                            highLabel: "Çok yüksek"
                        )
                    }
                }
                
                Section(header: Text("Sosyal Destek")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sosyal desteğin nasıl? (Aile, arkadaşlar, topluluk)")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Çok Az")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Picker("", selection: $socialSupport) {
                                ForEach(1...5, id: \.self) { value in
                                    Text("\(value)").tag(value)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 200)
                            
                            Spacer()
                            
                            Text("Çok İyi")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Notlar (Opsiyonel)")) {
                    TextField("Bugün hakkında notlar...", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let record = PostpartumDepressionRecord(
                            babyId: baby.id,
                            date: Date(),
                            moodScore: moodScore,
                            sleepHours: sleepHours,
                            cryingUrge: cryingUrge,
                            anxietyLevel: anxietyLevel,
                            hopelessnessLevel: hopelessnessLevel,
                            socialSupport: socialSupport,
                            notes: notes.isEmpty ? nil : notes
                        )
                        ppdService.addRecord(record)
                        HapticManager.shared.notification(type: .success)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ScoreSlider: View {
    let title: String
    @Binding var value: Int
    let lowLabel: String
    let highLabel: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(value)/5")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(lowLabel)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.secondary)
                
                Slider(value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0) }
                ), in: 1...5, step: 1)
                
                Text(highLabel)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
    }
}
