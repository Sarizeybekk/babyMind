//
//  DevelopmentalMilestonesView.swift
//
//  Gelişimsel kilometre taşları görünümü
//

import SwiftUI

struct DevelopmentalMilestonesView: View {
    let baby: Baby
    @StateObject private var milestoneService: DevelopmentalMilestoneService
    @State private var selectedCategory: DevelopmentalMilestone.Category? = nil
    @State private var showAddMilestone = false
    @State private var selectedMilestone: DevelopmentalMilestone? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    init(baby: Baby) {
        self.baby = baby
        _milestoneService = StateObject(wrappedValue: DevelopmentalMilestoneService(babyId: baby.id))
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
                        Text("Gelişimsel Kilometre Taşları")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // İlerleme Özeti
                    ProgressSummaryCard(milestoneService: milestoneService, theme: theme)
                        .padding(.horizontal, 20)
                    
                    // Gecikme Uyarıları
                    let delayedMilestones = milestoneService.getDelayedMilestones(ageInMonths: baby.ageInMonths)
                    if !delayedMilestones.isEmpty {
                        DelayWarningCard(milestones: delayedMilestones, theme: theme)
                            .padding(.horizontal, 20)
                    }
                    
                    // Kategori Filtreleri
                    CategoryFilterView(selectedCategory: $selectedCategory)
                        .padding(.horizontal, 20)
                    
                    // Kilometre Taşları Listesi
                    MilestonesListView(
                        milestoneService: milestoneService,
                        baby: baby,
                        selectedCategory: selectedCategory,
                        onMilestoneTap: { milestone in
                            selectedMilestone = milestone
                        }
                    )
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Gelişim")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedMilestone) { milestone in
            MilestoneDetailView(milestone: milestone, milestoneService: milestoneService, theme: theme)
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

// MARK: - İlerleme Özeti Kartı
struct ProgressSummaryCard: View {
    @ObservedObject var milestoneService: DevelopmentalMilestoneService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var progress = [DevelopmentalMilestone.Category: (achieved: Int, total: Int)]()
    
    init(milestoneService: DevelopmentalMilestoneService, theme: ColorTheme) {
        self.milestoneService = milestoneService
        self.theme = theme
        self.progress = milestoneService.getProgressByCategory()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("İlerleme Özeti")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(DevelopmentalMilestone.Category.allCases, id: \.self) { category in
                    if let (achieved, total) = progress[category] {
                        CategoryProgressCard(category: category, achieved: achieved, total: total)
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

struct CategoryProgressCard: View {
    let category: DevelopmentalMilestone.Category
    let achieved: Int
    let total: Int
    @Environment(\.colorScheme) var colorScheme
    
    var percentage: Double {
        total > 0 ? Double(achieved) / Double(total) : 0
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.system(size: 24))
                .foregroundColor(Color(
                    red: category.color.red,
                    green: category.color.green,
                    blue: category.color.blue
                ))
            
            Text("\(achieved)/\(total)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            
            Text(category.rawValue)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(
                            red: category.color.red,
                            green: category.color.green,
                            blue: category.color.blue
                        ))
                        .frame(width: geometry.size.width * percentage, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(red: 0.25, green: 0.25, blue: 0.3) : Color(red: 0.98, green: 0.98, blue: 0.99))
        )
    }
}

// MARK: - Gecikme Uyarı Kartı
struct DelayWarningCard: View {
    let milestones: [DevelopmentalMilestone]
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                
                Text("Gecikme Uyarıları")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                
                Spacer()
            }
            
            Text("\(milestones.count) kilometre taşı beklenen süreyi aştı. Doktorunuzla görüşmeniz önerilir.")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.secondary)
            
            ForEach(milestones.prefix(3)) { milestone in
                HStack {
                    Text("• \(milestone.milestone)")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    Spacer()
                    
                    Text("Beklenen: \(milestone.expectedAgeRange.description)")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 1.0, green: 0.95, blue: 0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 1.0, green: 0.4, blue: 0.4).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Kategori Filtreleri
struct CategoryFilterView: View {
    @Binding var selectedCategory: DevelopmentalMilestone.Category?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                MilestoneCategoryFilterButton(
                    title: "Tümü",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                
                ForEach(DevelopmentalMilestone.Category.allCases, id: \.self) { category in
                    MilestoneCategoryFilterButton(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct MilestoneCategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : (colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25)))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(red: 0.3, green: 0.7, blue: 0.9) : (colorScheme == .dark ? Color(red: 0.25, green: 0.25, blue: 0.3) : Color(red: 0.95, green: 0.95, blue: 0.97)))
                )
        }
    }
}

// MARK: - Kilometre Taşları Listesi
struct MilestonesListView: View {
    @ObservedObject var milestoneService: DevelopmentalMilestoneService
    let baby: Baby
    let selectedCategory: DevelopmentalMilestone.Category?
    let onMilestoneTap: (DevelopmentalMilestone) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var filteredMilestones: [DevelopmentalMilestone] {
        let milestones = milestoneService.milestones
        if let category = selectedCategory {
            return milestones.filter { $0.category == category }
        }
        return milestones
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(selectedCategory?.rawValue ?? "Tüm Kilometre Taşları")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            
            ForEach(filteredMilestones) { milestone in
                MilestoneCard(
                    milestone: milestone,
                    ageInMonths: baby.ageInMonths,
                    onTap: {
                        onMilestoneTap(milestone)
                    }
                )
            }
        }
    }
}

