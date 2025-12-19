//
//  ActivityLogView.swift
//
//  Takip sayfası - Modern iOS tasarımı
//

import SwiftUI

struct ActivityLogView: View {
    let baby: Baby
    @StateObject private var logger: ActivityLogger
    @StateObject private var medicationService: MedicationService
    @StateObject private var appointmentService: DoctorAppointmentService
    @StateObject private var noteService: DoctorNoteService
    @State private var showAddLog = false
    @State private var showAddMedication = false
    @State private var showAddAppointment = false
    @State private var showAddNote = false
    @State private var selectedType: ActivityLog.ActivityType = .feeding
    @State private var selectedDate = Date()
    @Environment(\.colorScheme) var colorScheme
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    init(baby: Baby) {
        self.baby = baby
        _logger = StateObject(wrappedValue: ActivityLogger(babyId: baby.id))
        _medicationService = StateObject(wrappedValue: MedicationService(babyId: baby.id))
        _appointmentService = StateObject(wrappedValue: DoctorAppointmentService(reminderService: ReminderService.shared))
        _noteService = StateObject(wrappedValue: DoctorNoteService(babyId: baby.id))
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
                    
                    // Bugünün Özeti Kartı
                    TodaySummaryCard(logger: logger)
                        .padding(.horizontal, 20)
                    
                    // Hızlı Ekleme Butonları
                    QuickAddSection(
                        selectedType: $selectedType,
                        showAddLog: $showAddLog
                    )
                    .padding(.horizontal, 20)
                    
                    // Tarih Seçici
                    DateSelectorView(selectedDate: $selectedDate, theme: theme)
                        .padding(.horizontal, 20)
                    
                    // Aktivite Listesi
                    ActivitiesListView(
                        logger: logger,
                        selectedDate: selectedDate,
                        theme: theme
                    )
                    .padding(.horizontal, 20)
                    
                    // İlaç Takibi
                    MedicationSection(
                        medicationService: medicationService,
                        showAddMedication: $showAddMedication
                    )
                    .padding(.horizontal, 20)
                    
                    // Doktor Randevuları
                    DoctorAppointmentsSection(
                        appointmentService: appointmentService,
                        baby: baby,
                        showAddAppointment: $showAddAppointment
                    )
                    .padding(.horizontal, 20)
                    
                    // Doktor Notları
                    DoctorNotesSection(
                        noteService: noteService,
                        showAddNote: $showAddNote
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Takip")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddLog) {
            AddActivityLogView(
                type: selectedType,
                onSave: { log in
                    logger.addLog(log)
                    HapticManager.shared.notification(type: .success)
                }
            )
        }
        .sheet(isPresented: $showAddMedication) {
            AddMedicationView(
                baby: baby,
                onSave: { medication in
                    medicationService.addMedication(medication)
                    HapticManager.shared.notification(type: .success)
                }
            )
        }
        .sheet(isPresented: $showAddAppointment) {
            AddDoctorAppointmentView(
                baby: baby,
                appointmentService: appointmentService,
                onSave: { appointment in
                    appointmentService.addAppointment(appointment)
                    HapticManager.shared.notification(type: .success)
                }
            )
        }
        .sheet(isPresented: $showAddNote) {
            AddDoctorNoteTrackingView(
                baby: baby,
                onSave: { note in
                    noteService.addNote(note)
                    HapticManager.shared.notification(type: .success)
                }
            )
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

// MARK: - Bugünün Özeti Kartı
struct TodaySummaryCard: View {
    @ObservedObject var logger: ActivityLogger
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bugünün Özeti")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
            
            HStack(spacing: 16) {
                SummaryMetricCard(
                    icon: "drop.fill",
                    iconColor: Color(red: 0.5, green: 0.7, blue: 1.0),
                    title: "Beslenme",
                    value: String(format: "%.0f", logger.getTotalFeedingToday()),
                    unit: "ml"
                )
                
                SummaryMetricCard(
                    icon: "moon.stars.fill",
                    iconColor: Color(red: 0.6, green: 0.6, blue: 1.0),
                    title: "Uyku",
                    value: formatSleepTime(logger.getTotalSleepToday()),
                    unit: ""
                )
                
                SummaryMetricCard(
                    icon: "hand.raised.fill",
                    iconColor: Color(red: 1.0, green: 0.7, blue: 0.4),
                    title: "Bez",
                    value: "\(logger.getTodayLogs().filter { $0.type == .diaper }.count)",
                    unit: "kez"
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
    
    private func formatSleepTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)s"
        }
        return "\(minutes)dk"
    }
}

struct SummaryMetricCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(iconColor)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
            
            HStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Hızlı Ekleme Bölümü
struct QuickAddSection: View {
    @Binding var selectedType: ActivityLog.ActivityType
    @Binding var showAddLog: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hızlı Ekle")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
            
            HStack(spacing: 12) {
                QuickAddButton(
                    icon: "drop.fill",
                    title: "Beslenme",
                    color: Color(red: 0.5, green: 0.7, blue: 1.0)
                ) {
                    selectedType = .feeding
                    HapticManager.shared.selection()
                    showAddLog = true
                }
                
                QuickAddButton(
                    icon: "moon.stars.fill",
                    title: "Uyku",
                    color: Color(red: 0.6, green: 0.6, blue: 1.0)
                ) {
                    selectedType = .sleep
                    HapticManager.shared.selection()
                    showAddLog = true
                }
                
                QuickAddButton(
                    icon: "hand.raised.fill",
                    title: "Bez",
                    color: Color(red: 1.0, green: 0.7, blue: 0.4)
                ) {
                    selectedType = .diaper
                    HapticManager.shared.selection()
                    showAddLog = true
                }
            }
        }
    }
}

