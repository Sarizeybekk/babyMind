//
//  AllergyTrackerView.swift
//  BabyMind
//
//  Alerji takip görünümü
//

import SwiftUI

struct AllergyTrackerView: View {
    let baby: Baby
    @StateObject private var allergyService: AllergyService
    @State private var showAddAllergy = false
    @State private var selectedAllergy: Allergy?
    @State private var selectedCategory: Allergy.AllergyCategory? = nil
    
    init(baby: Baby) {
        self.baby = baby
        _allergyService = StateObject(wrappedValue: AllergyService(babyId: baby.id))
    }
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: theme.backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if allergyService.allergies.isEmpty {
                EmptyAllergiesView(theme: theme, onAdd: {
                    showAddAllergy = true
                })
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Kategori Filtreleri
                        categoryFilters
                        
                        // Alerji Listesi
                        allergiesList
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Alerji Takibi")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddAllergy = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(theme.primary)
                }
            }
        }
        .sheet(isPresented: $showAddAllergy) {
            AddAllergyView(baby: baby, allergyService: allergyService, theme: theme)
        }
        .sheet(item: $selectedAllergy) { allergy in
            AllergyDetailView(allergy: allergy, allergyService: allergyService, theme: theme)
        }
    }
    
    @ViewBuilder
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryFilterButton(
                    title: "Tümü",
                    isSelected: selectedCategory == nil,
                    theme: theme
                ) {
                    selectedCategory = nil
                }
                
                ForEach(Allergy.AllergyCategory.allCases, id: \.self) { category in
                    CategoryFilterButton(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        theme: theme
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var allergiesList: some View {
        let filteredAllergies = selectedCategory == nil
            ? allergyService.allergies
            : allergyService.getAllergiesByCategory(selectedCategory!)
        
        VStack(spacing: 16) {
            ForEach(filteredAllergies) { allergy in
                AllergyCard(allergy: allergy, theme: theme) {
                    selectedAllergy = allergy
                }
            }
        }
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let theme: ColorTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : theme.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? theme.primary : Color.white)
                )
        }
    }
}

struct AllergyCard: View {
    let allergy: Allergy
    let theme: ColorTheme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Şiddet İkonu
                ZStack {
                    Circle()
                        .fill(severityColor.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: severityIcon)
                        .font(.system(size: 28))
                        .foregroundColor(severityColor)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(allergy.allergen)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(theme.text)
                        
                        Spacer()
                        
                        Text(allergy.severity.rawValue)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(severityColor)
                            )
                    }
                    
                    Text(allergy.category.rawValue)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(theme.text.opacity(0.7))
                    
                    if !allergy.symptoms.isEmpty {
                        Text(allergy.symptoms.prefix(2).joined(separator: ", "))
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(theme.text.opacity(0.6))
                            .lineLimit(1)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(theme.text.opacity(0.3))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: theme.cardShadow, radius: 10, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var severityColor: Color {
        switch allergy.severity {
        case .mild: return .yellow
        case .moderate: return .orange
        case .severe: return .red
        case .lifeThreatening: return .purple
        }
    }
    
    private var severityIcon: String {
        switch allergy.severity {
        case .mild: return "exclamationmark.circle.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .severe: return "exclamationmark.octagon.fill"
        case .lifeThreatening: return "cross.case.fill"
        }
    }
}

struct EmptyAllergiesView: View {
    let theme: ColorTheme
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(theme.primary.opacity(0.5))
            
