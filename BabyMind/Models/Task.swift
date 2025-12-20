//
//  Task.swift
//
//  Görev modeli
//

import Foundation

struct Task: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let title: String
    let description: String
    let category: TaskCategory
    let type: TaskType
    let priority: Priority
    let points: Int // Tamamlandığında kazanılan puan
    let createdAt: Date
    var completedAt: Date?
    var isCompleted: Bool
    var reminderDate: Date? // Bildirim gönderilecek tarih
    var relatedData: [String: String]? // İlgili veri bilgileri (örn: "recordType": "feeding")
    
    enum TaskCategory: String, Codable, CaseIterable {
        case daily = "Günlük Görevler"
        case health = "Sağlık Takibi"
        case development = "Gelişim"
        case feeding = "Beslenme"
        case sleep = "Uyku"
        case milestone = "Kilometre Taşları"
        case vaccination = "Aşı"
        case checkup = "Kontrol"
        
        var icon: String {
            switch self {
            case .daily: return "checkmark.circle.fill"
            case .health: return "heart.text.square.fill"
            case .development: return "chart.line.uptrend.xyaxis"
            case .feeding: return "fork.knife"
            case .sleep: return "bed.double.fill"
            case .milestone: return "star.fill"
            case .vaccination: return "syringe"
            case .checkup: return "stethoscope"
            }
        }
        
        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .daily: return (0.2, 0.6, 0.9)
            case .health: return (1.0, 0.3, 0.3)
            case .development: return (0.3, 0.7, 0.4)
            case .feeding: return (1.0, 0.7, 0.3)
            case .sleep: return (0.5, 0.4, 0.9)
            case .milestone: return (1.0, 0.8, 0.2)
            case .vaccination: return (0.2, 0.8, 0.5)
            case .checkup: return (0.6, 0.4, 0.9)
            }
        }
    }
    
    enum TaskType: String, Codable {
        case recordFeeding = "Beslenme Kaydı"
        case recordSleep = "Uyku Kaydı"
        case recordGrowth = "Büyüme Kaydı"
        case recordActivity = "Aktivite Kaydı"
        case markMilestone = "Kilometre Taşı İşaretle"
        case addVaccination = "Aşı Kaydı"
        case checkIn = "Check-in"
        case addNote = "Not Ekle"
        case completeRoutine = "Rutin Tamamla"
        case addMedication = "İlaç Kaydı"
        case scheduleAppointment = "Randevu Planla"
        case completeScreening = "Tarama Tamamla"
    }
    
    enum Priority: String, Codable {
        case low = "Düşük"
        case medium = "Orta"
        case high = "Yüksek"
        case critical = "Kritik"
        
        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .low: return (0.6, 0.6, 0.6)
            case .medium: return (1.0, 0.7, 0.3)
            case .high: return (1.0, 0.5, 0.2)
            case .critical: return (1.0, 0.2, 0.2)
            }
        }
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         title: String,
         description: String,
         category: TaskCategory,
         type: TaskType,
         priority: Priority = .medium,
         points: Int = 10,
         createdAt: Date = Date(),
         completedAt: Date? = nil,
         isCompleted: Bool = false,
         reminderDate: Date? = nil,
         relatedData: [String: String]? = nil) {
        self.id = id
        self.babyId = babyId
        self.title = title
        self.description = description
        self.category = category
        self.type = type
        self.priority = priority
        self.points = points
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.isCompleted = isCompleted
        self.reminderDate = reminderDate
        self.relatedData = relatedData
    }
}

struct UserProgress: Codable {
    var totalPoints: Int
    var completedTasks: Int
    var streakDays: Int // Ardışık gün sayısı
    var lastCompletedDate: Date?
    var achievements: [String] // Başarılar
    var level: Int // Kullanıcı seviyesi
    
    init() {
        self.totalPoints = 0
        self.completedTasks = 0
        self.streakDays = 0
        self.lastCompletedDate = nil
        self.achievements = []
        self.level = 1
    }
}
