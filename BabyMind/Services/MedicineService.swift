//
//  MedicineService.swift
//  BabyMind
//
//  İlaç yönetim servisi
//

import Foundation
import Combine

class MedicineService: ObservableObject {
    @Published var medicines: [Medicine] = []
    
    private let medicinesKey = "savedMedicines"
    private let reminderService: ReminderService
    
    init(reminderService: ReminderService) {
        self.reminderService = reminderService
        loadMedicines()
    }
    
    func addMedicine(_ medicine: Medicine, createReminders: Bool = true) {
        var newMedicine = medicine
        
        // Hatırlatıcılar oluştur
        if createReminders && medicine.isActive {
            let reminderIds = createMedicineReminders(for: medicine)
            newMedicine.reminderIds = reminderIds
        }
        
        medicines.append(newMedicine)
        saveMedicines()
    }
    
    func updateMedicine(_ medicine: Medicine) {
        if let index = medicines.firstIndex(where: { $0.id == medicine.id }) {
            let oldMedicine = medicines[index]
            
            // Eski hatırlatıcıları sil
            for reminderId in oldMedicine.reminderIds {
                if let reminder = reminderService.reminders.first(where: { $0.id == reminderId }) {
                    reminderService.deleteReminder(reminder)
                }
            }
            
            // Yeni hatırlatıcılar oluştur
            var updatedMedicine = medicine
            if medicine.isActive {
                let reminderIds = createMedicineReminders(for: medicine)
                updatedMedicine.reminderIds = reminderIds
            } else {
                updatedMedicine.reminderIds = []
            }
            
            medicines[index] = updatedMedicine
            saveMedicines()
        }
    }
    
    func deleteMedicine(_ medicine: Medicine) {
        // İlişkili hatırlatıcıları sil
        for reminderId in medicine.reminderIds {
            if let reminder = reminderService.reminders.first(where: { $0.id == reminderId }) {
                reminderService.deleteReminder(reminder)
            }
        }
        
        medicines.removeAll { $0.id == medicine.id }
        saveMedicines()
    }
    
    private func createMedicineReminders(for medicine: Medicine) -> [UUID] {
        var reminderIds: [UUID] = []
        let calendar = Calendar.current
        
        // İlk doz zamanını belirle
        var currentDate = medicine.startDate
        
        // Günlük doz sayısına göre hatırlatıcılar oluştur
        let timesPerDay = medicine.frequency.timesPerDay
        
        if let intervalHours = medicine.frequency.intervalHours {
            // Belirli saat aralıklarıyla (6, 8, 12 saat)
            var date = currentDate
            for _ in 0..<timesPerDay {
                let reminder = Reminder(
                    title: "İlaç Zamanı: \(medicine.name)",
                    description: "Dozaj: \(medicine.dosage)",
                    type: .medicine,
                    date: date,
                    isRepeating: true,
                    repeatInterval: .daily,
                    babyId: medicine.babyId
                )
                reminderService.addReminder(reminder)
                reminderIds.append(reminder.id)
                date = calendar.date(byAdding: .hour, value: intervalHours, to: date) ?? date
            }
        } else {
            // Günlük belirli saatlerde (1, 2, 3, 4 kez)
            let hours = getDefaultHours(for: timesPerDay)
            for hour in hours {
                var components = calendar.dateComponents([.year, .month, .day], from: currentDate)
                components.hour = hour
                components.minute = 0
                
                if let date = calendar.date(from: components) {
                    let reminder = Reminder(
                        title: "İlaç Zamanı: \(medicine.name)",
                        description: "Dozaj: \(medicine.dosage)",
                        type: .medicine,
                        date: date,
                        isRepeating: true,
                        repeatInterval: .daily,
                        babyId: medicine.babyId
                    )
                    reminderService.addReminder(reminder)
                    reminderIds.append(reminder.id)
                }
            }
        }
        
        return reminderIds
    }
    
    private func getDefaultHours(for timesPerDay: Int) -> [Int] {
        switch timesPerDay {
        case 1: return [10] // Sabah 10:00
        case 2: return [9, 21] // Sabah 9:00, Akşam 21:00
        case 3: return [8, 14, 20] // Sabah 8:00, Öğle 14:00, Akşam 20:00
        case 4: return [8, 12, 16, 20] // Sabah 8:00, Öğle 12:00, Öğleden sonra 16:00, Akşam 20:00
        default: return [10]
        }
    }
    
    func medicines(for babyId: UUID) -> [Medicine] {
        medicines.filter { $0.babyId == babyId }
    }
    
    func activeMedicines(for babyId: UUID) -> [Medicine] {
        medicines(for: babyId).filter { $0.isActive && !$0.isExpired }
    }
    
    private func saveMedicines() {
        if let encoded = try? JSONEncoder().encode(medicines) {
            UserDefaults.standard.set(encoded, forKey: medicinesKey)
        }
    }
    
    private func loadMedicines() {
        if let data = UserDefaults.standard.data(forKey: medicinesKey),
           let decoded = try? JSONDecoder().decode([Medicine].self, from: data) {
            medicines = decoded
        }
    }
}