struct QuickAddButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tarih Seçici
struct DateSelectorView: View {
    @Binding var selectedDate: Date
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(getWeekDates(), id: \.self) { date in
                    DateButton(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        theme: theme
                    ) {
                        HapticManager.shared.selection()
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private func getWeekDates() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        var dates: [Date] = []
        
        for i in -3...3 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(date)
            }
        }
        
        return dates
    }
}

struct DateButton: View {
    let date: Date
    let isSelected: Bool
    let theme: ColorTheme
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(dayName)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? .white : .secondary)
                
                Text(dayNumber)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .white : (colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25)))
            }
            .frame(width: 55, height: 65)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? theme.primary : (colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white))
            )
            .shadow(color: isSelected ? theme.primary.opacity(0.3) : Color.black.opacity(0.05), radius: isSelected ? 8 : 3, x: 0, y: 2)
        }
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).prefix(3).uppercased()
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

// MARK: - Aktivite Listesi
struct ActivitiesListView: View {
    @ObservedObject var logger: ActivityLogger
    let selectedDate: Date
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let logs = logger.getLogs(for: selectedDate)
        
        if logs.isEmpty {
            EmptyStateView()
        } else {
            VStack(alignment: .leading, spacing: 16) {
                Text(selectedDateTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                VStack(spacing: 12) {
                    ForEach(logs) { log in
                        ActivityLogCard(log: log, theme: theme, onDelete: {
                            logger.deleteLog(log)
                            HapticManager.shared.impact(style: .medium)
                        })
                    }
                }
            }
        }
    }
    
    private var selectedDateTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        
        if Calendar.current.isDateInToday(selectedDate) {
            return "Bugün"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            return "Dün"
        } else {
            formatter.dateFormat = "d MMMM"
            return formatter.string(from: selectedDate)
        }
    }
}

struct ActivityLogCard: View {
    let log: ActivityLog
    let theme: ColorTheme
    let onDelete: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // İkon
            ZStack {
                Circle()
                    .fill(activityColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: activityIcon)
                    .font(.system(size: 22))
                    .foregroundColor(activityColor)
            }
            
            // Bilgiler
            VStack(alignment: .leading, spacing: 6) {
                Text(activityName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                HStack(spacing: 8) {
                    Text(log.date, style: .time)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    if let amount = log.amount {
                        Text("• \(String(format: "%.0f", amount)) ml")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    if let duration = log.duration {
                        Text("• \(formatDuration(duration))")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                if let notes = log.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Sil butonu
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var activityIcon: String {
        switch log.type {
        case .feeding: return "drop.fill"
        case .sleep: return "moon.stars.fill"
        case .diaper: return "hand.raised.fill"
        case .medication: return "pills.fill"
        }
    }
    
    private var activityName: String {
        switch log.type {
        case .feeding: return "Beslenme"
        case .sleep: return "Uyku"
        case .diaper: return "Bez Değişimi"
        case .medication: return "İlaç"
        }
    }
    
    private var activityColor: Color {
        switch log.type {
        case .feeding: return Color(red: 0.5, green: 0.7, blue: 1.0)
        case .sleep: return Color(red: 0.6, green: 0.6, blue: 1.0)
        case .diaper: return Color(red: 1.0, green: 0.7, blue: 0.4)
        case .medication: return Color(red: 1.0, green: 0.4, blue: 0.4)
        }
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)s \(minutes)dk"
        }
        return "\(minutes)dk"
    }
}

struct EmptyStateView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("Henüz aktivite yok")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Text("İlk aktivitenizi ekleyin")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
        )
    }
}

