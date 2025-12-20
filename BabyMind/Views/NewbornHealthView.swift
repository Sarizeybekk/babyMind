//
//  NewbornHealthView.swift
//
//  Yenidoğan sağlık takip görünümü (SDG 3.2 hedefleri için)
//

import SwiftUI

struct NewbornHealthView: View {
    let baby: Baby
    @StateObject private var healthService: NewbornHealthService
    @State private var showAddRecord = false
    @State private var selectedCategory: NewbornHealthRecord.HealthCategory = .temperature
    @Environment(\.colorScheme) var colorScheme
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    init(baby: Baby) {
        self.baby = baby
        _healthService = StateObject(wrappedValue: NewbornHealthService(babyId: baby.id, birthDate: baby.birthDate))
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
                        Text("Yenidoğan Sağlık Takibi")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Spacer()
                        
                        Button(action: {
                            showAddRecord = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(theme.primary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // SDG 3.2 İlerleme
                    SDG32ProgressCard(healthService: healthService, theme: theme)
                        .padding(.horizontal, 20)
                    
                    // Erken Uyarılar
                    if !healthService.earlyWarnings.isEmpty {
                        EarlyWarningsCard(warnings: healthService.earlyWarnings, theme: theme)
                            .padding(.horizontal, 20)
                    }
                    
                    // Sağlık Taramaları
                    HealthScreeningsCard(healthService: healthService, theme: theme)
                        .padding(.horizontal, 20)
                    
                    // Günlük Takip
                    DailyTrackingCard(healthService: healthService, theme: theme)
                        .padding(.horizontal, 20)
                    
                    // Son Kayıtlar
                    if !healthService.healthRecords.isEmpty {
                        NewbornRecentRecordsView(healthService: healthService, theme: theme)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Yenidoğan Sağlık")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddRecord) {
            AddNewbornHealthRecordView(healthService: healthService, baby: baby, theme: theme)
        }
        .onAppear {
            healthService.checkEarlyWarnings()
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

// MARK: - SDG 3.2 İlerleme Kartı
struct SDG32ProgressCard: View {
    @ObservedObject var healthService: NewbornHealthService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var progress: SDG32Progress {
        healthService.getSDG32Progress()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "target")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                
                Text("SDG 3.2 İlerleme")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            Text("5 yaş altında önlenebilir ölümlerin sona erdirilmesi")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bebek Yaşı")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("\(progress.ageInDays) gün")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(theme.primary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sağlık Taramaları")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("\(progress.completedScreenings)/\(progress.totalScreenings)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(theme.primary)
                }
                
                Spacer()
                
                if progress.isOnTrack {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                        
                        Text("İyi Gidiyor")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.3))
                        
                        Text("Dikkat")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.3))
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

// MARK: - Erken Uyarılar Kartı
struct EarlyWarningsCard: View {
    let warnings: [EarlyWarning]
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                
                Text("Erken Uyarılar")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                
                Spacer()
            }
            
            ForEach(Array(warnings.enumerated()), id: \.offset) { _, warning in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: warning.severity == .critical ? "exclamationmark.octagon.fill" : "exclamationmark.triangle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(warning.severity == .critical ? Color(red: 1.0, green: 0.3, blue: 0.3) : Color(red: 1.0, green: 0.7, blue: 0.3))
                        
                        Text(warning.severity == .critical ? "Acil" : "Dikkat")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(warning.severity == .critical ? Color(red: 1.0, green: 0.3, blue: 0.3) : Color(red: 1.0, green: 0.7, blue: 0.3))
                    }
                    
                    Text(warning.message)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    Text("Öneri: \(warning.recommendation)")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(warning.severity == .critical ? Color(red: 1.0, green: 0.95, blue: 0.95) : Color(red: 1.0, green: 0.98, blue: 0.95))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(warning.severity == .critical ? Color(red: 1.0, green: 0.4, blue: 0.4).opacity(0.3) : Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 1.0, green: 0.98, blue: 0.98))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 1.0, green: 0.4, blue: 0.4).opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Sağlık Taramaları Kartı
struct HealthScreeningsCard: View {
    @ObservedObject var healthService: NewbornHealthService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var upcomingScreenings: [HealthScreening] {
        healthService.getUpcomingScreenings()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "stethoscope")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("Sağlık Taramaları")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            if !upcomingScreenings.isEmpty {
                Text("Yaklaşan Taramalar")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                
                ForEach(upcomingScreenings.prefix(3)) { screening in
                    ScreeningRow(screening: screening, theme: theme)
                }
            }
            
            Divider()
                .padding(.vertical, 8)
            
