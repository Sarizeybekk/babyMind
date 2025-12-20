//
//  ImmunityService.swift
//
//  Bağışıklık sistemi takip servisi
//

import Foundation
import Combine

class ImmunityService: ObservableObject {
    @Published var records: [ImmunityRecord] = []
    @Published var vaccinationSchedule: [VaccinationSchedule] = []
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadData()
        if vaccinationSchedule.isEmpty {
            initializeVaccinationSchedule()
        }
    }
    
    func initializeVaccinationSchedule() {
        vaccinationSchedule = [
            VaccinationSchedule(name: "BCG", recommendedAge: "Doğumda", doses: ["1 doz"]),
            VaccinationSchedule(name: "Hepatit B", recommendedAge: "Doğumda", doses: ["1. doz"]),
            VaccinationSchedule(name: "KPA (Pnömokok)", recommendedAge: "2. ay", doses: ["1. doz"]),
            VaccinationSchedule(name: "Beşli Karma", recommendedAge: "2. ay", doses: ["1. doz"]),
            VaccinationSchedule(name: "Rotavirüs", recommendedAge: "2. ay", doses: ["1. doz"]),
            VaccinationSchedule(name: "KPA (Pnömokok)", recommendedAge: "4. ay", doses: ["2. doz"]),
            VaccinationSchedule(name: "Beşli Karma", recommendedAge: "4. ay", doses: ["2. doz"]),
            VaccinationSchedule(name: "Rotavirüs", recommendedAge: "4. ay", doses: ["2. doz"]),
            VaccinationSchedule(name: "KPA (Pnömokok)", recommendedAge: "6. ay", doses: ["3. doz"]),
            VaccinationSchedule(name: "Beşli Karma", recommendedAge: "6. ay", doses: ["3. doz"]),
            VaccinationSchedule(name: "KKK (Kızamık, Kızamıkçık, Kabakulak)", recommendedAge: "12. ay", doses: ["1. doz"]),
            VaccinationSchedule(name: "Suçiçeği", recommendedAge: "12. ay", doses: ["1. doz"])
        ]
        saveData()
    }
    
    func addRecord(_ record: ImmunityRecord) {
        records.append(record)
        records.sort { $0.date > $1.date }
        saveData()
    }
    
    func deleteRecord(_ record: ImmunityRecord) {
        records.removeAll { $0.id == record.id }
        saveData()
    }
    
    func markVaccinationCompleted(_ vaccination: VaccinationSchedule, date: Date = Date()) {
        if let index = vaccinationSchedule.firstIndex(where: { $0.name == vaccination.name }) {
            let updated = VaccinationSchedule(
                name: vaccination.name,
                recommendedAge: vaccination.recommendedAge,
                doses: vaccination.doses,
                isCompleted: true,
                completedDate: date
            )
            vaccinationSchedule[index] = updated
            saveData()
        }
    }
    
    func getUpcomingVaccinations(ageInMonths: Int) -> [VaccinationSchedule] {
        return vaccinationSchedule.filter { !$0.isCompleted && isVaccinationDue($0, ageInMonths: ageInMonths) }
    }
    
    func getIllnessHistory() -> [ImmunityRecord] {
        return records.filter { $0.type == .illness }.sorted { $0.date > $1.date }
    }
    
    func getSeasonalRecommendations() -> [String] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        
        var recommendations: [String] = []
        
        // Kış ayları (Aralık, Ocak, Şubat)
        if month == 12 || month <= 2 {
            recommendations.append("Kış aylarında grip ve soğuk algınlığı riski yüksek. Bebeğinizi sıcak tutun.")
            recommendations.append("Kapalı ortamlarda havalandırmaya dikkat edin.")
        }
        
        // İlkbahar (Mart, Nisan, Mayıs)
        if month >= 3 && month <= 5 {
            recommendations.append("İlkbahar alerjileri başlayabilir. Polen takibi yapın.")
            recommendations.append("Güneş ışığından faydalanın (D vitamini için).")
        }
        
        // Yaz (Haziran, Temmuz, Ağustos)
        if month >= 6 && month <= 8 {
            recommendations.append("Yaz aylarında güneş koruması önemli. SPF 50+ kullanın.")
            recommendations.append("Sıcak havalarda sıvı alımını artırın.")
            recommendations.append("Sivrisinek ve böcek ısırıklarına dikkat edin.")
        }
        
        // Sonbahar (Eylül, Ekim, Kasım)
        if month >= 9 && month <= 11 {
            recommendations.append("Sonbahar mevsim geçişi. Hava değişimlerine dikkat edin.")
            recommendations.append("Bağışıklık sistemini güçlendiren besinler tüketin.")
        }
        
        return recommendations
    }
    
    func getImmunityStrengtheningTips() -> [String] {
        return [
            "Düzenli emzirme veya formül süt ile beslenme",
            "Yeterli uyku (yaşa göre 12-16 saat)",
            "Temiz hava ve güneş ışığı",
            "Düzenli aşı takibi",
            "Hijyen kurallarına dikkat (el yıkama)",
            "Stres azaltma (bebek için sakin ortam)",
            "Probiyotik içeren besinler (yaşa uygun)",
            "Doktor kontrollerini aksatmayın"
        ]
    }
    
    private func isVaccinationDue(_ vaccination: VaccinationSchedule, ageInMonths: Int) -> Bool {
        // Basitleştirilmiş kontrol - gerçek uygulamada daha detaylı olmalı
        let ageString = vaccination.recommendedAge.lowercased()
        if ageString.contains("doğum") {
            return ageInMonths == 0
        } else if let month = extractMonth(from: ageString) {
            return ageInMonths >= month && ageInMonths <= month + 1
        }
        return false
    }
    
    private func extractMonth(from text: String) -> Int? {
        let numbers = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(numbers)
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: "immunityRecords_\(babyId.uuidString)")
        }
        // VaccinationSchedule'ı kaydetmek için ayrı bir yöntem gerekebilir
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "immunityRecords_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([ImmunityRecord].self, from: data) {
            records = decoded.sorted { $0.date > $1.date }
        }
    }
}