            Text("Henüz alerji kaydı yok")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)
            
            Text("Bebeğinizin bilinen alerjilerini ekleyin")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(theme.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onAdd) {
                Text("Alerji Ekle")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [theme.primary, theme.primaryDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Add Allergy View
struct AddAllergyView: View {
    let baby: Baby
    @ObservedObject var allergyService: AllergyService
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    
    @State private var allergen: String = ""
    @State private var selectedCategory: Allergy.AllergyCategory = .food
    @State private var selectedSeverity: Allergy.Severity = .mild
    @State private var symptoms: [String] = []
    @State private var newSymptom: String = ""
    @State private var notes: String = ""
    @State private var testResult: String = ""
    @State private var testDate: Date = Date()
    @State private var hasTestResult: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Alerjen Bilgisi") {
                    TextField("Alerjen (örn: Fıstık, Süt)", text: $allergen)
                    
                    Picker("Kategori", selection: $selectedCategory) {
                        ForEach(Allergy.AllergyCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    Picker("Şiddet", selection: $selectedSeverity) {
                        ForEach(Allergy.Severity.allCases, id: \.self) { severity in
                            Text(severity.rawValue).tag(severity)
                        }
                    }
                }
                
                Section("Semptomlar") {
                    ForEach(symptoms, id: \.self) { symptom in
                        HStack {
                            Text(symptom)
                            Spacer()
                            Button(action: {
                                symptoms.removeAll { $0 == symptom }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    HStack {
                        TextField("Semptom ekle", text: $newSymptom)
                        Button("Ekle") {
                            if !newSymptom.isEmpty {
                                symptoms.append(newSymptom)
                                newSymptom = ""
                            }
                        }
                        .disabled(newSymptom.isEmpty)
                    }
                }
                
                Section("Notlar") {
                    TextField("Notlar (opsiyonel)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Test Sonucu") {
                    Toggle("Test sonucu var", isOn: $hasTestResult)
                    
                    if hasTestResult {
                        TextField("Test sonucu", text: $testResult)
                        DatePicker("Test tarihi", selection: $testDate, displayedComponents: [.date])
                    }
                }
            }
            .navigationTitle("Alerji Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveAllergy()
                    }
                    .disabled(allergen.isEmpty)
                }
            }
        }
    }
    
    private func saveAllergy() {
        let allergy = Allergy(
            babyId: baby.id,
            allergen: allergen,
            category: selectedCategory,
            severity: selectedSeverity,
            symptoms: symptoms,
            notes: notes.isEmpty ? nil : notes,
            testResult: hasTestResult && !testResult.isEmpty ? testResult : nil,
            testDate: hasTestResult ? testDate : nil
        )
        
        allergyService.addAllergy(allergy)
        HapticManager.shared.notification(type: .success)
        dismiss()
    }
}

// MARK: - Allergy Detail View
struct AllergyDetailView: View {
    let allergy: Allergy
    @ObservedObject var allergyService: AllergyService
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false
    @State private var showAddReaction = false
    
    var reactions: [AllergyReaction] {
        allergyService.getReactions(for: allergy)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Alerji Bilgileri
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(allergy.allergen)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(theme.text)
                            
                            Spacer()
                            
                            Text(allergy.severity.rawValue)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(severityColor)
                                )
                        }
                        
                        DetailRow(title: "Kategori", value: allergy.category.rawValue, theme: theme)
                        DetailRow(title: "İlk Tespit", value: allergy.firstObserved, dateStyle: .date, theme: theme)
                        
                        if !allergy.symptoms.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Semptomlar")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.text)
                                
                                ForEach(allergy.symptoms, id: \.self) { symptom in
                                    HStack {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 6))
                                        Text(symptom)
                                            .font(.system(size: 15, design: .rounded))
                                            .foregroundColor(theme.text)
                                    }
                                }
                            }
                        }
                        
                        if let notes = allergy.notes {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notlar")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.text)
                                Text(notes)
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(theme.text.opacity(0.8))
                            }
                        }
                        
                        if let testResult = allergy.testResult {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Test Sonucu")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.text)
                                Text(testResult)
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(theme.text.opacity(0.8))
                                
                                if let testDate = allergy.testDate {
                                    Text("Tarih: \(testDate, style: .date)")
                                        .font(.system(size: 13, design: .rounded))
                                        .foregroundColor(theme.text.opacity(0.6))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: theme.cardShadow, radius: 10, x: 0, y: 3)
                    )
                    
                    // Reaksiyonlar
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Reaksiyonlar")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(theme.text)
                            
                            Spacer()
                            
                            Button(action: {
                                showAddReaction = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(theme.primary)
                            }
                        }
                        
                        if reactions.isEmpty {
                            Text("Henüz reaksiyon kaydı yok")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(theme.text.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(reactions) { reaction in
                                ReactionRow(reaction: reaction, theme: theme)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: theme.cardShadow, radius: 10, x: 0, y: 3)
                    )
                }
                .padding()
            }
            .navigationTitle("Alerji Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive, action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
            .alert("Alerjiyi Sil", isPresented: $showDeleteAlert) {
                Button("İptal", role: .cancel) { }
                Button("Sil", role: .destructive) {
                    allergyService.deleteAllergy(allergy)
                    dismiss()
                }
            } message: {
                Text("Bu alerjiyi silmek istediğinizden emin misiniz?")
            }
            .sheet(isPresented: $showAddReaction) {
                AddReactionView(allergy: allergy, allergyService: allergyService, theme: theme)
            }
        }
    }
    
    private var severityColor: Color {
        switch allergy.severity {
        case .mild: return .yellow
        case .moderate: return .orange
        case .severe: return .red
        case .lifeThreatening: return .purple
        }
    }
}

