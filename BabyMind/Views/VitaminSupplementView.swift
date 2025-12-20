//
//  VitaminSupplementView.swift
//
//  Vitamin ve takviye yönetim görünümü
//

import SwiftUI

struct VitaminSupplementView: View {
    let baby: Baby
    @StateObject private var supplementService: VitaminSupplementService
    @State private var showAddSupplement = false
    @State private var selectedSupplement: VitaminSupplement? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    init(baby: Baby) {
        self.baby = baby
        _supplementService = StateObject(wrappedValue: VitaminSupplementService(babyId: baby.id))
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
                        Text("Vitamin ve Takviye")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Spacer()
                        
                        Button(action: {
                            showAddSupplement = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(theme.primary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Eksiklik Uyarıları
                    let deficiencies = supplementService.checkDeficiencies(ageInMonths: baby.ageInMonths)
                    if !deficiencies.isEmpty {
                        DeficiencyAlertsCard(deficiencies: deficiencies, theme: theme)
                            .padding(.horizontal, 20)
                    }
                    
                    // Aktif Takviyeler
                    if !supplementService.getActiveSupplements().isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Aktif Takviyeler")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                                .padding(.horizontal, 20)
                            
                            ForEach(supplementService.getActiveSupplements()) { supplement in
                                SupplementCard(
                                    supplement: supplement,
                                    theme: theme,
                                    onTap: {
                                        selectedSupplement = supplement
                                    }
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    // Besin Kaynakları Rehberi
                    FoodSourcesGuideView(theme: theme)
                        .padding(.horizontal, 20)
                }
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Vitamin & Takviye")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddSupplement) {
            AddVitaminSupplementView(supplementService: supplementService, baby: baby, theme: theme)
        }
        .sheet(item: $selectedSupplement) { supplement in
            SupplementDetailView(supplement: supplement, supplementService: supplementService, theme: theme)
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

// MARK: - Eksiklik Uyarıları Kartı
struct DeficiencyAlertsCard: View {
    let deficiencies: [DeficiencyAlert]
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.3))
                
                Text("Eksiklik Uyarıları")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.3))
                
                Spacer()
            }
            
            ForEach(Array(deficiencies.enumerated()), id: \.offset) { _, alert in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: alert.type.icon)
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.3))
                    
                    Text(alert.message)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 1.0, green: 0.98, blue: 0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Takviye Kartı
struct SupplementCard: View {
    let supplement: VitaminSupplement
    let theme: ColorTheme
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.9, green: 0.6, blue: 0.3).opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: supplement.type.icon)
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 0.9, green: 0.6, blue: 0.3))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(supplement.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    HStack(spacing: 8) {
                        Text(supplement.dosage)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(supplement.frequency.rawValue)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if supplement.isActive {
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
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Besin Kaynakları Rehberi
struct FoodSourcesGuideView: View {
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedType: VitaminSupplement.SupplementType = .vitaminD
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "book.fill")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("Besin Kaynakları Rehberi")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            Picker("Vitamin/Takviye", selection: $selectedType) {
                ForEach(VitaminSupplement.SupplementType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.menu)
            
            let sources = getFoodSources(for: selectedType)
            ForEach(sources, id: \.self) { source in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(theme.primary)
                    
                    Text(source)
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
    
    private func getFoodSources(for type: VitaminSupplement.SupplementType) -> [String] {
        let service = VitaminSupplementService(babyId: UUID())
        return service.getFoodSources(for: type)
    }
}

// MARK: - Takviye Ekleme Görünümü
struct AddVitaminSupplementView: View {
    @ObservedObject var supplementService: VitaminSupplementService
    let baby: Baby
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var type: VitaminSupplement.SupplementType = .vitaminD
    @State private var dosage: String = ""
    @State private var frequency: VitaminSupplement.Frequency = .daily
    @State private var startDate = Date()
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Takviye Bilgileri")) {
                    Picker("Tip", selection: $type) {
                        ForEach(VitaminSupplement.SupplementType.allCases, id: \.self) { supplementType in
                            Text(supplementType.rawValue).tag(supplementType)
                        }
                    }
                    
                    TextField("İsim", text: $name)
                    
                    TextField("Dozaj (örn: 400 IU)", text: $dosage)
                    
                    Picker("Sıklık", selection: $frequency) {
                        ForEach(VitaminSupplement.Frequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                }
                
                Section(header: Text("Tarih")) {
                    DatePicker("Başlangıç Tarihi", selection: $startDate, displayedComponents: .date)
                }
                
                Section(header: Text("Notlar (Opsiyonel)")) {
                    TextField("Notlar", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Yeni Takviye")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let supplement = VitaminSupplement(
                            babyId: baby.id,
                            name: name.isEmpty ? type.rawValue : name,
                            type: type,
                            dosage: dosage,
                            frequency: frequency,
                            startDate: startDate,
                            notes: notes.isEmpty ? nil : notes
                        )
                        supplementService.addSupplement(supplement)
                        HapticManager.shared.notification(type: .success)
                        dismiss()
                    }
                    .disabled(dosage.isEmpty)
                }
            }
        }
    }
}

struct SupplementDetailView: View {
    let supplement: VitaminSupplement
    @ObservedObject var supplementService: VitaminSupplementService
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Başlık
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.9, green: 0.6, blue: 0.3).opacity(0.15))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: supplement.type.icon)
                                    .font(.system(size: 30))
                                    .foregroundColor(Color(red: 0.9, green: 0.6, blue: 0.3))
                            }
                            
                            Spacer()
                        }
                        
                        Text(supplement.name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
                    )
                    
                    // Bilgiler
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Bilgiler")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        InfoRow(title: "Dozaj", value: supplement.dosage)
                        InfoRow(title: "Sıklık", value: supplement.frequency.rawValue)
                        InfoRow(title: "Başlangıç", value: formatDate(supplement.startDate))
                        
                        if let notes = supplement.notes, !notes.isEmpty {
                            InfoRow(title: "Notlar", value: notes)
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
            .navigationTitle("Takviye Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}
