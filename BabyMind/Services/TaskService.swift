//
//  TaskService.swift
//
//  Görev yönetim servisi
//

import Foundation
import Combine
import UserNotifications
import UIKit

class TaskService: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var userProgress: UserProgress = UserProgress()
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadData()
        requestNotificationPermission()
    }
    
    func generateDailyTasks(for baby: Baby) {
        let calendar = Calendar.current
        let today = Date()
        
        // Bugün için görevler oluştur
        var newTasks: [Task] = []
        
        // Günlük görevler
        newTasks.append(Task(
            babyId: babyId,
            title: "Bugünün Beslenme Kayıtlarını Gir",
            description: "Bebeğinizin bugünkü beslenme kayıtlarını ekleyin",
            category: .feeding,
            type: .recordFeeding,
            priority: .high,
            points: 15,
            reminderDate: calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today)
        ))
        
        newTasks.append(Task(
            babyId: babyId,
            title: "Uyku Kayıtlarını Güncelle",
            description: "Bebeğinizin uyku saatlerini kaydedin",
            category: .sleep,
            type: .recordSleep,
            priority: .medium,
            points: 10,
            reminderDate: calendar.date(bySettingHour: 21, minute: 0, second: 0, of: today)
        ))
        
        // Haftalık görevler (haftanın belirli günleri)
        let weekday = calendar.component(.weekday, from: today)
        
        if weekday == 2 { // Pazartesi
            newTasks.append(Task(
                babyId: babyId,
                title: "Bu Haftanın Büyüme Kaydını Ekle",
                description: "Bebeğinizin ağırlık ve boy ölçümlerini kaydedin",
                category: .health,
                type: .recordGrowth,
                priority: .medium,
                points: 20
            ))
        }
        
        // Yaşa göre görevler
        if baby.ageInMonths < 6 {
            newTasks.append(Task(
                babyId: babyId,
                title: "Günlük Sağlık Kontrolü",
                description: "Bebeğinizin genel sağlık durumunu kontrol edin",
                category: .health,
                type: .checkIn,
                priority: .high,
                points: 15
            ))
        }
        
        if baby.ageInMonths >= 4 && baby.ageInMonths < 12 {
            newTasks.append(Task(
                babyId: babyId,
                title: "Yeni Kilometre Taşı İşaretle",
                description: "Bebeğinizin yeni bir gelişim aşamasını kaydedin",
                category: .milestone,
                type: .markMilestone,
                priority: .medium,
                points: 25
            ))
        }
        
        // Aşı görevleri (aylık kontrol)
        if weekday == 1 { // Pazar - haftalık aşı kontrolü
            newTasks.append(Task(
                babyId: babyId,
                title: "Aşı Takvimini Kontrol Et",
                description: "Yaklaşan aşıları kontrol edin",
                category: .vaccination,
                type: .addVaccination,
                priority: .high,
                points: 20
            ))
        }
        
        // Rutin görevler
        newTasks.append(Task(
            babyId: babyId,
            title: "Günlük Rutinleri Tamamla",
            description: "Beslenme ve uyku rutinlerini takip edin",
            category: .daily,
            type: .completeRoutine,
            priority: .medium,
            points: 10
        ))
        
        // Bugün için görevleri ekle (daha önce eklenmemişse)
        for task in newTasks {
            if !tasks.contains(where: { $0.title == task.title && calendar.isDate($0.createdAt, inSameDayAs: today) }) {
                tasks.append(task)
                scheduleNotification(for: task)
            }
        }
        
        saveData()
    }
    
    func completeTask(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        
        var updatedTask = task
        updatedTask.isCompleted = true
        updatedTask.completedAt = Date()
        tasks[index] = updatedTask
        
        // İlerlemeyi güncelle
        updateProgress(completedTask: updatedTask)
        
        // Motivasyon mesajı gönder
        sendMotivationalMessage(for: updatedTask)
        
        // Streak kontrolü
        updateStreak()
        
        saveData()
        HapticManager.shared.impact(style: .medium)
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveData()
    }
    
    func getTodayTasks() -> [Task] {
        let calendar = Calendar.current
        let today = Date()
        return tasks.filter { task in
            calendar.isDate(task.createdAt, inSameDayAs: today)
        }
    }
    
    func getPendingTasks() -> [Task] {
        return tasks.filter { !$0.isCompleted }
            .sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    func getCompletedTasks() -> [Task] {
        return tasks.filter { $0.isCompleted }
            .sorted { ($0.completedAt ?? Date()) > ($1.completedAt ?? Date()) }
    }
    
    private func updateProgress(completedTask: Task) {
        userProgress.totalPoints += completedTask.points
        userProgress.completedTasks += 1
        userProgress.lastCompletedDate = Date()
        
        // Seviye hesaplama (her 100 puan = 1 seviye)
        userProgress.level = (userProgress.totalPoints / 100) + 1
        
        // Başarı kontrolü
        checkAchievements()
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        guard let lastDate = userProgress.lastCompletedDate else {
            userProgress.streakDays = 1
            return
        }
        
        if calendar.isDateInToday(lastDate) {
            // Bugün zaten tamamlanmış
            return
        }
        
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()),
           calendar.isDate(lastDate, inSameDayAs: yesterday) {
            // Dün tamamlanmış, streak devam ediyor
            userProgress.streakDays += 1
        } else {
            // Streak kırıldı
            userProgress.streakDays = 1
        }
    }
    
    private func checkAchievements() {
        var newAchievements: [String] = []
        
        // İlk görev
        if userProgress.completedTasks == 1 && !userProgress.achievements.contains("İlk Adım") {
            newAchievements.append("İlk Adım")
        }
        
        // 10 görev
        if userProgress.completedTasks == 10 && !userProgress.achievements.contains("10 Görev") {
            newAchievements.append("10 Görev")
        }
        
        // 7 gün streak
        if userProgress.streakDays == 7 && !userProgress.achievements.contains("7 Gün Streak") {
            newAchievements.append("7 Gün Streak")
        }
        
        // 30 gün streak
        if userProgress.streakDays == 30 && !userProgress.achievements.contains("30 Gün Streak") {
            newAchievements.append("30 Gün Streak")
        }
        
        // 100 puan
        if userProgress.totalPoints >= 100 && !userProgress.achievements.contains("100 Puan") {
            newAchievements.append("100 Puan")
        }
        
        userProgress.achievements.append(contentsOf: newAchievements)
        
        // Yeni başarılar için bildirim
        for achievement in newAchievements {
            sendAchievementNotification(achievement: achievement)
        }
    }
    
    private func sendMotivationalMessage(for task: Task) {
        let messages = [
            "Harika! İyi bir annesin! 🌟",
            "Müthiş! Bebeğin için çok iyi bir şey yaptın! 💪",
            "Süpersin! Devam et! 🎉",
            "Harika iş çıkardın! Bebeğin çok şanslı! 👏",
            "Mükemmel! Sen gerçekten harika bir annesin! ⭐",
            "Bravo! Her gün daha iyi oluyorsun! 🌈",
            "Süper! Bebeğin için en iyisini yapıyorsun! 💖",
            "Harika! Sen gerçek bir süper annesin! 🦸‍♀️",
            "Müthiş! Bebeğin için mükemmel bir iş yaptın! 🎊",
            "Süpersin! Devam et, çok iyi gidiyorsun! 🚀"
        ]
        
        let message = messages.randomElement() ?? "Harika iş!"
        
        // Bildirim gönder
        sendLocalNotification(
            title: "Görev Tamamlandı! 🎉",
            body: message,
            identifier: "task_completed_\(task.id.uuidString)"
        )
    }
    
    private func sendAchievementNotification(achievement: String) {
        sendLocalNotification(
            title: "Başarı Kazandın! 🏆",
            body: "\(achievement) başarısını kazandın! Sen gerçekten harika bir annesin!",
            identifier: "achievement_\(achievement)"
        )
    }
    
    private func scheduleNotification(for task: Task) {
        guard let reminderDate = task.reminderDate,
              reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Görev Hatırlatıcısı 📋"
        content.body = task.title
        content.sound = .default
        content.badge = NSNumber(value: getPendingTasks().count)
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "task_reminder_\(task.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func sendLocalNotification(title: String, body: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = NSNumber(value: getPendingTasks().count)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                print("✅ Bildirim izni verildi")
            }
        }
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks_\(babyId.uuidString)")
        }
        if let encoded = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(encoded, forKey: "userProgress_\(babyId.uuidString)")
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "tasks_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "userProgress_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode(UserProgress.self, from: data) {
            userProgress = decoded
        }
    }
}


