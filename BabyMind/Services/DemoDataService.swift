//
//  DemoDataService.swift
//
//  Demo verileri için servis
//

import Foundation

class DemoDataService {
    static let shared = DemoDataService()
    
    private init() {}
    
    func populateDemoData(for babyId: UUID, birthDate: Date, gender: Baby.Gender) {
        let calendar = Calendar.current
        
        // 1. Büyüme Verileri (GrowthPercentileService)
        populateGrowthData(babyId: babyId, birthDate: birthDate, gender: gender)
        
        // 2. Uyku Kayıtları (SleepAnalysisService)
        populateSleepData(babyId: babyId, birthDate: birthDate)
        
        // 3. Gelişimsel Kilometre Taşları (DevelopmentalMilestoneService)
        populateMilestoneData(babyId: babyId, birthDate: birthDate)
        
        // 4. Aktivite Kayıtları (ActivityLogger)
        populateActivityData(babyId: babyId, birthDate: birthDate)
        
        // 5. Aşı ve Bağışıklık (ImmunityService)
        populateImmunityData(babyId: babyId, birthDate: birthDate)
        
        // 6. Vitamin Takviyeleri (VitaminSupplementService)
        populateVitaminData(babyId: babyId, birthDate: birthDate)
        
        // 7. Bağlanma Aktiviteleri (BondingActivityService)
        populateBondingData(babyId: babyId, birthDate: birthDate)
        
        // 8. Rutinler (RoutineService)
        populateRoutineData(babyId: babyId, birthDate: birthDate)
        
        // 9. Güvenlik Kontrol Listesi (SafetyChecklistService)
        populateSafetyData(babyId: babyId)
        
        // 10. Yenidoğan Sağlık (NewbornHealthService)
        populateNewbornHealthData(babyId: babyId, birthDate: birthDate)
        
        // 11. Doğum Sonrası Depresyon (PostpartumDepressionService)
        populatePPDData(babyId: babyId, birthDate: birthDate)
        
        // 12. Beslenme Menü Planı (MealPlanService)
        populateMealPlanData(babyId: babyId, birthDate: birthDate)
        
        // 13. Doktor Randevuları ve Notları
        populateMedicalData(babyId: babyId, birthDate: birthDate)
        
        // 14. İlaç ve Hatırlatıcılar
        populateMedicationData(babyId: babyId, birthDate: birthDate)
        
        print("✅ Demo verileri başarıyla eklendi!")
    }
    
    // MARK: - Büyüme Verileri
    private func populateGrowthData(babyId: UUID, birthDate: Date, gender: Baby.Gender) {
        let service = GrowthPercentileService(babyId: babyId, isMale: gender == .male)
        let calendar = Calendar.current
        
        // Doğum verisi
        let birthRecord = GrowthRecord(
            babyId: babyId,
            date: birthDate,
            weight: gender == .male ? 3.5 : 3.2,
            height: gender == .male ? 50.0 : 49.0,
            headCircumference: gender == .male ? 35.0 : 34.0,
            ageInMonths: 0
        )
        service.addRecord(birthRecord)
        
        // Aylık veriler (son 6 ay)
        for month in 1...6 {
            if let date = calendar.date(byAdding: .month, value: month, to: birthDate) {
                let weight = gender == .male ? 
                    (3.5 + Double(month) * 0.7) : 
                    (3.2 + Double(month) * 0.65)
                let height = gender == .male ?
                    (50.0 + Double(month) * 2.5) :
                    (49.0 + Double(month) * 2.4)
                let hc = gender == .male ?
                    (35.0 + Double(month) * 0.8) :
                    (34.0 + Double(month) * 0.75)
                
                let record = GrowthRecord(
                    babyId: babyId,
                    date: date,
                    weight: weight,
                    height: height,
                    headCircumference: hc,
                    ageInMonths: month
                )
                service.addRecord(record)
            }
        }
    }
    
