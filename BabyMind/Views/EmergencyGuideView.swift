//
//  EmergencyGuideView.swift
//
//  Acil durum rehberi görünümü
//

import SwiftUI

struct EmergencyGuideView: View {
    let baby: Baby
    @State private var selectedCategory: EmergencyGuide.Category? = nil
    @State private var selectedGuide: EmergencyGuide? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    private let guideService = EmergencyGuideService.shared
    
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
                        Text("Acil Durum Rehberi")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Acil Durum Butonu
                    EmergencyButton()
                        .padding(.horizontal, 20)
                    
                    // Kategori Listesi
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Rehber Kategorileri")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                            .padding(.horizontal, 20)
                        
                        ForEach(guideService.getEmergencyGuides()) { guide in
                            EmergencyGuideCard(
                                guide: guide,
                                theme: theme,
                                onTap: {
                                    selectedGuide = guide
                                }
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Acil Durum")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedGuide) { guide in
            EmergencyGuideDetailView(guide: guide, theme: theme)
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

// MARK: - Acil Durum Butonu
struct EmergencyButton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            if let url = URL(string: "tel:112") {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                Image(systemName: "phone.fill")
                    .font(.system(size: 24))
                
                Text("112 Acil Servis")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.3, blue: 0.3), Color(red: 1.0, green: 0.2, blue: 0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color(red: 1.0, green: 0.3, blue: 0.3).opacity(0.4), radius: 10, x: 0, y: 5)
        }
    }
}

// MARK: - Rehber Kartı
struct EmergencyGuideCard: View {
    let guide: EmergencyGuide
    let theme: ColorTheme
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(
                            red: guide.category.color.red,
                            green: guide.category.color.green,
                            blue: guide.category.color.blue
                        ).opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: guide.category.icon)
                        .font(.system(size: 22))
                        .foregroundColor(Color(
                            red: guide.category.color.red,
                            green: guide.category.color.green,
                            blue: guide.category.color.blue
                        ))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(guide.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    Text(guide.description)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
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

// MARK: - Rehber Detay Görünümü
struct EmergencyGuideDetailView: View {
    let guide: EmergencyGuide
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
                                    .fill(Color(
                                        red: guide.category.color.red,
                                        green: guide.category.color.green,
                                        blue: guide.category.color.blue
                                    ).opacity(0.15))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: guide.category.icon)
                                    .font(.system(size: 30))
                                    .foregroundColor(Color(
                                        red: guide.category.color.red,
                                        green: guide.category.color.green,
                                        blue: guide.category.color.blue
                                    ))
                            }
                            
                            Spacer()
                        }
                        
                        Text(guide.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Text(guide.description)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
                    )
                    
                    // Adımlar
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Yapılması Gerekenler")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        ForEach(Array(guide.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color(
                                            red: guide.category.color.red,
                                            green: guide.category.color.green,
                                            blue: guide.category.color.blue
                                        ))
                                        .frame(width: 28, height: 28)
                                    
                                    Text("\(index + 1)")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                
                                Text(step)
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
                    )
                    
                    // Doktor Uyarısı
                    if let whenToCall = guide.whenToCallDoctor {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                                
                                Text("Ne Zaman Doktora Gidilmeli?")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                            }
                            
                            Text(whenToCall)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
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
                .padding()
            }
            .navigationTitle("Rehber")
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
}
