//
//  BondingActivitiesView.swift
//
//  Anne-bebek bağlanma aktiviteleri görünümü
//

import SwiftUI

struct BondingActivitiesView: View {
    let baby: Baby
    @StateObject private var bondingService: BondingActivityService
    @State private var showAddActivity = false
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    init(baby: Baby) {
        self.baby = baby
        _bondingService = StateObject(wrappedValue: BondingActivityService(babyId: baby.id))
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
                        Text("Bağlanma Aktiviteleri")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Spacer()
                        
                        Button(action: {
                            showAddActivity = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(theme.primary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Haftalık Özet
                    WeeklySummaryCard(bondingService: bondingService, theme: theme)
                        .padding(.horizontal, 20)
                    
                    // Tab Seçici
                    Picker("", selection: $selectedTab) {
                        Text("Oyun Önerileri").tag(0)
                        Text("Masaj").tag(1)
                        Text("Okuma").tag(2)
                        Text("Müzik").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    
                    if selectedTab == 0 {
                        PlaySuggestionsView(bondingService: bondingService, baby: baby, theme: theme)
                            .padding(.horizontal, 20)
                    } else if selectedTab == 1 {
                        MassageGuideView(bondingService: bondingService, theme: theme)
                            .padding(.horizontal, 20)
                    } else if selectedTab == 2 {
                        ReadingGuideView(bondingService: bondingService, theme: theme)
                            .padding(.horizontal, 20)
                    } else {
                        MusicGuideView(bondingService: bondingService, theme: theme)
                            .padding(.horizontal, 20)
                    }
                    
                    // Son Aktiviteler
                    if !bondingService.activities.isEmpty {
                        RecentActivitiesView(bondingService: bondingService, theme: theme)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Bağlanma")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddActivity) {
            AddBondingActivityView(bondingService: bondingService, baby: baby, theme: theme)
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

// MARK: - Haftalık Özet Kartı
struct WeeklySummaryCard: View {
    @ObservedObject var bondingService: BondingActivityService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var summary: (completed: Int, total: Int) {
        bondingService.getWeeklyActivitySummary()
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Bu Hafta")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("\(summary.completed)/\(summary.total)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(theme.primary)
                
                Text("Aktivite Tamamlandı")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 12)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: summary.total > 0 ? Double(summary.completed) / Double(summary.total) : 0)
                    .stroke(theme.primary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
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

// MARK: - Oyun Önerileri
struct PlaySuggestionsView: View {
    @ObservedObject var bondingService: BondingActivityService
    let baby: Baby
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var suggestions: [PlaySuggestion] {
        bondingService.getPlaySuggestions(ageInMonths: baby.ageInMonths)
    }
    
    var body: some View {
        ForEach(suggestions, id: \.ageRange) { suggestion in
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 20))
                        .foregroundColor(theme.primary)
                    
                    Text("Oyun Önerileri - \(suggestion.ageRange)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Aktiviteler")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    ForEach(suggestion.activities, id: \.self) { activity in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(theme.primary)
                            
                            Text(activity)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Faydaları")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    ForEach(suggestion.benefits, id: \.self) { benefit in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.3))
                            
                            Text(benefit)
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
}

// MARK: - Masaj Rehberi
struct MassageGuideView: View {
    @ObservedObject var bondingService: BondingActivityService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("Masaj Teknikleri")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            }
            
            ForEach(bondingService.getMassageTechniques(), id: \.self) { technique in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(theme.primary)
                        .padding(.top, 6)
                    
                    Text(technique)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
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

// MARK: - Okuma Rehberi
struct ReadingGuideView: View {
    @ObservedObject var bondingService: BondingActivityService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "book.fill")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("Okuma Rutinleri")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            }
            
            ForEach(bondingService.getReadingRoutines(), id: \.self) { routine in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(theme.primary)
                    
                    Text(routine)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
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

// MARK: - Müzik Rehberi
struct MusicGuideView: View {
    @ObservedObject var bondingService: BondingActivityService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "music.note")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("Müzik ve Ses Terapisi")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            }
            
            ForEach(bondingService.getMusicTherapyTips(), id: \.self) { tip in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 14))
                        .foregroundColor(theme.primary)
                    
                    Text(tip)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
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

// MARK: - Son Aktiviteler
struct RecentActivitiesView: View {
    @ObservedObject var bondingService: BondingActivityService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Son Aktiviteler")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            
            ForEach(bondingService.activities.prefix(5)) { activity in
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(theme.primary.opacity(0.15))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: activity.activityType.icon)
                            .font(.system(size: 22))
                            .foregroundColor(theme.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(activity.activityType.rawValue)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Text(activity.date, style: .date)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if activity.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
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
    }
}

// MARK: - Aktivite Ekleme
struct AddBondingActivityView: View {
    @ObservedObject var bondingService: BondingActivityService
    let baby: Baby
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    @State private var activityType: BondingActivity.ActivityType = .play
    @State private var date = Date()
    @State private var duration: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Aktivite Tipi")) {
                    Picker("Tip", selection: $activityType) {
                        ForEach(BondingActivity.ActivityType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Tarih ve Süre")) {
                    DatePicker("Tarih", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    TextField("Süre (dakika)", text: $duration)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Notlar (Opsiyonel)")) {
                    TextField("Notlar", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Yeni Aktivite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let durationValue = duration.isEmpty ? nil : TimeInterval(Double(duration) ?? 0) * 60
                        let activity = BondingActivity(
                            babyId: baby.id,
                            activityType: activityType,
                            date: date,
                            duration: durationValue,
                            notes: notes.isEmpty ? nil : notes,
                            isCompleted: true
                        )
                        bondingService.addActivity(activity)
                        HapticManager.shared.notification(type: .success)
                        dismiss()
                    }
                }
            }
        }
    }
}