    // MARK: - Uyku Kayıtları
    private func populateSleepData(babyId: UUID, birthDate: Date) {
        let service = SleepAnalysisService(babyId: babyId)
        let calendar = Calendar.current
        
        // Son 14 gün için uyku kayıtları
        for day in 0..<14 {
            guard let date = calendar.date(byAdding: .day, value: -day, to: Date()) else { continue }
            
            // Gece uykusu
            if let nightStart = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: date),
               let nightEnd = calendar.date(byAdding: .hour, value: 8, to: nightStart) {
                let nightRecord = SleepRecord(
                    babyId: babyId,
                    startTime: nightStart,
                    endTime: nightEnd,
                    sleepType: .night,
                    quality: [.good, .fair, .excellent].randomElement(),
                    wakeCount: Int.random(in: 0...2),
                    notes: nil
                )
                service.addRecord(nightRecord)
            }
            
            // Gündüz uykusu (2-3 kez)
            for nap in 0..<Int.random(in: 2...3) {
                if let napStart = calendar.date(bySettingHour: 10 + nap * 3, minute: 0, second: 0, of: date),
                   let napEnd = calendar.date(byAdding: .hour, value: 1, to: napStart) {
                    let napRecord = SleepRecord(
                        babyId: babyId,
                        startTime: napStart,
                        endTime: napEnd,
                        sleepType: .nap,
                        quality: .good,
                        wakeCount: 0,
                        notes: nil
                    )
                    service.addRecord(napRecord)
                }
            }
        }
    }
    
    // MARK: - Gelişimsel Kilometre Taşları
    private func populateMilestoneData(babyId: UUID, birthDate: Date) {
        let service = DevelopmentalMilestoneService(babyId: babyId)
        let calendar = Calendar.current
        let ageInMonths = calendar.dateComponents([.month], from: birthDate, to: Date()).month ?? 0
        
        // Bazı kilometre taşlarını tamamla
        for milestone in service.milestones {
            if milestone.expectedAgeRange.minMonths <= ageInMonths {
                // %70 ihtimalle tamamlanmış
                if Int.random(in: 0...100) < 70 {
                    let achievedDate = calendar.date(byAdding: .month, value: -Int.random(in: 0...2), to: Date()) ?? Date()
                    service.markMilestoneAchieved(milestone, date: achievedDate, notes: "Demo verisi")
                }
            }
        }
    }
    
    // MARK: - Aktivite Kayıtları
    private func populateActivityData(babyId: UUID, birthDate: Date) {
        let logger = ActivityLogger(babyId: babyId)
        let calendar = Calendar.current
        
        // Son 7 gün için aktiviteler
        for day in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -day, to: Date()) else { continue }
            
            // Beslenme (günde 6-8 kez)
            for _ in 0..<Int.random(in: 6...8) {
                let feedingDate = calendar.date(byAdding: .minute, value: Int.random(in: 0...1440), to: date) ?? date
                let feedingLog = ActivityLog(
                    type: .feeding,
                    date: feedingDate,
                    amount: Double.random(in: 100...200),
                    notes: nil
                )
                logger.addLog(feedingLog)
            }
            
            // Bez değişimi (günde 6-10 kez)
            for _ in 0..<Int.random(in: 6...10) {
                let diaperDate = calendar.date(byAdding: .minute, value: Int.random(in: 0...1440), to: date) ?? date
                let isWet = Bool.random()
                let isDirty = Bool.random()
                let diaperLog = ActivityLog(
                    type: .diaper,
                    date: diaperDate,
                    notes: "\(isWet ? "Islak" : "") \(isDirty ? "Kirli" : "")".trimmingCharacters(in: .whitespaces)
                )
                logger.addLog(diaperLog)
            }
        }
    }
    
    // MARK: - Bağışıklık Verileri
    private func populateImmunityData(babyId: UUID, birthDate: Date) {
        let service = ImmunityService(babyId: babyId)
        let calendar = Calendar.current
        
        // Bazı aşıları tamamla
        let completedVaccinations = ["BCG", "Hepatit B", "KPA (Pnömokok)", "Beşli Karma", "Rotavirüs"]
        for vaccination in service.vaccinationSchedule {
            if completedVaccinations.contains(vaccination.name) && !vaccination.isCompleted {
                // Önerilen yaşa göre tamamlanma tarihi hesapla
                let ageString = vaccination.recommendedAge.lowercased()
                var daysToAdd = 0
                if ageString.contains("doğum") {
                    daysToAdd = 0
                } else if let month = extractMonth(from: ageString) {
                    daysToAdd = month * 30
                }
                let completedDate = calendar.date(byAdding: .day, value: daysToAdd, to: birthDate) ?? Date()
                service.markVaccinationCompleted(vaccination, date: completedDate)
            }
        }
        
        // Bir hastalık kaydı ekle
        if let illnessDate = calendar.date(byAdding: .month, value: -2, to: Date()) {
            let illness = ImmunityRecord(
                babyId: babyId,
                date: illnessDate,
                type: .illness,
                details: "Soğuk algınlığı",
                severity: .mild,
                notes: "Hafif ateş, burun akıntısı. 3 gün sürdü."
            )
            service.addRecord(illness)
        }
    }
    
    // MARK: - Vitamin Takviyeleri
    private func populateVitaminData(babyId: UUID, birthDate: Date) {
        let service = VitaminSupplementService(babyId: babyId)
        let calendar = Calendar.current
        
        // D Vitamini
        let vitaminD = VitaminSupplement(
            babyId: babyId,
            name: "D Vitamini",
            type: .vitaminD,
            dosage: "400 IU",
            frequency: .daily,
            startDate: calendar.date(byAdding: .day, value: 7, to: birthDate) ?? birthDate,
            notes: "Doktor önerisi ile"
        )
        service.addSupplement(vitaminD)
        
        // Demir (4 ay sonra)
        if let ironDate = calendar.date(byAdding: .month, value: 4, to: birthDate) {
            let iron = VitaminSupplement(
                babyId: babyId,
                name: "Demir Takviyesi",
                type: .iron,
                dosage: "1 ml",
                frequency: .daily,
                startDate: ironDate,
                notes: "4. aydan itibaren"
            )
            service.addSupplement(iron)
        }
    }
    
    // MARK: - Bağlanma Aktiviteleri
    private func populateBondingData(babyId: UUID, birthDate: Date) {
        let service = BondingActivityService(babyId: babyId)
        let calendar = Calendar.current
        
        // Son 14 gün için aktiviteler
        for day in 0..<14 {
            guard let date = calendar.date(byAdding: .day, value: -day, to: Date()) else { continue }
            
            // Her gün 2-3 aktivite
            let activities: [BondingActivity.ActivityType] = [
                .play, .massage, .reading, .music, .skinToSkin, .talking, .cuddling
            ]
            
            for _ in 0..<Int.random(in: 2...3) {
                let activityType = activities.randomElement() ?? .play
                let activityDate = calendar.date(byAdding: .minute, value: Int.random(in: 0...1440), to: date) ?? date
                
                let activity = BondingActivity(
                    babyId: babyId,
                    activityType: activityType,
                    date: activityDate,
                    duration: TimeInterval(Int.random(in: 10...30) * 60),
                    notes: "Demo aktivite",
                    isCompleted: true
                )
                service.addActivity(activity)
            }
        }
    }
    
    // MARK: - Rutinler
    private func populateRoutineData(babyId: UUID, birthDate: Date) {
        let service = RoutineService(babyId: babyId)
        let calendar = Calendar.current
        
        // Bugün için rutinler
        let today = Date()
        
        // Uyku rutinleri
        if let sleepTime = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today) {
            let sleepRoutine = Routine(
                babyId: babyId,
                type: .sleep,
                time: sleepTime,
                isCompleted: true,
                completionDate: sleepTime
            )
            service.addRoutine(sleepRoutine)
        }
        
        // Beslenme rutinleri (günde 6 kez)
        let feedingHours = [7, 10, 13, 16, 19, 22]
        for hour in feedingHours {
            if let feedingTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: today) {
                let feedingRoutine = Routine(
                    babyId: babyId,
                    type: .feeding,
                    time: feedingTime,
                    isCompleted: hour <= calendar.component(.hour, from: Date()),
                    completionDate: hour <= calendar.component(.hour, from: Date()) ? feedingTime : nil
                )
                service.addRoutine(feedingRoutine)
            }
        }
    }
    
    // MARK: - Güvenlik Kontrol Listesi
    private func populateSafetyData(babyId: UUID) {
        let service = SafetyChecklistService(babyId: babyId)
        
        // %80'i tamamla
        for item in service.checklistItems {
            if Int.random(in: 0...100) < 80 {
                service.toggleItem(item)
            }
        }
    }
    
    // MARK: - Yenidoğan Sağlık
    private func populateNewbornHealthData(babyId: UUID, birthDate: Date) {
        let service = NewbornHealthService(babyId: babyId, birthDate: birthDate)
        let calendar = Calendar.current
        let ageInDays = calendar.dateComponents([.day], from: birthDate, to: Date()).day ?? 0
        
        // İlk 28 gün için kayıtlar
        if ageInDays <= 28 {
            for day in 0..<min(ageInDays, 14) {
                guard let date = calendar.date(byAdding: .day, value: -day, to: Date()) else { continue }
                
                // Ateş
                let temp = Double.random(in: 36.5...37.2)
                let tempRecord = NewbornHealthRecord(
                    babyId: babyId,
                    date: date,
                    ageInDays: ageInDays - day,
                    category: .temperature,
                    value: temp,
                    status: temp < 37.5 ? .normal : .warning
                )
                service.addHealthRecord(tempRecord)
                
                // Beslenme
                let feedingCount = Double.random(in: 8...12)
                let feedingRecord = NewbornHealthRecord(
                    babyId: babyId,
                    date: date,
                    ageInDays: ageInDays - day,
                    category: .feeding,
                    value: feedingCount,
                    status: feedingCount >= 8 ? .normal : .warning
                )
                service.addHealthRecord(feedingRecord)
                
                // Nefes alma
                let breathing = Double.random(in: 35...55)
                let breathingRecord = NewbornHealthRecord(
                    babyId: babyId,
                    date: date,
                    ageInDays: ageInDays - day,
                    category: .breathing,
                    value: breathing,
                    status: (breathing >= 30 && breathing <= 60) ? .normal : .critical
                )
                service.addHealthRecord(breathingRecord)
            }
            
            // İlk 3 taramayı tamamla
            for (index, screening) in service.screenings.enumerated() {
                if index < 3 {
                    service.markScreeningCompleted(screening)
                }
            }
        }
    }
    
    // MARK: - Doğum Sonrası Depresyon
    private func populatePPDData(babyId: UUID, birthDate: Date) {
        let service = PostpartumDepressionService(babyId: babyId)
        let calendar = Calendar.current
        
        // Son 14 gün için check-in'ler
        for day in 0..<14 {
            guard let date = calendar.date(byAdding: .day, value: -day, to: Date()) else { continue }
            
            // İyileşen trend (başlangıçta düşük, sonra yükselen)
            let baseMood = 3 + (14 - day) / 5
            let mood = min(5, max(1, baseMood + Int.random(in: -1...1)))
            
            let record = PostpartumDepressionRecord(
                babyId: babyId,
                date: date,
                moodScore: mood,
                sleepHours: Double.random(in: 6...8),
                cryingUrge: max(1, mood - 2),
                anxietyLevel: max(1, mood - 1),
                hopelessnessLevel: max(1, mood - 2),
                socialSupport: min(5, mood + 1),
                notes: day == 0 ? "Bugün daha iyi hissediyorum" : nil
            )
            service.addRecord(record)
        }
    }
    
    // MARK: - Beslenme Menü Planı
    private func populateMealPlanData(babyId: UUID, birthDate: Date) {
        let service = MealPlanService(babyId: babyId)
        let calendar = Calendar.current
        let ageInMonths = calendar.dateComponents([.month], from: birthDate, to: Date()).month ?? 0
        
        if ageInMonths >= 4 {
            // Bu hafta için menü planı oluştur
            let mealPlan = service.generateWeeklyMealPlan(ageInMonths: ageInMonths)
            service.addMealPlan(mealPlan)
        }
    }
    
    // MARK: - Tıbbi Veriler
    private func populateMedicalData(babyId: UUID, birthDate: Date) {
        let calendar = Calendar.current
        
        // Doktor Randevuları
        let appointmentService = DoctorAppointmentService(reminderService: ReminderService.shared)
        
        // Geçmiş randevu
        if let pastDate = calendar.date(byAdding: .month, value: -1, to: Date()) {
            let pastAppointment = DoctorAppointment(
                doctorName: "Dr. Ayşe Yılmaz",
                specialty: "Çocuk Doktoru",
                clinicName: "Çocuk Sağlığı Merkezi",
                address: "İstanbul",
                phoneNumber: "0212 123 45 67",
                date: pastDate,
                notes: "Rutin kontrol. Her şey normal.",
                isCompleted: true,
                babyId: babyId
            )
            appointmentService.addAppointment(pastAppointment, createReminder: false)
        }
        
        // Gelecek randevu
        if let futureDate = calendar.date(byAdding: .month, value: 1, to: Date()) {
            let futureAppointment = DoctorAppointment(
                doctorName: "Dr. Ayşe Yılmaz",
                specialty: "Çocuk Doktoru",
                clinicName: "Çocuk Sağlığı Merkezi",
                address: "İstanbul",
                phoneNumber: "0212 123 45 67",
                date: futureDate,
                notes: "6. ay kontrolü ve aşı",
                isCompleted: false,
                babyId: babyId
            )
            appointmentService.addAppointment(futureAppointment, createReminder: false)
        }
        
        // Doktor Notları
        let noteService = DoctorNoteService(babyId: babyId)
        if let noteDate = calendar.date(byAdding: .month, value: -1, to: Date()) {
            let note = DoctorNote(
                babyId: babyId,
                date: noteDate,
                doctorName: "Dr. Ayşe Yılmaz",
                specialty: "Çocuk Doktoru",
                reason: "Rutin Kontrol",
                diagnosis: nil,
                notes: "Bebek sağlıklı gelişiyor. Ağırlık ve boy normal aralıkta. Beslenme düzeni iyi.",
                recommendations: ["Düzenli beslenmeye devam edin", "Aşı takvimini takip edin"]
            )
            noteService.addNote(note)
        }
    }
    
    // MARK: - İlaç ve Hatırlatıcılar
    private func populateMedicationData(babyId: UUID, birthDate: Date) {
        let calendar = Calendar.current
        
        // İlaç Kayıtları
        let medicationService = MedicationService(babyId: babyId)
        
        if let medDate = calendar.date(byAdding: .day, value: -5, to: Date()) {
            let medication = Medication(
                babyId: babyId,
                name: "Parasetamol",
                dosage: "2.5 ml",
                frequency: .asNeeded,
                startDate: medDate,
                endDate: calendar.date(byAdding: .day, value: 3, to: medDate),
                notes: "Ateş için",
                isActive: false
            )
            medicationService.addMedication(medication)
        }
        
        // Aktif ilaç
        let activeMedication = Medication(
            babyId: babyId,
            name: "D Vitamini Damlası",
            dosage: "400 IU",
            frequency: .once,
            startDate: calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
            notes: "Günlük kullanım",
            isActive: true
        )
        medicationService.addMedication(activeMedication)
        
        // Hatırlatıcılar
        let reminderService = ReminderService.shared
        
        // Beslenme hatırlatıcısı
        let feedingReminder = Reminder(
            title: "Beslenme Zamanı",
            description: "Bebeğinizi besleme zamanı",
            type: .feeding,
            date: calendar.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
            babyId: babyId
        )
        reminderService.addReminder(feedingReminder)
        
        // İlaç hatırlatıcısı
        let medicineReminder = Reminder(
            title: "D Vitamini",
            description: "400 IU",
            type: .medicine,
            date: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date(),
            babyId: babyId
        )
        reminderService.addReminder(medicineReminder)
    }
    
    private func extractMonth(from text: String) -> Int? {
        let numbers = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(numbers)
    }
}