// MARK: - Aktivite Ekleme Formu
struct AddActivityLogView: View {
    let type: ActivityLog.ActivityType
    let onSave: (ActivityLog) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var duration: String = ""
    @State private var notes: String = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Aktivite Bilgileri") {
                    DatePicker("Tarih ve Saat", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                    
                    if type == .feeding {
                        HStack {
                            Text("Miktar (ml)")
                            Spacer()
                            TextField("0", text: $amount)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                    }
                    
                    if type == .sleep {
                        HStack {
                            Text("Süre (dakika)")
                            Spacer()
                            TextField("0", text: $duration)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                    }
                    
                    TextField("Notlar (opsiyonel)", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle(type.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let log = ActivityLog(
                            type: type,
                            date: date,
                            duration: type == .sleep ? (Double(duration) ?? 0) * 60 : nil,
                            amount: type == .feeding ? Double(amount) : nil,
                            notes: notes.isEmpty ? nil : notes
                        )
                        onSave(log)
                        dismiss()
                    }
                    .disabled((type == .feeding && amount.isEmpty) || (type == .sleep && duration.isEmpty))
                }
            }
        }
    }
}

// MARK: - İlaç Takibi Bölümü
struct MedicationSection: View {
    @ObservedObject var medicationService: MedicationService
    @Binding var showAddMedication: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("İlaç Takibi")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
                
                Button(action: {
                    HapticManager.shared.selection()
                    showAddMedication = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.9))
                }
            }
            
            let activeMedications = medicationService.activeMedications()
            
            if activeMedications.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "pills.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("Aktif ilaç yok")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(activeMedications.prefix(3)) { medication in
                        MedicationCard(medication: medication, onDelete: {
                            medicationService.deleteMedication(medication)
                        })
                    }
                }
            }
        }
    }
}

struct MedicationCard: View {
    let medication: Medication
    let onDelete: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.3, green: 0.7, blue: 0.9).opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "pills.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.9))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Text("\(medication.dosage) • \(medication.frequency.rawValue)")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Doktor Randevuları Bölümü
struct DoctorAppointmentsSection: View {
    @ObservedObject var appointmentService: DoctorAppointmentService
    let baby: Baby
    @Binding var showAddAppointment: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Doktor Randevuları")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
                
                Button(action: {
                    HapticManager.shared.selection()
                    showAddAppointment = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                }
            }
            
            let upcomingAppointments = appointmentService.upcomingAppointments(for: baby.id, limit: 3)
            
            if upcomingAppointments.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("Yaklaşan randevu yok")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(upcomingAppointments) { appointment in
                        AppointmentCard(appointment: appointment, onDelete: {
                            appointmentService.deleteAppointment(appointment)
                        })
                    }
                }
            }
        }
    }
}

struct AppointmentCard: View {
    let appointment: DoctorAppointment
    let onDelete: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.4, blue: 0.4).opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "stethoscope")
                    .font(.system(size: 22))
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.doctorName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Text("\(appointment.specialty) • \(formatDate(appointment.date))")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMM, HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Doktor Notları Bölümü
struct DoctorNotesSection: View {
    @ObservedObject var noteService: DoctorNoteService
    @Binding var showAddNote: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Doktor Notları")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
                
                Button(action: {
                    HapticManager.shared.selection()
                    showAddNote = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 0.5, green: 0.8, blue: 0.6))
                }
            }
            
            let recentNotes = Array(noteService.notes.prefix(3))
            
            if recentNotes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "note.text")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("Doktor notu yok")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(recentNotes) { note in
                        TrackingDoctorNoteCard(note: note, onDelete: {
                            noteService.deleteNote(note)
                        })
                    }
                }
            }
        }
    }
}

