//
//  NewbornHealthService.swift
//
//  Yenidoğan sağlık takip servisi (SDG 3.2 hedefleri için)
//

import Foundation
import Combine

class NewbornHealthService: ObservableObject {
    @Published var healthRecords: [NewbornHealthRecord] = []
    @Published var screenings: [HealthScreening] = []
    @Published var earlyWarnings: [EarlyWarning] = []
    private let babyId: UUID
    private let birthDate: Date
    
    init(babyId: UUID, birthDate: Date) {
        self.babyId = babyId
        self.birthDate = birthDate
        loadData()
        initializeScreenings()
    }
    
    func initializeScreenings() {
        let calendar = Calendar.current
        screenings = [
            HealthScreening(
                ageInDays: 0,
                screeningType: .newbornExam,
                recommendedDate: birthDate,
                description: "Doğum sonrası ilk muayene - genel sağlık kontrolü"
            ),
            HealthScreening(
                ageInDays: 1,
                screeningType: .hearingTest,
                recommendedDate: calendar.date(byAdding: .day, value: 1, to: birthDate) ?? birthDate,
                description: "Yenidoğan işitme taraması - erken teşhis için kritik"
            ),
            HealthScreening(
                ageInDays: 3,
                screeningType: .metabolicScreening,
                recommendedDate: calendar.date(byAdding: .day, value: 3, to: birthDate) ?? birthDate,
                description: "Guthrie testi - metabolik hastalık taraması"
            ),
            HealthScreening(
                ageInDays: 7,
                screeningType: .hipUltrasound,
                recommendedDate: calendar.date(byAdding: .day, value: 7, to: birthDate) ?? birthDate,
                description: "Kalça displazisi taraması - 1-2. hafta arası"
            ),
            HealthScreening(
                ageInDays: 30,
                screeningType: .eyeExam,
                recommendedDate: calendar.date(byAdding: .day, value: 30, to: birthDate) ?? birthDate,
                description: "Göz muayenesi - görme problemlerinin erken tespiti"
            )
        ]
    }
    
    func addHealthRecord(_ record: NewbornHealthRecord) {
        healthRecords.append(record)
        healthRecords.sort { $0.date > $1.date }
        saveData()
        checkEarlyWarnings()
    }
    
    func checkEarlyWarnings() {
        earlyWarnings.removeAll()
        let ageInDays = Calendar.current.dateComponents([.day], from: birthDate, to: Date()).day ?? 0
        
        // İlk 28 gün kritik dönem (yenidoğan dönemi)
        if ageInDays <= 28 {
            // Ateş kontrolü
            if let latestTemp = getLatestRecord(for: .temperature) {
                if let value = latestTemp.value, value >= 38.0 {
                    earlyWarnings.append(EarlyWarning(
                        type: .fever,
                        severity: .critical,
                        message: "Yenidoğan bebeklerde 38°C üzeri ateş acil durumdur. Derhal doktora başvurun.",
                        recommendation: "112'yi arayın veya acil servise gidin."
                    ))
                }
            }
            
            // Nefes alma kontrolü
            if let latestBreathing = getLatestRecord(for: .breathing) {
                if let value = latestBreathing.value {
                    if value < 30 || value > 60 {
                        earlyWarnings.append(EarlyWarning(
                            type: .breathing,
                            severity: .critical,
                            message: "Nefes alma hızı normal aralık dışında (\(Int(value)) nefes/dakika). Normal: 30-60 nefes/dakika",
                            recommendation: "Derhal doktora başvurun."
                        ))
                    }
                }
            }
            
            // Beslenme kontrolü
            if let latestFeeding = getLatestRecord(for: .feeding) {
                if let value = latestFeeding.value, value < 6 {
                    earlyWarnings.append(EarlyWarning(
                        type: .feeding,
                        severity: .warning,
                        message: "Günlük beslenme sayısı düşük (\(Int(value)) kez). Yenidoğanlar günde en az 8-12 kez beslenmelidir.",
                        recommendation: "Beslenme sıklığını artırın ve doktorunuza danışın."
                    ))
                }
            }
            
            // Ağırlık kaybı kontrolü
            if ageInDays >= 3 {
                if let birthWeight = getBirthWeight(),
                   let currentWeight = getLatestWeight() {
                    let weightLoss = birthWeight - currentWeight
                    let weightLossPercent = (weightLoss / birthWeight) * 100
                    
                    if weightLossPercent > 10 {
                        earlyWarnings.append(EarlyWarning(
                            type: .weightLoss,
                            severity: .critical,
                            message: "Ağırlık kaybı %\(Int(weightLossPercent)) - kritik seviye. Doğum ağırlığının %10'undan fazla kayıp tehlikelidir.",
                            recommendation: "Derhal doktora başvurun."
                        ))
                    } else if weightLossPercent > 7 {
                        earlyWarnings.append(EarlyWarning(
                            type: .weightLoss,
                            severity: .warning,
                            message: "Ağırlık kaybı %\(Int(weightLossPercent)) - dikkat edilmesi gereken seviye.",
                            recommendation: "Beslenmeyi gözlemleyin ve doktorunuza danışın."
                        ))
                    }
                }
            }
        }
        
        // Sarılık kontrolü (ilk 2 hafta)
        if ageInDays <= 14 {
            if let jaundiceRecord = getLatestRecord(for: .jaundice) {
                if jaundiceRecord.status == .critical {
                    earlyWarnings.append(EarlyWarning(
                        type: .jaundice,
                        severity: .critical,
                        message: "Sarılık belirtileri kritik seviyede. Yenidoğan sarılığı ciddi olabilir.",
                        recommendation: "Derhal doktora başvurun."
                    ))
                }
            }
        }
    }
    
