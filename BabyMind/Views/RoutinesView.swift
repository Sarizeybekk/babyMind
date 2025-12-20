//
//  RoutinesView.swift
//
//  Rutinler görünümü
//

import SwiftUI

struct RoutinesView: View {
    let baby: Baby
    @StateObject private var routineService: RoutineService
    @State private var showAddRoutine = false
    @State private var selectedRoutine: Routine? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    init(baby: Baby) {
        self.baby = baby
        _routineService = StateObject(wrappedValue: RoutineService(babyId: baby.id))
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
                        Text("Rutinler")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Spacer()
                        
                        Button(action: {
                            showAddRoutine = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(theme.primary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Başarı Skoru
                    RoutineSuccessScoreCard(routineService: routineService, theme: theme)
                        .padding(.horizontal, 20)
                    
                    // Önerilen Rutinler
                    RecommendedRoutinesView(routineService: routineService, baby: baby, theme: theme)
                        .padding(.horizontal, 20)
                    
                    // Günlük Rutinler
                    DailyRoutinesView(routineService: routineService, theme: theme)
                        .padding(.horizontal, 20)
                }
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Rutinler")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddRoutine) {
            AddRoutineView(routineService: routineService, baby: baby, theme: theme)
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

// MARK: - Başarı Skoru Kartı
struct RoutineSuccessScoreCard: View {
    @ObservedObject var routineService: RoutineService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var successScore: Double {
        routineService.getRoutineSuccessScore()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("Rutin Başarı Skoru")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            HStack(spacing: 30) {
                ZStack {
                    Circle()
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 16)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: successScore / 100)
                        .stroke(theme.primary, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 4) {
                        Text("\(Int(successScore))")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(theme.primary)
                        
                        Text("/100")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Son 7 Gün")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text(successScore >= 80 ? "Mükemmel" : successScore >= 60 ? "İyi" : successScore >= 40 ? "Orta" : "Geliştirilmeli")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
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

// MARK: - Önerilen Rutinler
struct RecommendedRoutinesView: View {
    @ObservedObject var routineService: RoutineService
    let baby: Baby
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var recommendedRoutines: [RoutineSchedule] {
        routineService.getRecommendedRoutines(ageInMonths: baby.ageInMonths)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("Yaşa Göre Rutin Önerileri")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            }
            
            ForEach(recommendedRoutines, id: \.ageRange) { schedule in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: schedule.type.icon)
                            .font(.system(size: 18))
                            .foregroundColor(theme.primary)
                        
                        Text("\(schedule.type.rawValue) - \(schedule.ageRange)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                    }
                    
                    Text(schedule.description)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorScheme == .dark ? Color(red: 0.25, green: 0.25, blue: 0.3) : Color(red: 0.98, green: 0.98, blue: 0.99))
                )
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

// MARK: - Günlük Rutinler
struct DailyRoutinesView: View {
    @ObservedObject var routineService: RoutineService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var todayRoutines: [Routine] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        
        return routineService.routines.filter { routine in
            routine.time >= today && routine.time < tomorrow
        }.sorted { $0.time < $1.time }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bugünün Rutinleri")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            
            if todayRoutines.isEmpty {
                Text("Henüz rutin eklenmemiş")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
            } else {
                ForEach(todayRoutines) { routine in
                    RoutineRow(routine: routine, theme: theme, onComplete: {
                        routineService.completeRoutine(routine)
                    })
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

struct RoutineRow: View {
    let routine: Routine
    let theme: ColorTheme
    let onComplete: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(theme.primary.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: routine.type.icon)
                    .font(.system(size: 22))
                    .foregroundColor(theme.primary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(routine.type.rawValue)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Text(routine.time, style: .time)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !routine.isCompleted {
                Button(action: onComplete) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 24))
                        .foregroundColor(theme.primary)
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(red: 0.25, green: 0.25, blue: 0.3) : Color(red: 0.98, green: 0.98, blue: 0.99))
        )
    }
}

// MARK: - Rutin Ekleme
struct AddRoutineView: View {
    @ObservedObject var routineService: RoutineService
    let baby: Baby
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    @State private var routineType: Routine.RoutineType = .sleep
    @State private var time = Date()
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rutin Tipi")) {
                    Picker("Tip", selection: $routineType) {
                        ForEach(Routine.RoutineType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Zaman")) {
                    DatePicker("Saat", selection: $time, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Notlar (Opsiyonel)")) {
                    TextField("Notlar", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Yeni Rutin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let routine = Routine(
                            babyId: baby.id,
                            type: routineType,
                            time: time,
                            notes: notes.isEmpty ? nil : notes
                        )
                        routineService.addRoutine(routine)
                        HapticManager.shared.notification(type: .success)
                        dismiss()
                    }
                }
            }
        }
    }
}
