//
//  SafetyChecklistView.swift
//
//  Güvenlik kontrol listesi görünümü
//

import SwiftUI

struct SafetyChecklistView: View {
    let baby: Baby
    @StateObject private var checklistService: SafetyChecklistService
    @State private var selectedCategory: SafetyChecklist.Category? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    init(baby: Baby) {
        self.baby = baby
        _checklistService = StateObject(wrappedValue: SafetyChecklistService(babyId: baby.id))
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
                        Text("Güvenlik Kontrol Listesi")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Genel İlerleme
                    OverallProgressCard(checklistService: checklistService, theme: theme)
                        .padding(.horizontal, 20)
                    
                    // Kategori Filtreleri
                    SafetyCategoryFilterView(selectedCategory: $selectedCategory)
                        .padding(.horizontal, 20)
                    
                    // Kontrol Listesi
                    SafetyChecklistItemsView(
                        checklistService: checklistService,
                        selectedCategory: selectedCategory,
                        theme: theme
                    )
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Güvenlik")
        .navigationBarTitleDisplayMode(.large)
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

// MARK: - Genel İlerleme Kartı
struct OverallProgressCard: View {
    @ObservedObject var checklistService: SafetyChecklistService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var overallProgress: Double {
        checklistService.getOverallProgress()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("Genel İlerleme")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            HStack(spacing: 30) {
                ZStack {
                    Circle()
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 16)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: overallProgress / 100)
                        .stroke(theme.primary, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(overallProgress))%")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(theme.primary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    let progress = checklistService.getProgressByCategory()
                    ForEach(SafetyChecklist.Category.allCases, id: \.self) { category in
                        if let (checked, total) = progress[category] {
                            HStack {
                                Text(category.rawValue)
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(checked)/\(total)")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                            }
                        }
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

// MARK: - Kategori Filtreleri
struct SafetyCategoryFilterView: View {
    @Binding var selectedCategory: SafetyChecklist.Category?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                SafetyCategoryFilterButton(
                    title: "Tümü",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                
                ForEach(SafetyChecklist.Category.allCases, id: \.self) { category in
                    SafetyCategoryFilterButton(
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

struct SafetyCategoryFilterButton: View {
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

// MARK: - Kontrol Listesi Öğeleri
struct SafetyChecklistItemsView: View {
    @ObservedObject var checklistService: SafetyChecklistService
    let selectedCategory: SafetyChecklist.Category?
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var filteredItems: [SafetyChecklist] {
        let items = checklistService.checklistItems
        if let category = selectedCategory {
            return items.filter { $0.category == category }
        }
        return items
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(selectedCategory?.rawValue ?? "Tüm Kontroller")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            
            ForEach(filteredItems) { item in
                SafetyChecklistItemRow(
                    item: item,
                    theme: theme,
                    onToggle: {
                        checklistService.toggleItem(item)
                    }
                )
            }
        }
    }
}

struct SafetyChecklistItemRow: View {
    let item: SafetyChecklist
    let theme: ColorTheme
    let onToggle: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(
                            red: item.category.color.red,
                            green: item.category.color.green,
                            blue: item.category.color.blue
                        ).opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: item.category.icon)
                        .font(.system(size: 22))
                        .foregroundColor(Color(
                            red: item.category.color.red,
                            green: item.category.color.green,
                            blue: item.category.color.blue
                        ))
                }
                
                Text(item.item)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                    .strikethrough(item.isChecked)
                    .opacity(item.isChecked ? 0.6 : 1.0)
                
                Spacer()
                
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(item.isChecked ? Color(red: 0.2, green: 0.8, blue: 0.4) : Color.secondary)
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
