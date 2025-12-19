//
//  RemindersView.swift
//  BabyMind
//
//  Hatırlatıcılar görünümü
//

import SwiftUI

struct RemindersView: View {
    let baby: Baby
    @ObservedObject private var reminderService = ReminderService.shared
    @State private var showAddReminder = false
    @State private var selectedReminder: Reminder?
    
    var body: some View {
        let theme = ColorTheme.theme(for: baby.gender)
        
        ZStack {
            LinearGradient(
                colors: theme.backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Yaklaşan Hatırlatıcılar
                if !upcomingReminders.isEmpty {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(upcomingReminders) { reminder in
                                ReminderCard(reminder: reminder, theme: theme) {
                                    reminderService.completeReminder(reminder)
                                }
                                .onTapGesture {
                                    selectedReminder = reminder
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    EmptyRemindersView(theme: theme)
                }
            }
        }
        .navigationTitle("Hatırlatıcılar")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    // Test butonu (geliştirme için)
                    #if DEBUG
                    Button(action: {
                        // Test için hemen bir alert göster
                        if let firstReminder = reminderService.reminders(for: baby.id).first(where: { !$0.isCompleted }) {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("ReminderAlert"),
                                object: nil,
                                userInfo: ["reminderId": firstReminder.id.uuidString]
                            )
                        } else {
                            // Test hatırlatıcısı oluştur
                            let testReminder = Reminder(
                                title: "Test Hatırlatıcı",
                                description: "Bu bir test hatırlatıcısıdır",
                                type: .other,
                                date: Date(),
                                babyId: baby.id
                            )
                            reminderService.addReminder(testReminder)
                            NotificationCenter.default.post(
                                name: NSNotification.Name("ReminderAlert"),
                                object: nil,
                                userInfo: ["reminderId": testReminder.id.uuidString]
                            )
                        }
                    }) {
                        Image(systemName: "bell.badge")
                            .font(.system(size: 20))
                            .foregroundColor(theme.primary)
                    }
                    #endif
                    
                    Button(action: {
                        showAddReminder = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(theme.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddReminder) {
            AddReminderView(baby: baby, theme: theme)
        }
        .sheet(item: $selectedReminder) { reminder in
            ReminderDetailView(reminder: reminder, theme: theme)
        }
    }
    
    private var upcomingReminders: [Reminder] {
        reminderService.upcomingReminders(for: baby.id, limit: 20)
    }
}

struct ReminderCard: View {
    let reminder: Reminder
    let theme: ColorTheme
    let onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // İkon
            ZStack {
                Circle()
                    .fill(theme.primary.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: reminder.type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
            }
            
            // Bilgiler
            VStack(alignment: .leading, spacing: 6) {
                Text(reminder.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.text)
                
                if !reminder.description.isEmpty {
                    Text(reminder.description)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(theme.text.opacity(0.7))
                        .lineLimit(2)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text(reminder.date, style: .relative)
                        .font(.system(size: 12, design: .rounded))
                }
                .foregroundColor(theme.text.opacity(0.6))
            }
            
            Spacer()
            
            // Tamamla butonu
            Button(action: onComplete) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(theme.primary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: theme.cardShadow, radius: 10, x: 0, y: 3)
        )
    }
}

struct EmptyRemindersView: View {
    let theme: ColorTheme
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(theme.text.opacity(0.3))
            
            Text("Henüz hatırlatıcı yok")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)
            
            Text("Yeni hatırlatıcı eklemek için + butonuna tıklayın")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(theme.text.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct AddReminderView: View {
    let baby: Baby
    @ObservedObject var reminderService = ReminderService.shared
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var type: Reminder.ReminderType = .other
    @State private var date: Date = Date()
    @State private var isRepeating: Bool = false
    @State private var repeatInterval: Reminder.RepeatInterval = .daily
    
    var body: some View {
        NavigationView {
            Form {
                Section("Bilgiler") {
                    TextField("Başlık", text: $title)
                    TextField("Açıklama (opsiyonel)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Tür", selection: $type) {
                        ForEach(Reminder.ReminderType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                }
                
                Section("Zamanlama") {
                    DatePicker("Tarih ve Saat", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    Toggle("Tekrarla", isOn: $isRepeating)
                    
                    if isRepeating {
                        Picker("Tekrar Aralığı", selection: $repeatInterval) {
                            ForEach(Reminder.RepeatInterval.allCases, id: \.self) { interval in
                                Text(interval.rawValue).tag(interval)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Yeni Hatırlatıcı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let reminder = Reminder(
                            title: title,
                            description: description,
                            type: type,
                            date: date,
                            isRepeating: isRepeating,
                            repeatInterval: isRepeating ? repeatInterval : nil,
                            babyId: baby.id
                        )
                        reminderService.addReminder(reminder)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct ReminderDetailView: View {
    let reminder: Reminder
    @ObservedObject var reminderService = ReminderService.shared
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // İkon ve Başlık
                    HStack {
                        ZStack {
                            Circle()
                                .fill(theme.primary.opacity(0.15))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: reminder.type.icon)
                                .font(.system(size: 28))
                                .foregroundColor(theme.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(reminder.title)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(theme.text)
                            
                            Text(reminder.type.rawValue)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(theme.text.opacity(0.6))
                        }
                        
                        Spacer()
                    }
                    .padding()
                    
                    // Tarih
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tarih ve Saat")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(theme.text.opacity(0.7))
                        
                        Text(reminder.date, style: .date)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(theme.text)
                        
                        Text(reminder.date, style: .time)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(theme.text)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: theme.cardShadow, radius: 5, x: 0, y: 2)
                    )
                    
                    // Açıklama
                    if !reminder.description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Açıklama")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(theme.text.opacity(0.7))
                            
                            Text(reminder.description)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(theme.text)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: theme.cardShadow, radius: 5, x: 0, y: 2)
                        )
                    }
                    
                    // Tekrarlama Bilgisi
                    if reminder.isRepeating, let interval = reminder.repeatInterval {
                        HStack {
                            Image(systemName: "repeat")
                                .foregroundColor(theme.primary)
                            Text("Tekrarlama: \(interval.rawValue)")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(theme.text)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.primary.opacity(0.1))
                        )
                    }
                    
                    // Tamamla Butonu
                    if !reminder.isCompleted {
                        Button(action: {
                            reminderService.completeReminder(reminder)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Tamamlandı Olarak İşaretle")
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [theme.primary, theme.primaryDark],
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
            .navigationTitle("Hatırlatıcı Detayı")
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

