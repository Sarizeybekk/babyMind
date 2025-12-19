//
//  Reminder.swift
//  BabyMind
//
//  Hatırlatıcı modeli
//

import Foundation

struct Reminder: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var type: ReminderType
    var date: Date
    var isCompleted: Bool
    var isRepeating: Bool
    var repeatInterval: RepeatInterval?
    var babyId: UUID
    var notificationId: String?
    
    enum ReminderType: String, Codable, CaseIterable {
        case feeding = "Beslenme"
        case vaccine = "Aşı"
        case doctor = "Doktor Randevusu"
        case medicine = "İlaç"
        case sleep = "Uyku"
        case activity = "Aktivite"
        case other = "Diğer"
        
        var icon: String {
            switch self {
            case .feeding: return "fork.knife"
            case .vaccine: return "syringe"
            case .doctor: return "stethoscope"
            case .medicine: return "pills"
            case .sleep: return "bed.double"
            case .activity: return "figure.walk"
            case .other: return "bell"
            }
        }
    }
    
    enum RepeatInterval: String, Codable, CaseIterable {
        case daily = "Günlük"
        case weekly = "Haftalık"
        case monthly = "Aylık"
        case custom = "Özel"
        
        var calendarComponent: Calendar.Component {
            switch self {
            case .daily: return .day
            case .weekly: return .weekOfYear
            case .monthly: return .month
            case .custom: return .day
            }
        }
    }
    
    init(id: UUID = UUID(),
         title: String,
         description: String = "",
         type: ReminderType,
         date: Date,
         isCompleted: Bool = false,
         isRepeating: Bool = false,
         repeatInterval: RepeatInterval? = nil,
         babyId: UUID,
         notificationId: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.date = date
        self.isCompleted = isCompleted
        self.isRepeating = isRepeating
        self.repeatInterval = repeatInterval
        self.babyId = babyId
        self.notificationId = notificationId
    }
    
    var nextDate: Date? {
        guard isRepeating, let interval = repeatInterval else { return nil }
        let calendar = Calendar.current
        return calendar.date(byAdding: interval.calendarComponent, value: 1, to: date)
    }
}