struct TrackingDoctorNoteCard: View {
    let note: DoctorNote
    let onDelete: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.5, green: 0.8, blue: 0.6).opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "note.text")
                    .font(.system(size: 22))
                    .foregroundColor(Color(red: 0.5, green: 0.8, blue: 0.6))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(note.doctorName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Text("\(note.reason) • \(formatDate(note.date))")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Form View'ları
struct AddMedicationView: View {
    let baby: Baby
    let onSave: (Medication) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var frequency: Medication.Frequency = .once
    @State private var startDate = Date()
    @State private var endDate: Date? = nil
    @State private var notes: String = ""
    @State private var hasEndDate = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("İlaç Bilgileri") {
                    TextField("İlaç Adı", text: $name)
                    TextField("Dozaj (örn: 5ml)", text: $dosage)
                    
                    Picker("Sıklık", selection: $frequency) {
                        ForEach(Medication.Frequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    
                    DatePicker("Başlangıç Tarihi", selection: $startDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                    
                    Toggle("Bitiş Tarihi Var", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker("Bitiş Tarihi", selection: Binding(
                            get: { endDate ?? Date() },
                            set: { endDate = $0 }
                        ), displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                    }
                    
                    TextField("Notlar (opsiyonel)", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("İlaç Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let medication = Medication(
                            babyId: baby.id,
                            name: name,
                            dosage: dosage,
                            frequency: frequency,
                            startDate: startDate,
                            endDate: hasEndDate ? endDate : nil,
                            notes: notes.isEmpty ? nil : notes
                        )
                        onSave(medication)
                        dismiss()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)
                }
            }
        }
    }
}

struct AddDoctorAppointmentView: View {
    let baby: Baby
    @ObservedObject var appointmentService: DoctorAppointmentService
    let onSave: (DoctorAppointment) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var doctorName: String = ""
    @State private var specialty: String = ""
    @State private var clinicName: String = ""
    @State private var address: String = ""
    @State private var phoneNumber: String = ""
    @State private var date = Date()
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Doktor Bilgileri") {
                    TextField("Doktor Adı", text: $doctorName)
                    TextField("Uzmanlık", text: $specialty)
                    TextField("Klinik Adı", text: $clinicName)
                    TextField("Adres", text: $address)
                    TextField("Telefon", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section("Randevu Bilgileri") {
                    DatePicker("Tarih ve Saat", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                    
                    TextField("Notlar (opsiyonel)", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Randevu Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let appointment = DoctorAppointment(
                            doctorName: doctorName,
                            specialty: specialty,
                            clinicName: clinicName,
                            address: address,
                            phoneNumber: phoneNumber,
                            date: date,
                            notes: notes,
                            babyId: baby.id
                        )
                        onSave(appointment)
                        dismiss()
                    }
                    .disabled(doctorName.isEmpty || specialty.isEmpty)
                }
            }
        }
    }
}

struct AddDoctorNoteTrackingView: View {
    let baby: Baby
    let onSave: (DoctorNote) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var doctorName: String = ""
    @State private var specialty: String = ""
    @State private var reason: String = ""
    @State private var diagnosis: String = ""
    @State private var notes: String = ""
    @State private var date = Date()
    @State private var recommendations: [String] = []
    @State private var newRecommendation: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Doktor Bilgileri") {
                    TextField("Doktor Adı", text: $doctorName)
                    TextField("Uzmanlık", text: $specialty)
                    DatePicker("Tarih", selection: $date, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                }
                
                Section("Ziyaret Bilgileri") {
                    TextField("Ziyaret Nedeni", text: $reason)
                    TextField("Teşhis (opsiyonel)", text: $diagnosis)
                    TextField("Notlar (opsiyonel)", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                Section("Öneriler") {
                    ForEach(recommendations, id: \.self) { rec in
                        Text(rec)
                    }
                    .onDelete { indexSet in
                        recommendations.remove(atOffsets: indexSet)
                    }
                    
                    HStack {
                        TextField("Yeni öneri", text: $newRecommendation)
                        Button("Ekle") {
                            if !newRecommendation.isEmpty {
                                recommendations.append(newRecommendation)
                                newRecommendation = ""
                            }
                        }
                    }
                }
            }
            .navigationTitle("Doktor Notu Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let note = DoctorNote(
                            babyId: baby.id,
                            date: date,
                            doctorName: doctorName,
                            specialty: specialty.isEmpty ? nil : specialty,
                            reason: reason,
                            diagnosis: diagnosis.isEmpty ? nil : diagnosis,
                            notes: notes.isEmpty ? nil : notes,
                            recommendations: recommendations
                        )
                        onSave(note)
                        dismiss()
                    }
                    .disabled(doctorName.isEmpty || reason.isEmpty)
                }
            }
        }
    }
}