    func getLatestRecord(for category: NewbornHealthRecord.HealthCategory) -> NewbornHealthRecord? {
        return healthRecords.filter { $0.category == category }.sorted { $0.date > $1.date }.first
    }
    
    func getBirthWeight() -> Double? {
        // Bu bilgi Baby modelinden alınmalı
        return nil
    }
    
    func getLatestWeight() -> Double? {
        return getLatestRecord(for: .weight)?.value
    }
    
    func getUpcomingScreenings() -> [HealthScreening] {
        let today = Date()
        return screenings.filter { !$0.isCompleted && $0.recommendedDate <= today }
    }
    
    func markScreeningCompleted(_ screening: HealthScreening) {
        if let index = screenings.firstIndex(where: { $0.id == screening.id }) {
            screenings[index].isCompleted = true
        }
    }
    
    func getSDG32Progress() -> SDG32Progress {
        let ageInDays = Calendar.current.dateComponents([.day], from: birthDate, to: Date()).day ?? 0
        let completedScreenings = screenings.filter { $0.isCompleted }.count
        let totalScreenings = screenings.count
        let hasCriticalWarnings = earlyWarnings.contains { $0.severity == .critical }
        
        return SDG32Progress(
            ageInDays: ageInDays,
            completedScreenings: completedScreenings,
            totalScreenings: totalScreenings,
            hasCriticalWarnings: hasCriticalWarnings,
            healthRecordsCount: healthRecords.count
        )
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(healthRecords) {
            UserDefaults.standard.set(encoded, forKey: "newbornHealthRecords_\(babyId.uuidString)")
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "newbornHealthRecords_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([NewbornHealthRecord].self, from: data) {
            healthRecords = decoded.sorted { $0.date > $1.date }
        }
    }
}

struct EarlyWarning {
    let type: WarningType
    let severity: Severity
    let message: String
    let recommendation: String
    
    enum WarningType {
        case fever
        case breathing
        case feeding
        case weightLoss
        case jaundice
        case dehydration
    }
    
    enum Severity {
        case warning
        case critical
    }
}

struct SDG32Progress {
    let ageInDays: Int
    let completedScreenings: Int
    let totalScreenings: Int
    let hasCriticalWarnings: Bool
    let healthRecordsCount: Int
    
    var screeningProgress: Double {
        guard totalScreenings > 0 else { return 0 }
        return Double(completedScreenings) / Double(totalScreenings) * 100
    }
    
    var isOnTrack: Bool {
        return !hasCriticalWarnings && screeningProgress >= 80
    }
}
