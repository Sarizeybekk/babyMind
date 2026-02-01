//
//  ImmunityTrackerView.swift
//
//  Bağışıklık sistemi takip görünümü
//

import SwiftUI

struct ImmunityTrackerView: View {
    let baby: Baby
    @StateObject private var immunityService: ImmunityService
    @State private var showAddRecord = false
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    init(baby: Baby) {
        self.baby = baby
        _immunityService = StateObject(wrappedValue: ImmunityService(babyId: baby.id))
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
                        Text("Bağışıklık Sistemi")
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
                    
                    // Tab Seçici
                    Picker("", selection: $selectedTab) {
                        Text("Aşı Takvimi").tag(0)
                        Text("Hastalık Geçmişi").tag(1)
                        Text("Öneriler").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    
                    if selectedTab == 0 {
                        VaccinationScheduleView(immunityService: immunityService, baby: baby, theme: theme)
                            .padding(.horizontal, 20)
                    } else if selectedTab == 1 {
                        IllnessHistoryView(immunityService: immunityService, theme: theme)
                            .padding(.horizontal, 20)
                    } else {
                        RecommendationsView(immunityService: immunityService, theme: theme)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Bağışıklık")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddRecord) {
            AddImmunityRecordView(immunityService: immunityService, baby: baby, theme: theme)
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

// MARK: - Aşı Takvimi Görünümü
struct VaccinationScheduleView: View {
    @ObservedObject var immunityService: ImmunityService
    let baby: Baby
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var upcomingVaccinations: [VaccinationSchedule] {
        immunityService.getUpcomingVaccinations(ageInMonths: baby.ageInMonths)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !upcomingVaccinations.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.3))
                        
                        Text("Yaklaşan Aşılar")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                    }
                    
                    ForEach(upcomingVaccinations.prefix(3), id: \.name) { vaccination in
                        ImmunityVaccinationCard(vaccination: vaccination, theme: theme)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Aşı Takvimi")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                ForEach(immunityService.vaccinationSchedule, id: \.name) { vaccination in
                    ImmunityVaccinationCard(vaccination: vaccination, theme: theme)
                }
            }
        }
    }
}

struct ImmunityVaccinationCard: View {
    let vaccination: VaccinationSchedule
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.2, green: 0.7, blue: 0.9).opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "syringe.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.9))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(vaccination.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    Spacer()
                    
                    if vaccination.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                    }
                }
                
                Text(vaccination.recommendedAge)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
                
                if !vaccination.doses.isEmpty {
                    Text(vaccination.doses.joined(separator: ", "))
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }
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

// MARK: - Hastalık Geçmişi
struct IllnessHistoryView: View {
    @ObservedObject var immunityService: ImmunityService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hastalık Geçmişi")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            
            let illnesses = immunityService.getIllnessHistory()
            
            if illnesses.isEmpty {
                Text("Henüz hastalık kaydı yok")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
            } else {
                ForEach(illnesses) { record in
                    ImmunityRecordCard(record: record, theme: theme)
                }
            }
        }
    }
}

struct ImmunityRecordCard: View {
    let record: ImmunityRecord
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(
                        red: record.type.color.red,
                        green: record.type.color.green,
                        blue: record.type.color.blue
                    ).opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: record.type.icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color(
                        red: record.type.color.red,
                        green: record.type.color.green,
                        blue: record.type.color.blue
                    ))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(record.details)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                HStack(spacing: 8) {
                    Text(record.date, style: .date)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    if let severity = record.severity {
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(severity.rawValue)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Öneriler Görünümü
struct RecommendationsView: View {
    @ObservedObject var immunityService: ImmunityService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Mevsimsel Uyarılar
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                        .foregroundColor(theme.primary)
                    
                    Text("Mevsimsel Uyarılar")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                }
                
                ForEach(immunityService.getSeasonalRecommendations(), id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(theme.primary)
                        
                        Text(recommendation)
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
            
            // Bağışıklık Güçlendirme
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18))
                        .foregroundColor(theme.primary)
                    
                    Text("Bağışıklık Güçlendirme")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                }
                
                ForEach(immunityService.getImmunityStrengtheningTips(), id: \.self) { tip in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                        
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
}

// MARK: - Kayıt Ekleme Görünümü
struct AddImmunityRecordView: View {
    @ObservedObject var immunityService: ImmunityService
    let baby: Baby
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var recordType: ImmunityRecord.RecordType = .illness
    @State private var details: String = ""
    @State private var severity: ImmunityRecord.Severity? = nil
    @State private var notes: String = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kayıt Tipi")) {
                    Picker("Tip", selection: $recordType) {
                        ForEach(ImmunityRecord.RecordType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Tarih")) {
                    DatePicker("Tarih", selection: $date, displayedComponents: [.date])
                }
                
                Section(header: Text("Detaylar")) {
                    TextField("Detaylar", text: $details, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                if recordType == .illness {
                    Section(header: Text("Şiddet")) {
                        Picker("Şiddet", selection: $severity) {
                            Text("Seçiniz").tag(ImmunityRecord.Severity?.none)
                            ForEach([ImmunityRecord.Severity.mild, .moderate, .severe], id: \.self) { sev in
                                Text(sev.rawValue).tag(ImmunityRecord.Severity?.some(sev))
                            }
                        }
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
                        let record = ImmunityRecord(
                            babyId: baby.id,
                            date: date,
                            type: recordType,
                            details: details,
                            severity: severity,
                            notes: notes.isEmpty ? nil : notes
                        )
                        immunityService.addRecord(record)
                        HapticManager.shared.notification(type: .success)
                        dismiss()
                    }
                    .disabled(details.isEmpty)
                }
            }
        }
    }
}