struct ReactionRow: View {
    let reaction: AllergyReaction
    let theme: ColorTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(reaction.date, style: .date)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.text)
                
                Spacer()
                
                Text(reaction.severity.rawValue)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(severityColor)
                    )
            }
            
            if !reaction.symptoms.isEmpty {
                Text(reaction.symptoms.joined(separator: ", "))
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(theme.text.opacity(0.7))
            }
            
            if let notes = reaction.notes {
                Text(notes)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(theme.text.opacity(0.6))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
    
    private var severityColor: Color {
        switch reaction.severity {
        case .mild: return .yellow
        case .moderate: return .orange
        case .severe: return .red
        case .lifeThreatening: return .purple
        }
    }
}

struct AddReactionView: View {
    let allergy: Allergy
    @ObservedObject var allergyService: AllergyService
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedSeverity: Allergy.Severity = .mild
    @State private var symptoms: [String] = []
    @State private var newSymptom: String = ""
    @State private var notes: String = ""
    @State private var medicationGiven: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Reaksiyon Bilgisi") {
                    Picker("Şiddet", selection: $selectedSeverity) {
                        ForEach(Allergy.Severity.allCases, id: \.self) { severity in
                            Text(severity.rawValue).tag(severity)
                        }
                    }
                    
                    DatePicker("Tarih", selection: .constant(Date()), displayedComponents: [.date, .hourAndMinute])
                        .disabled(true)
                }
                
                Section("Semptomlar") {
                    ForEach(symptoms, id: \.self) { symptom in
                        HStack {
                            Text(symptom)
                            Spacer()
                            Button(action: {
                                symptoms.removeAll { $0 == symptom }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    HStack {
                        TextField("Semptom ekle", text: $newSymptom)
                        Button("Ekle") {
                            if !newSymptom.isEmpty {
                                symptoms.append(newSymptom)
                                newSymptom = ""
                            }
                        }
                        .disabled(newSymptom.isEmpty)
                    }
                }
                
                Section("Notlar") {
                    TextField("Notlar (opsiyonel)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("İlaç") {
                    TextField("Verilen ilaç (opsiyonel)", text: $medicationGiven)
                }
            }
            .navigationTitle("Reaksiyon Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveReaction()
                    }
                }
            }
        }
    }
    
    private func saveReaction() {
        let reaction = AllergyReaction(
            allergyId: allergy.id,
            severity: selectedSeverity,
            symptoms: symptoms,
            notes: notes.isEmpty ? nil : notes,
            medicationGiven: medicationGiven.isEmpty ? nil : medicationGiven
        )
        
        allergyService.addReaction(reaction)
        HapticManager.shared.notification(type: .success)
        dismiss()
    }
}