struct MilestoneCard: View {
    let milestone: DevelopmentalMilestone
    let ageInMonths: Int
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var status: MilestoneStatus {
        if let _ = milestone.achievedDate {
            return .achieved
        }
        if ageInMonths > milestone.expectedAgeRange.maxMonths {
            return .delayed
        } else if ageInMonths >= milestone.expectedAgeRange.minMonths {
            return .expected
        } else {
            return .upcoming
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // İkon
                ZStack {
                    Circle()
                        .fill(Color(
                            red: milestone.category.color.red,
                            green: milestone.category.color.green,
                            blue: milestone.category.color.blue
                        ).opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: milestone.category.icon)
                        .font(.system(size: 22))
                        .foregroundColor(Color(
                            red: milestone.category.color.red,
                            green: milestone.category.color.green,
                            blue: milestone.category.color.blue
                        ))
                }
                
                // Bilgiler
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(milestone.milestone)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Spacer()
                        
                        // Durum badge
                        Text(status.text)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(
                                        red: status.color.red,
                                        green: status.color.green,
                                        blue: status.color.blue
                                    ))
                            )
                    }
                    
                    HStack(spacing: 8) {
                        Text(milestone.category.rawValue)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("Beklenen: \(milestone.expectedAgeRange.description)")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    if let achievedDate = milestone.achievedDate {
                        Text("Tamamlandı: \(formatDate(achievedDate))")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
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
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Kilometre Taşı Detay Görünümü
struct MilestoneDetailView: View {
    let milestone: DevelopmentalMilestone
    @ObservedObject var milestoneService: DevelopmentalMilestoneService
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showMarkAchieved = false
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Başlık
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color(
                                        red: milestone.category.color.red,
                                        green: milestone.category.color.green,
                                        blue: milestone.category.color.blue
                                    ).opacity(0.15))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: milestone.category.icon)
                                    .font(.system(size: 30))
                                    .foregroundColor(Color(
                                        red: milestone.category.color.red,
                                        green: milestone.category.color.green,
                                        blue: milestone.category.color.blue
                                    ))
                            }
                            
                            Spacer()
                        }
                        
                        Text(milestone.milestone)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Text(milestone.category.rawValue)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.secondary)
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
                        
                        InfoRow(title: "Beklenen Yaş Aralığı", value: milestone.expectedAgeRange.description)
                        
                        if let achievedDate = milestone.achievedDate {
                            InfoRow(title: "Tamamlanma Tarihi", value: formatDate(achievedDate))
                        }
                        
                        if let notes = milestone.notes, !notes.isEmpty {
                            InfoRow(title: "Notlar", value: notes)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
                    )
                    
                    // Tamamla Butonu
                    if milestone.achievedDate == nil {
                        Button(action: {
                            showMarkAchieved = true
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                Text("Kilometre Taşını Tamamla")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [theme.primary, theme.primary.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Kilometre Taşı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showMarkAchieved) {
                MarkMilestoneAchievedView(
                    milestone: milestone,
                    milestoneService: milestoneService,
                    notes: $notes,
                    onDismiss: {
                        showMarkAchieved = false
                        dismiss()
                    }
                )
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
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

struct MarkMilestoneAchievedView: View {
    let milestone: DevelopmentalMilestone
    @ObservedObject var milestoneService: DevelopmentalMilestoneService
    @Binding var notes: String
    let onDismiss: () -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tamamlanma Tarihi")) {
                    DatePicker("Tarih", selection: $selectedDate, displayedComponents: .date)
                }
                
                Section(header: Text("Notlar (Opsiyonel)")) {
                    TextField("Notlar", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Kilometre Taşını Tamamla")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        milestoneService.markMilestoneAchieved(milestone, date: selectedDate, notes: notes.isEmpty ? nil : notes)
                        HapticManager.shared.notification(type: .success)
                        onDismiss()
                    }
                }
            }
        }
    }
}


