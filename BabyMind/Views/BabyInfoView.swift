//
//  BabyInfoView.swift
//  BabyMind
//
//  Bebek bilgileri giriş ekranı
//

import SwiftUI

struct BabyInfoView: View {
    @ObservedObject var babyManager: BabyManager
    @Binding var baby: Baby?
    @State private var name: String = ""
    @State private var birthDate: Date = Date()
    @State private var gender: Baby.Gender = .male
    @State private var birthWeight: String = ""
    @State private var birthHeight: String = ""
    @State private var showAnimation = false
    var isFirstBaby: Bool = true
    @Environment(\.dismiss) var dismiss
    
    init(babyManager: BabyManager? = nil, baby: Binding<Baby?> = .constant(nil), isFirstBaby: Bool = true) {
        if let manager = babyManager {
            self._babyManager = ObservedObject(wrappedValue: manager)
        } else {
            self._babyManager = ObservedObject(wrappedValue: BabyManager())
        }
        self._baby = baby
        self.isFirstBaby = isFirstBaby
    }
    
    var body: some View {
        ZStack {
            // Gradient Arka Plan
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.9, blue: 0.95),
                    Color(red: 0.98, green: 0.85, blue: 0.92),
                    Color(red: 0.95, green: 0.8, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Üst Başlık Bölümü
                    VStack(spacing: 16) {
                        // Logo/İkon - Pembe Kalp
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
                                .frame(width: 120, height: 120)
                                .shadow(color: Color.pink.opacity(0.3), radius: 20, x: 0, y: 10)
                            
                            Image(systemName: "heart.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(showAnimation ? 1.0 : 0.8)
                        .opacity(showAnimation ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showAnimation)
                        
                        VStack(spacing: 8) {
                            Text("BabyMind'a")
                                .font(.system(size: 32, weight: .light, design: .rounded))
                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.3))
                            
                            Text("Hoş Geldiniz")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.5, green: 0.2, blue: 0.35))
                        }
                        .opacity(showAnimation ? 1.0 : 0.0)
                        .offset(y: showAnimation ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showAnimation)
                        
                        Text("Bebeğiniz için kişiselleştirilmiş rehberlik")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.4))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .opacity(showAnimation ? 1.0 : 0.0)
                            .offset(y: showAnimation ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: showAnimation)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                    
                    // Form Kartı
                    VStack(spacing: 24) {
                        // Bebek Bilgileri
                        VStack(alignment: .leading, spacing: 20) {
                            SectionHeader(icon: "person.fill", title: "Bebek Bilgileri")
                            
                            CustomTextField(
                                title: "Bebek Adı",
                                text: $name,
                                placeholder: "Örn: Ayşe, Mehmet",
                                icon: "heart.text.square.fill"
                            )
                            
                            CustomDatePicker(
                                title: "Doğum Tarihi",
                                date: $birthDate,
                                icon: "calendar"
                            )
                            
                            CustomPicker(
                                title: "Cinsiyet",
                                selection: $gender,
                                icon: "person.2.fill"
                            )
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.pink.opacity(0.1), radius: 15, x: 0, y: 5)
                        )
                        
                        // Doğum Bilgileri
                        VStack(alignment: .leading, spacing: 20) {
                            SectionHeader(icon: "chart.bar.fill", title: "Doğum Bilgileri")
                            
                            HStack(spacing: 16) {
                                CustomNumberField(
                                    title: "Doğum Ağırlığı",
                                    text: $birthWeight,
                                    placeholder: "3.2",
                                    unit: "kg",
                                    icon: "scalemass.fill"
                                )
                                
                                CustomNumberField(
                                    title: "Doğum Boyu",
                                    text: $birthHeight,
                                    placeholder: "50",
                                    unit: "cm",
                                    icon: "ruler.fill"
                                )
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.pink.opacity(0.1), radius: 15, x: 0, y: 5)
                        )
                        
                        // Kaydet Butonu
                        Button(action: saveBabyInfo) {
                            HStack {
                                Text("Başlayalım")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 20))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.5, blue: 0.7),
                                        Color(red: 0.9, green: 0.4, blue: 0.65)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.pink.opacity(0.4), radius: 15, x: 0, y: 8)
                            .scaleEffect(isFormValid ? 1.0 : 0.95)
                        }
                        .disabled(!isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.6)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            showAnimation = true
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !birthWeight.isEmpty &&
        !birthHeight.isEmpty &&
        Double(birthWeight) != nil &&
        Double(birthHeight) != nil
    }
    
    private func saveBabyInfo() {
        guard let weight = Double(birthWeight),
              let height = Double(birthHeight) else {
            return
        }
        
        let newBaby = Baby(
            name: name,
            birthDate: birthDate,
            gender: gender,
            birthWeight: weight,
            birthHeight: height
        )
        
        HapticManager.shared.notification(type: .success)
        
        // Birden fazla bebek yönetimi
        babyManager.addBaby(newBaby)
        if !isFirstBaby {
            dismiss()
        }
    }
}

// MARK: - Custom Components

struct SectionHeader: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.7))
            
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.35))
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.7))
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .font(.system(size: 16, design: .rounded))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.98, green: 0.95, blue: 0.97))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.pink.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct CustomDatePicker: View {
    let title: String
    @Binding var date: Date
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.35))
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.7))
                    .frame(width: 20)
                
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "tr_TR"))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.98, green: 0.95, blue: 0.97))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.pink.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct CustomPicker: View {
    let title: String
    @Binding var selection: Baby.Gender
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.35))
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.7))
                    .frame(width: 20)
                
                Picker("", selection: $selection) {
                    ForEach(Baby.Gender.allCases, id: \.self) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.98, green: 0.95, blue: 0.97))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.pink.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct CustomNumberField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let unit: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.35))
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.7))
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 16, design: .rounded))
                
                Text(unit)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.4))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.98, green: 0.95, blue: 0.97))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.pink.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    BabyInfoView(babyManager: BabyManager(), isFirstBaby: true)
}
