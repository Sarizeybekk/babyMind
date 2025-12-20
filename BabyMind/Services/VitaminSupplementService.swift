//
//  VitaminSupplementService.swift
//
//  Vitamin ve takviye yönetim servisi
//

import Foundation
import Combine

class VitaminSupplementService: ObservableObject {
    @Published var supplements: [VitaminSupplement] = []
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadSupplements()
    }
    
    func addSupplement(_ supplement: VitaminSupplement) {
        supplements.append(supplement)
        supplements.sort { $0.startDate > $1.startDate }
        saveSupplements()
    }
    
    func updateSupplement(_ supplement: VitaminSupplement) {
        if let index = supplements.firstIndex(where: { $0.id == supplement.id }) {
            supplements[index] = supplement
            saveSupplements()
        }
    }
    
    func deleteSupplement(_ supplement: VitaminSupplement) {
        supplements.removeAll { $0.id == supplement.id }
        saveSupplements()
    }
    
    func getActiveSupplements() -> [VitaminSupplement] {
        return supplements.filter { $0.isActive }
    }
    
    func checkDeficiencies(ageInMonths: Int) -> [DeficiencyAlert] {
        var alerts: [DeficiencyAlert] = []
        let activeSupplements = getActiveSupplements()
        
        // D Vitamini kontrolü
        let hasVitaminD = activeSupplements.contains { $0.type == .vitaminD }
        if !hasVitaminD && ageInMonths < 12 {
            alerts.append(DeficiencyAlert(
                type: .vitaminD,
                message: "D vitamini takviyesi önerilir (0-12 ay).",
                severity: .moderate
            ))
        }
        
        // Demir kontrolü
        let hasIron = activeSupplements.contains { $0.type == .iron }
        if !hasIron && ageInMonths >= 4 && ageInMonths <= 12 {
            alerts.append(DeficiencyAlert(
                type: .iron,
                message: "Demir takviyesi düşünülebilir (4-12 ay). Doktorunuza danışın.",
                severity: .low
            ))
        }
        
        return alerts
    }
    
    func getFoodSources(for type: VitaminSupplement.SupplementType) -> [String] {
        switch type {
        case .vitaminD:
            return [
                "Güneş ışığı (en önemli kaynak)",
                "Somon, ton balığı",
                "Yumurta sarısı",
                "D vitamini eklenmiş süt/formül"
            ]
        case .iron:
            return [
                "Kırmızı et",
                "Kümes hayvanları",
                "Balık",
                "Baklagiller",
                "Demir eklenmiş tahıllar",
                "Koyu yeşil yapraklı sebzeler"
            ]
        case .zinc:
            return [
                "Et ve kümes hayvanları",
                "Deniz ürünleri",
                "Baklagiller",
                "Tam tahıllar",
                "Süt ürünleri"
            ]
        case .multivitamin:
            return ["Doktor önerisi ile multivitamin preparatları"]
        case .probiotic:
            return [
                "Yoğurt",
                "Kefir",
                "Probiyotik eklenmiş formül süt",
                "Doktor önerisi ile probiyotik takviyeleri"
            ]
        case .omega3:
            return [
                "Somon, ton balığı",
                "Ceviz",
                "Keten tohumu",
                "Omega-3 eklenmiş formül süt"
            ]
        case .other:
            return ["Doktor önerisi"]
        }
    }
    
    private func saveSupplements() {
        if let encoded = try? JSONEncoder().encode(supplements) {
            UserDefaults.standard.set(encoded, forKey: "vitaminSupplements_\(babyId.uuidString)")
        }
    }
    
    private func loadSupplements() {
        if let data = UserDefaults.standard.data(forKey: "vitaminSupplements_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([VitaminSupplement].self, from: data) {
            supplements = decoded.sorted { $0.startDate > $1.startDate }
        }
    }
}
