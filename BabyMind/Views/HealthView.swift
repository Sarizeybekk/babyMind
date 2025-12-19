//
//  HealthView.swift
//  BabyMind
//
//  Sağlık ekranı
//

import SwiftUI

struct HealthView: View {
    let baby: Baby
    private let healthService = HealthService()
    @State private var vaccinations: [Vaccination] = []
    @State private var healthTips: [String] = []
    @State private var showContent = false
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    var body: some View {
        ZStack {
            // Gradient Arka Plan - Dark Mode Desteği
            LinearGradient(
                colors: getBackgroundGradient(),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Aşı Takvimi
                    VaccinationSection(vaccinations: vaccinations)
                        .padding(.horizontal)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
                    
                    // Sağlık Önerileri
                    HealthTipsSection(tips: healthTips)
                        .padding(.horizontal)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
                    
                    // Acil Durum Bilgileri
                    EmergencySection()
                        .padding(.horizontal)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: showContent)
                    
                    // Büyüme Takibi
                    GrowthTrackingSection(baby: baby)
                        .padding(.horizontal)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: showContent)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Sağlık")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadData()
            withAnimation {
                showContent = true
            }
        }
    }
    
    private func loadData() {
        vaccinations = healthService.getVaccinations(for: baby)
        healthTips = healthService.getHealthTips(for: baby)
    }
    
    private func getBackgroundGradient() -> [Color] {
        if colorScheme == .dark {
            return theme.backgroundGradient
        } else {
            return [
                Color(red: 0.95, green: 0.98, blue: 1.0),
                Color(red: 0.98, green: 0.95, blue: 0.98),
                Color.white
            ]
        }
    }
}

struct VaccinationSection: View {
    let vaccinations: [Vaccination]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.3, green: 0.7, blue: 0.9).opacity(0.3),
                                        Color(red: 0.2, green: 0.6, blue: 0.8).opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "syringe.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.9))
                    }
                    
                    Text("Aşı Takvimi")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.3, green: 0.2, blue: 0.25))
                }
                
                Spacer()
            }
            
            if vaccinations.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                    
                    Text("Tüm aşılar tamamlandı")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.45))
                }
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                        .shadow(color: Color.pink.opacity(0.05), radius: 10, x: 0, y: 3)
                )
            } else {
                ForEach(vaccinations) { vaccination in
                    VaccinationCard(vaccination: vaccination)
                }
            }
        }
    }
}

struct VaccinationCard: View {
    let vaccination: Vaccination
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // İkon
            ZStack {
                Circle()
                    .fill(vaccination.isCompleted ? 
                          Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.15) :
                          Color(red: 1.0, green: 0.6, blue: 0.3).opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: vaccination.isCompleted ? "checkmark.shield.fill" : "shield.fill")
                    .font(.system(size: 26))
                    .foregroundColor(vaccination.isCompleted ? 
                                   Color(red: 0.3, green: 0.8, blue: 0.5) :
                                   Color(red: 1.0, green: 0.6, blue: 0.3))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(vaccination.name)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                    
                    Spacer()
                    
                    if vaccination.isCompleted {
                        Text("✓ Tamamlandı")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.15))
                            .cornerRadius(8)
                    } else {
                        Text("Bekliyor")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.3))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(red: 1.0, green: 0.6, blue: 0.3).opacity(0.15))
                            .cornerRadius(8)
                    }
                }
                
                Text(vaccination.description)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.45))
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 10))
                    Text("\(vaccination.recommendedAge) haftalık")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                }
                .foregroundColor(Color(red: 0.6, green: 0.5, blue: 0.55))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.pink.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
}

struct HealthTipsSection: View {
    let tips: [String]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.5, green: 0.8, blue: 0.6).opacity(0.3),
                                        Color(red: 0.4, green: 0.7, blue: 0.5).opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 0.5, green: 0.8, blue: 0.6))
                    }
                    
                    Text("Sağlık Önerileri")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.3, green: 0.2, blue: 0.25))
                }
                
                Spacer()
            }
            
            ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                HealthTipRow(tip: tip, number: index + 1)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.pink.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
}

struct HealthTipRow: View {
    let tip: String
    let number: Int
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.5, green: 0.8, blue: 0.6),
                                Color(red: 0.4, green: 0.7, blue: 0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)
                
                Text("\(number)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(tip)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct EmergencySection: View {
    let healthService = HealthService()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.3, blue: 0.3).opacity(0.3),
                                        Color(red: 0.9, green: 0.2, blue: 0.2).opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                    }
                    
                    Text("Acil Durum")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.3, green: 0.2, blue: 0.25))
                }
                
                Spacer()
            }
            
            ForEach(healthService.getEmergencyInfo()) { contact in
                EmergencyContactCard(contact: contact)
            }
        }
    }
}

struct EmergencyContactCard: View {
    let contact: EmergencyContact
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            if let url = URL(string: "tel://\(contact.phone)") {
                UIApplication.shared.open(url)
            }
            HapticManager.shared.impact(style: .medium)
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.3, blue: 0.3).opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "phone.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                    
                    Text(contact.phone)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                }
                
                Spacer()
                
                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                    .shadow(color: Color.red.opacity(0.1), radius: 15, x: 0, y: 5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GrowthTrackingSection: View {
    let baby: Baby
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.7, green: 0.5, blue: 0.9).opacity(0.3),
                                        Color(red: 0.6, green: 0.4, blue: 0.8).opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.9))
                    }
                    
                    Text("Büyüme Takibi")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                }
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                GrowthMetricCard(
                    icon: "scalemass.fill",
                    iconColor: Color(red: 1.0, green: 0.6, blue: 0.3),
                    title: "Doğum Ağırlığı",
                    value: String(format: "%.2f kg", baby.birthWeight),
                    subtitle: "Başlangıç"
                )
                
                GrowthMetricCard(
                    icon: "ruler.fill",
                    iconColor: Color(red: 0.5, green: 0.7, blue: 1.0),
                    title: "Doğum Boyu",
                    value: String(format: "%.0f cm", baby.birthHeight),
                    subtitle: "Başlangıç"
                )
            }
            
            if let currentWeight = baby.currentWeight {
                GrowthMetricCard(
                    icon: "arrow.up.circle.fill",
                    iconColor: Color(red: 0.3, green: 0.8, blue: 0.5),
                    title: "Güncel Ağırlık",
                    value: String(format: "%.2f kg", currentWeight),
                    subtitle: "Son ölçüm"
                )
            }
            
            if let currentHeight = baby.currentHeight {
                GrowthMetricCard(
                    icon: "arrow.up.circle.fill",
                    iconColor: Color(red: 0.3, green: 0.8, blue: 0.5),
                    title: "Güncel Boy",
                    value: String(format: "%.0f cm", currentHeight),
                    subtitle: "Son ölçüm"
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.pink.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
}

struct GrowthMetricCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.4))
                
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0.6, green: 0.5, blue: 0.55))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.98, green: 0.97, blue: 0.99))
        )
    }
}

#Preview {
    HealthView(
        baby: Baby(
            name: "Bebek",
            birthDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
            gender: .male,
            birthWeight: 3.2,
            birthHeight: 50
        )
    )
}

