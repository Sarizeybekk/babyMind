//
//  FamilyCalendarView.swift
//  BabyMind
//
//  Aile Takvimi görünümü
//

import SwiftUI
import EventKit
import Combine

struct FamilyCalendarView: View {
    let baby: Baby
    @StateObject private var calendarService = FamilyCalendarService()
    @State private var selectedDate = Date()
    @State private var events: [CalendarEvent] = []
    @State private var showAddEvent = false
    @State private var showPermissionAlert = false
    
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
            
            ScrollView {
                VStack(spacing: 24) {
                    // Takvim Görünümü
                    calendarView
                    
                    // Etkinlikler Listesi
                    eventsList
                }
                .padding()
            }
        }
        .navigationTitle("Aile Takvimi")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if calendarService.hasPermission {
                        showAddEvent = true
                    } else {
                        showPermissionAlert = true
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(theme.primary)
                }
            }
        }
        .onAppear {
            requestPermission()
            loadEvents()
        }
        .sheet(isPresented: $showAddEvent) {
            AddCalendarEventView(baby: baby, calendarService: calendarService, theme: theme)
        }
        .alert("Takvim İzni Gerekli", isPresented: $showPermissionAlert) {
            Button("Ayarlar") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("İptal", role: .cancel) { }
        } message: {
            Text("Takvime etkinlik eklemek için takvim erişim izni gereklidir.")
        }
    }
    
    @ViewBuilder
    private var calendarView: some View {
        VStack(spacing: 16) {
            // Ay ve Yıl Başlığı
            HStack {
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                    loadEvents()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(theme.primary)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(theme.text)
                
                Spacer()
                
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                    loadEvents()
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(theme.primary)
                }
            }
            
            // Hafta Günleri
            HStack(spacing: 0) {
                ForEach(["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(theme.text.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Takvim Günleri
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(calendarDays, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        hasEvent: events.contains { Calendar.current.isDate($0.date, inSameDayAs: date) },
                        isCurrentMonth: Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .month),
                        theme: theme
                    ) {
                        selectedDate = date
                        loadEvents()
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
    }
    
    @ViewBuilder
    private var eventsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Etkinlikler")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)
            
            let dayEvents = events.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            
            if dayEvents.isEmpty {
                Text("Bu gün için etkinlik yok")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(theme.text.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(dayEvents) { event in
                    CalendarEventRow(event: event, theme: theme)
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
    
    private var calendarDays: [Date] {
        let calendar = Calendar.current
        guard let firstDay = calendar.dateInterval(of: .month, for: selectedDate)?.start else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let daysToSubtract = (firstWeekday + 5) % 7 // Pazartesi = 0
        
        guard let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: firstDay) else {
            return []
        }
        
        var days: [Date] = []
        for i in 0..<42 { // 6 hafta
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func requestPermission() {
        calendarService.requestPermission { granted in
            if granted {
                loadEvents()
            }
        }
    }
    
    private func loadEvents() {
        events = calendarService.getEvents(for: selectedDate)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate).capitalized
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let hasEvent: Bool
    let isCurrentMonth: Bool
    let theme: ColorTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14, weight: isSelected ? .bold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? .white : (isCurrentMonth ? theme.text : theme.text.opacity(0.3)))
                
                if hasEvent {
                    Circle()
                        .fill(isSelected ? .white : theme.primary)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(isSelected ? theme.primary : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CalendarEventRow: View {
    let event: CalendarEvent
    let theme: ColorTheme
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(theme.primary)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.text)
                
                if !event.notes.isEmpty {
                    Text(event.notes)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(theme.text.opacity(0.7))
                        .lineLimit(1)
                }
                
                Text(event.date, style: .time)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(theme.text.opacity(0.6))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

// MARK: - Calendar Service
struct CalendarEvent: Identifiable {
    let id: String
    let title: String
    let date: Date
    let notes: String
    let type: EventType
    
    enum EventType {
        case doctor
        case vaccination
        case activity
        case other
    }
}

class FamilyCalendarService: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var hasPermission = false
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { granted, error in
            DispatchQueue.main.async {
                self.hasPermission = granted
                completion(granted)
            }
        }
    }
    
    func getEvents(for date: Date) -> [CalendarEvent] {
        guard hasPermission else { return [] }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let ekEvents = eventStore.events(matching: predicate)
        
        return ekEvents.map { ekEvent in
            CalendarEvent(
                id: ekEvent.eventIdentifier,
                title: ekEvent.title,
                date: ekEvent.startDate,
                notes: ekEvent.notes ?? "",
                type: determineEventType(ekEvent)
            )
        }
    }
    
    func addEvent(_ event: CalendarEvent) {
        guard hasPermission else { return }
        
        let ekEvent = EKEvent(eventStore: eventStore)
        ekEvent.title = event.title
        ekEvent.startDate = event.date
        ekEvent.endDate = event.date.addingTimeInterval(3600) // 1 saat
        ekEvent.notes = event.notes
        ekEvent.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(ekEvent, span: .thisEvent)
        } catch {
            print("Etkinlik kaydedilemedi: \(error)")
        }
    }
    
    private func determineEventType(_ event: EKEvent) -> CalendarEvent.EventType {
        let title = event.title.lowercased()
        if title.contains("doktor") || title.contains("doctor") {
            return .doctor
        } else if title.contains("aşı") || title.contains("vaccine") {
            return .vaccination
        } else if title.contains("aktivite") || title.contains("activity") {
            return .activity
        } else {
            return .other
        }
    }
}

struct AddCalendarEventView: View {
    let baby: Baby
    @ObservedObject var calendarService: FamilyCalendarService
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var eventType: CalendarEvent.EventType = .other
    
    var body: some View {
        NavigationView {
            Form {
                Section("Etkinlik Bilgisi") {
                    TextField("Başlık", text: $title)
                    
                    Picker("Tip", selection: $eventType) {
                        Text("Doktor").tag(CalendarEvent.EventType.doctor)
                        Text("Aşı").tag(CalendarEvent.EventType.vaccination)
                        Text("Aktivite").tag(CalendarEvent.EventType.activity)
                        Text("Diğer").tag(CalendarEvent.EventType.other)
                    }
                    
                    DatePicker("Tarih", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                }
                
                Section("Notlar") {
                    TextField("Notlar (opsiyonel)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Etkinlik Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveEvent() {
        let event = CalendarEvent(
            id: UUID().uuidString,
            title: title,
            date: date,
            notes: notes,
            type: eventType
        )
        
        calendarService.addEvent(event)
        HapticManager.shared.notification(type: .success)
        dismiss()
    }
}