            Text("Tüm Taramalar")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            
            ForEach(healthService.screenings) { screening in
                ScreeningRow(screening: screening, theme: theme)
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

struct ScreeningRow: View {
    let screening: HealthScreening
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(theme.primary.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: screening.screeningType.icon)
                    .font(.system(size: 22))
                    .foregroundColor(theme.primary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(screening.screeningType.rawValue)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Text(screening.description)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text("Önerilen: \(screening.recommendedDate, style: .date)")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if screening.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
            } else {
                Image(systemName: "circle")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(red: 0.25, green: 0.25, blue: 0.3) : Color(red: 0.98, green: 0.98, blue: 0.99))
        )
    }
}

// MARK: - Günlük Takip Kartı
struct DailyTrackingCard: View {
    @ObservedObject var healthService: NewbornHealthService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("Günlük Takip")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            Text("Yenidoğan bebeklerin ilk 28 günü kritik dönemdir. Aşağıdaki değerleri düzenli takip edin:")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(NewbornHealthRecord.HealthCategory.allCases.prefix(6), id: \.self) { category in
                    TrackingCategoryCard(category: category, healthService: healthService, theme: theme)
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

struct TrackingCategoryCard: View {
    let category: NewbornHealthRecord.HealthCategory
    @ObservedObject var healthService: NewbornHealthService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var latestRecord: NewbornHealthRecord? {
        healthService.getLatestRecord(for: category)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.system(size: 24))
                .foregroundColor(theme.primary)
            
            Text(category.rawValue)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let record = latestRecord {
                if let value = record.value {
                    Text(String(format: "%.1f", value))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(
                            red: record.status.color.red,
                            green: record.status.color.green,
                            blue: record.status.color.blue
                        ))
                }
                
                Circle()
                    .fill(Color(
                        red: record.status.color.red,
                        green: record.status.color.green,
                        blue: record.status.color.blue
                    ))
                    .frame(width: 8, height: 8)
            } else {
                Text("Kayıt Yok")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(red: 0.25, green: 0.25, blue: 0.3) : Color(red: 0.98, green: 0.98, blue: 0.99))
        )
    }
}

// MARK: - Son Kayıtlar
struct NewbornRecentRecordsView: View {
    @ObservedObject var healthService: NewbornHealthService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Son Kayıtlar")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            
            ForEach(healthService.healthRecords.prefix(5)) { record in
                HealthRecordRow(record: record, theme: theme)
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

struct HealthRecordRow: View {
    let record: NewbornHealthRecord
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(
                        red: record.status.color.red,
                        green: record.status.color.green,
                        blue: record.status.color.blue
                    ).opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: record.category.icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color(
                        red: record.status.color.red,
                        green: record.status.color.green,
                        blue: record.status.color.blue
                    ))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(record.category.rawValue)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                HStack(spacing: 8) {
                    if let value = record.value {
                        Text(String(format: "%.1f", value))
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(record.date, style: .date)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(record.status.rawValue)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(
                            red: record.status.color.red,
                            green: record.status.color.green,
                            blue: record.status.color.blue
                        ))
                )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(red: 0.25, green: 0.25, blue: 0.3) : Color(red: 0.98, green: 0.98, blue: 0.99))
        )
    }
}

// MARK: - Kayıt Ekleme
struct AddNewbornHealthRecordView: View {
    @ObservedObject var healthService: NewbornHealthService
    let baby: Baby
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    @State private var category: NewbornHealthRecord.HealthCategory = .temperature
    @State private var value: String = ""
    @State private var status: NewbornHealthRecord.HealthStatus = .normal
    @State private var notes: String = ""
    @State private var date = Date()
    
    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: baby.birthDate, to: date).day ?? 0
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kategori")) {
                    Picker("Kategori", selection: $category) {
                        ForEach(NewbornHealthRecord.HealthCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                }
                
                Section(header: Text("Tarih ve Değer")) {
                    DatePicker("Tarih", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    if category.normalRange != nil {
                        TextField("Değer", text: $value)
                            .keyboardType(.decimalPad)
                        
                        if let range = category.normalRange {
                            Text("Normal aralık: \(String(format: "%.1f", range.min)) - \(String(format: "%.1f", range.max))")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Durum")) {
                    Picker("Durum", selection: $status) {
                        Text("Normal").tag(NewbornHealthRecord.HealthStatus.normal)
                        Text("Dikkat").tag(NewbornHealthRecord.HealthStatus.warning)
                        Text("Acil").tag(NewbornHealthRecord.HealthStatus.critical)
                    }
                }
                
                Section(header: Text("Notlar (Opsiyonel)")) {
                    TextField("Notlar", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Yeni Kayıt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let valueDouble = Double(value)
                        let record = NewbornHealthRecord(
                            babyId: baby.id,
                            date: date,
                            ageInDays: ageInDays,
                            category: category,
                            value: valueDouble,
                            status: status,
                            notes: notes.isEmpty ? nil : notes
                        )
                        healthService.addHealthRecord(record)
                        HapticManager.shared.notification(type: .success)
                        dismiss()
                    }
                }
            }
        }
    }
}
