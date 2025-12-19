//
//  CryAnalysisView.swift
//
//  Ağlama analizi görünümü
//

import SwiftUI
import AVFoundation

struct CryAnalysisView: View {
    let baby: Baby
    @StateObject private var cryService: CryAnalysisService
    @State private var isRecording = false
    @State private var recordingURL: URL?
    @State private var showAnalysisResult = false
    @State private var currentAnalysis: CryAnalysis?
    @State private var isAnalyzing = false
    @State private var notes: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    init(baby: Baby) {
        self.baby = baby
        _cryService = StateObject(wrappedValue: CryAnalysisService(babyId: baby.id))
    }
    
    var body: some View {
        ZStack {
            // Cinsiyete göre hafif renkli gradient arka plan
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
                        Text("Ağlama Analizi")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Kayıt Bölümü
                    RecordingSection(
                        isRecording: cryService.isRecording,
                        recordingDuration: cryService.recordingDuration,
                        onStart: {
                            recordingURL = cryService.startRecording()
                            HapticManager.shared.impact(style: .medium)
                        },
                        onStop: {
                            recordingURL = cryService.stopRecording()
                            HapticManager.shared.impact(style: .light)
                            if let url = recordingURL {
                                isAnalyzing = true
                                cryService.analyzeCry(audioURL: url, notes: notes.isEmpty ? nil : notes) { analysis in
                                    currentAnalysis = analysis
                                    showAnalysisResult = true
                                    isAnalyzing = false
                                    notes = ""
                                    HapticManager.shared.notification(type: .success)
                                }
                            }
                        }
                    )
                    .padding(.horizontal, 20)
                    
                    // Notlar
                    if cryService.isRecording {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notlar (Opsiyonel)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                            
                            TextField("Ağlama hakkında notlar...", text: $notes, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...5)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Analiz Sonuçları
                    if isAnalyzing {
                        AnalyzingView()
                            .padding(.horizontal, 20)
                    }
                    
                    // Son Analizler
                    if !cryService.analyses.isEmpty {
                        RecentAnalysesSection(
                            cryService: cryService,
                            theme: theme
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // İstatistikler
                    if !cryService.analyses.isEmpty {
                        CryStatisticsSection(
                            cryService: cryService
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Ağlama Analizi")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAnalysisResult) {
            if let analysis = currentAnalysis {
                CryAnalysisResultView(
                    analysis: analysis,
                    theme: theme,
                    onDismiss: {
                        showAnalysisResult = false
                    }
                )
            }
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

// MARK: - Kayıt Bölümü
struct RecordingSection: View {
    let isRecording: Bool
    let recordingDuration: TimeInterval
    let onStart: () -> Void
    let onStop: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            // Büyük kayıt butonu
            Button(action: {
                if isRecording {
                    onStop()
                } else {
                    onStart()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(isRecording ? Color.red : Color(red: 0.3, green: 0.7, blue: 0.9))
                        .frame(width: 120, height: 120)
                        .shadow(color: (isRecording ? Color.red : Color(red: 0.3, green: 0.7, blue: 0.9)).opacity(0.4), radius: 20, x: 0, y: 10)
                    
                    if isRecording {
                        // Kayıt animasyonu
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 40, height: 40)
                            .opacity(0.8)
                    } else {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Süre gösterimi
            if isRecording {
                Text(formatDuration(recordingDuration))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color.red)
                
                Text("Kayıt alınıyor...")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            } else {
                Text("Kayıt Başlat")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
        )
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Analiz Yapılıyor Görünümü
struct AnalyzingView: View {
    @State private var rotation: Double = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color(red: 0.3, green: 0.7, blue: 0.9).opacity(0.3), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color(red: 0.3, green: 0.7, blue: 0.9), lineWidth: 4)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
            }
            
            Text("Analiz yapılıyor...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
        )
    }
}

// MARK: - Son Analizler Bölümü
struct RecentAnalysesSection: View {
    @ObservedObject var cryService: CryAnalysisService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Son Analizler")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
            
            VStack(spacing: 12) {
                ForEach(cryService.getRecentAnalyses(limit: 5)) { analysis in
                    CryAnalysisCard(
                        analysis: analysis,
                        onDelete: {
                            cryService.deleteAnalysis(analysis)
                        }
                    )
                }
            }
        }
    }
}

struct CryAnalysisCard: View {
    let analysis: CryAnalysis
    let onDelete: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // İkon
            ZStack {
                Circle()
                    .fill(Color(
                        red: analysis.cryType.color.red,
                        green: analysis.cryType.color.green,
                        blue: analysis.cryType.color.blue
                    ).opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: analysis.cryType.icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color(
                        red: analysis.cryType.color.red,
                        green: analysis.cryType.color.green,
                        blue: analysis.cryType.color.blue
                    ))
            }
            
            // Bilgiler
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(analysis.cryType.rawValue)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    Spacer()
                    
                    Text("\(Int(analysis.confidence * 100))%")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.secondary.opacity(0.1))
                        )
                }
                
                HStack(spacing: 8) {
                    Text(analysis.date, style: .time)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(analysis.duration))sn")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                if let recommendation = analysis.aiRecommendation {
                    Text(recommendation)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.top, 4)
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - İstatistikler Bölümü
struct CryStatisticsSection: View {
    @ObservedObject var cryService: CryAnalysisService
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("İstatistikler")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
            
            let stats = calculateStatistics()
            
            VStack(spacing: 12) {
                ForEach(Array(stats.keys.sorted(by: { stats[$0]! > stats[$1]! })), id: \.self) { type in
                    if let count = stats[type], count > 0 {
                        StatRow(
                            cryType: type,
                            count: count,
                            total: cryService.analyses.count
                        )
                    }
                }
            }
        }
    }
    
    private func calculateStatistics() -> [CryAnalysis.CryType: Int] {
        var stats: [CryAnalysis.CryType: Int] = [:]
        for analysis in cryService.analyses {
            stats[analysis.cryType, default: 0] += 1
        }
        return stats
    }
}

struct StatRow: View {
    let cryType: CryAnalysis.CryType
    let count: Int
    let total: Int
    @Environment(\.colorScheme) var colorScheme
    
