//
//  ReminderService.swift
//  BabyMind
//
//  Hatırlatıcı yönetim servisi
//

import Foundation
import UserNotifications
import Combine

class ReminderService: ObservableObject {
    @Published var reminders: [Reminder] = []
    
    private let remindersKey = "savedReminders"
    
    // Singleton instance
    static let shared = ReminderService()
    
    init() {
        // Notification delegate'i ayarla
        _ = NotificationDelegate.shared
        requestNotificationPermission()
        loadReminders()
        
        // Timer'ı başlat (biraz gecikmeyle, init tamamlandıktan sonra)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.startReminderChecker()
        }
    }
    
    // MARK: - Reminder Checker
    
    private var reminderCheckTimer: Timer?
    
    private func startReminderChecker() {
        // Eğer timer zaten varsa iptal et
        reminderCheckTimer?.invalidate()
        
        // Her 5 saniyede bir kontrol et (test için kısa, production'da 30 saniye yapılabilir)
        reminderCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkUpcomingReminders()
        }
        // Timer'ı main run loop'a ekle
        if let timer = reminderCheckTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private var shownReminderIds: Set<UUID> = [] // Gösterilen hatırlatıcıları takip et
    
    private func checkUpcomingReminders() {
        let now = Date()
        
        for reminder in reminders where !reminder.isCompleted {
            // Hatırlatıcı zamanı geldi mi ve daha önce gösterilmedi mi?
            if reminder.date <= now && reminder.date > now.addingTimeInterval(-300) && !shownReminderIds.contains(reminder.id) {
                // Bildirim gönder
                shownReminderIds.insert(reminder.id)
                showReminderAlert(reminder)
            }
        }
    }
    
    private func showReminderAlert(_ reminder: Reminder) {
        // Ana thread'de çalıştır
        DispatchQueue.main.async {
            // Reminder ID'yi gönder, ReminderAlertManager ReminderService'ten alacak
            NotificationCenter.default.post(
                name: NSNotification.Name("ReminderAlert"),
                object: nil,
                userInfo: ["reminderId": reminder.id.uuidString]
            )
        }
    }
    
    func getReminder(by id: UUID) -> Reminder? {
        return reminders.first { $0.id == id }
    }
    
    func markReminderAsShown(_ reminder: Reminder) {
        shownReminderIds.remove(reminder.id)
    }
    
    // MARK: - Notification Permission
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - CRUD Operations
    
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
        saveReminders()
        scheduleNotification(for: reminder)
    }
    
    func updateReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            // Eski bildirimi iptal et
            if let oldNotificationId = reminders[index].notificationId {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [oldNotificationId])
            }
            
            reminders[index] = reminder
            saveReminders()
            scheduleNotification(for: reminder)
        }
    }
    
    func deleteReminder(_ reminder: Reminder) {
        if let notificationId = reminder.notificationId {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
        }
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
    }
    
    func completeReminder(_ reminder: Reminder) {
        var updatedReminder = reminder
        updatedReminder.isCompleted = true
        
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = updatedReminder
            
            // Tekrarlayan hatırlatıcı ise yeni bir tane oluştur
            if reminder.isRepeating, let nextDate = reminder.nextDate {
                let newReminder = Reminder(
                    id: UUID(),
                    title: reminder.title,
                    description: reminder.description,
                    type: reminder.type,
                    date: nextDate,
                    isCompleted: false,
                    isRepeating: reminder.isRepeating,
                    repeatInterval: reminder.repeatInterval,
                    babyId: reminder.babyId,
                    notificationId: nil
                )
                addReminder(newReminder)
            }
            
            saveReminders()
        }
    }
    
    // MARK: - Query Methods
    
    func reminders(for babyId: UUID) -> [Reminder] {
        reminders.filter { $0.babyId == babyId }
    }
    
    func upcomingReminders(for babyId: UUID, limit: Int = 5) -> [Reminder] {
        let now = Date()
        return reminders(for: babyId)
            .filter { !$0.isCompleted && $0.date >= now }
            .sorted { $0.date < $1.date }
            .prefix(limit)
            .map { $0 }
    }
    
    func reminders(for babyId: UUID, type: Reminder.ReminderType) -> [Reminder] {
        reminders(for: babyId).filter { $0.type == type }
    }
    
    // MARK: - Notification Scheduling
    
    private func scheduleNotification(for reminder: Reminder) {
        guard !reminder.isCompleted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.description.isEmpty ? "Hatırlatıcı zamanı geldi!" : reminder.description
        content.sound = .default
        content.badge = 1
        
        // Kategori ekle (aksiyon butonları için)
        content.categoryIdentifier = "REMINDER_CATEGORY"
        
        // Reminder ID'yi userInfo'ya ekle
        content.userInfo = ["reminderId": reminder.id.uuidString]
        
        // Tarih bileşenlerini al
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: reminder.isRepeating)
        
        let notificationId = reminder.notificationId ?? UUID().uuidString
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                // Notification ID'yi kaydet
                if let index = self.reminders.firstIndex(where: { $0.id == reminder.id }) {
                    var updatedReminder = self.reminders[index]
                    updatedReminder.notificationId = notificationId
                    self.reminders[index] = updatedReminder
                    self.saveReminders()
                }
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: remindersKey)
        }
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: remindersKey),
           let decoded = try? JSONDecoder().decode([Reminder].self, from: data) {
            reminders = decoded
            
            // Tüm bildirimleri yeniden zamanla
            for reminder in reminders where !reminder.isCompleted {
                scheduleNotification(for: reminder)
            }
        }
    }
    
    // MARK: - Auto Reminders
    
    func createFeedingReminder(for baby: Baby, interval: TimeInterval = 3 * 60 * 60) {
        let nextFeedingDate = Date().addingTimeInterval(interval)
        let reminder = Reminder(
            title: "\(baby.name.isEmpty ? "Bebeğiniz" : baby.name) için beslenme zamanı",
            description: "Bebeğinizi besleme zamanı geldi.",
            type: .feeding,
            date: nextFeedingDate,
            isRepeating: true,
            repeatInterval: .daily,
            babyId: baby.id
        )
        addReminder(reminder)
    }
    
    func createVaccineReminder(for baby: Baby, vaccineName: String, date: Date) {
        let reminder = Reminder(
            title: "Aşı Zamanı: \(vaccineName)",
            description: "\(baby.name.isEmpty ? "Bebeğiniz" : baby.name) için \(vaccineName) aşısı zamanı geldi.",
            type: .vaccine,
            date: date,
            babyId: baby.id
        )
        addReminder(reminder)
    }
}

