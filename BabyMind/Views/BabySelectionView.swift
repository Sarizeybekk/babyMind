//
//  BabySelectionView.swift
//  BabyMind
//
//  Bebek seçim ekranı
//

import SwiftUI

struct BabySelectionView: View {
    @ObservedObject var babyManager: BabyManager
    @State private var showAddBaby = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        // Use default theme for selection view, will change when baby is selected
        let defaultTheme = ColorTheme.theme(for: .female)
        return ZStack {
            // Gradient Arka Plan
            LinearGradient(
                colors: defaultTheme.backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Başlık
                    VStack(spacing: 12) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(defaultTheme.primary)
                        
                        Text("Bebeğinizi Seçin")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                    }
                    .padding(.top, 40)
                    
                    // Bebek Listesi
                    VStack(spacing: 16) {
                        ForEach(babyManager.babies) { baby in
                            BabySelectionCard(
                                baby: baby,
                                isSelected: babyManager.selectedBabyId == baby.id,
                                onSelect: {
                                    babyManager.selectBaby(baby)
                                    // Bebek seçildikten sonra ekranı kapat
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        dismiss()
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Yeni Bebek Ekle Butonu
                    Button(action: {
                        showAddBaby = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                            Text("Yeni Bebek Ekle")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [
                                    defaultTheme.primary,
                                    defaultTheme.primaryDark
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: defaultTheme.primary.opacity(0.4), radius: 15, x: 0, y: 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showAddBaby) {
            BabyInfoView(babyManager: babyManager, isFirstBaby: false)
        }
    }
}

struct BabySelectionCard: View {
    let baby: Baby
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        let theme = ColorTheme.theme(for: baby.gender)
        return Button(action: {
            HapticManager.shared.selection()
            onSelect()
        }) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.7, blue: 0.85),
                                    Color(red: 0.95, green: 0.6, blue: 0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                
                // Bilgiler
                VStack(alignment: .leading, spacing: 8) {
                    Text(baby.name.isEmpty ? "Bebeğim" : baby.name)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                    
                    HStack(spacing: 16) {
                        Label("\(baby.ageInWeeks) hafta", systemImage: "calendar")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.4))
                        
                        Label(baby.gender.rawValue, systemImage: "person.fill")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.4))
                    }
                }
                
                Spacer()
                
                // Seçim İşareti
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(theme.primary)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: isSelected ? theme.primary.opacity(0.3) : theme.primary.opacity(0.1), 
                           radius: isSelected ? 15 : 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? theme.primary : Color.clear, 
                           lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}