    var percentage: Double {
        total > 0 ? Double(count) / Double(total) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: cryType.icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(
                        red: cryType.color.red,
                        green: cryType.color.green,
                        blue: cryType.color.blue
                    ))
                
                Text(cryType.rawValue)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
                
                Text("\(count) kez")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(
                            red: cryType.color.red,
                            green: cryType.color.green,
                            blue: cryType.color.blue
                        ))
                        .frame(width: geometry.size.width * percentage, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Analiz Sonuç Görünümü
struct CryAnalysisResultView: View {
    let analysis: CryAnalysis
    let theme: ColorTheme
    let onDismiss: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Sonuç Kartı
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color(
                                    red: analysis.cryType.color.red,
                                    green: analysis.cryType.color.green,
                                    blue: analysis.cryType.color.blue
                                ).opacity(0.15))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: analysis.cryType.icon)
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(Color(
                                    red: analysis.cryType.color.red,
                                    green: analysis.cryType.color.green,
                                    blue: analysis.cryType.color.blue
                                ))
                        }
                        
                        Text(analysis.cryType.rawValue)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Text("Güven: %\(Int(analysis.confidence * 100))")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
                    )
                    
                    // AI Önerisi
                    if let recommendation = analysis.aiRecommendation {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 20))
                                    .foregroundColor(theme.primary)
                                
                                Text("AI Önerisi")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                            }
                            
                            Text(recommendation)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
                        )
                    }
                    
                    // Detaylar
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detaylar")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        CryDetailRow(title: "Tarih", value: formatDate(analysis.date))
                        CryDetailRow(title: "Süre", value: "\(Int(analysis.duration)) saniye")
                        CryDetailRow(title: "Güven Skoru", value: "%\(Int(analysis.confidence * 100))")
                        
                        if let notes = analysis.notes, !notes.isEmpty {
                            CryDetailRow(title: "Notlar", value: notes)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
                    )
                }
                .padding()
            }
            .navigationTitle("Analiz Sonucu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tamam") {
                        onDismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct CryDetailRow: View {
    let title: String
    let value: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
        }
        .padding(.vertical, 4)
    }
}
