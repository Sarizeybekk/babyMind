//
//  SafetyChecklistService.swift
//
//  Güvenlik kontrol listesi servisi
//

import Foundation
import Combine

class SafetyChecklistService: ObservableObject {
    @Published var checklistItems: [SafetyChecklist] = []
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadChecklist()
        if checklistItems.isEmpty {
            initializeDefaultChecklist()
        }
    }
    
    func initializeDefaultChecklist() {
        var items: [SafetyChecklist] = []
        
        // Ev Güvenliği
        items.append(contentsOf: [
            SafetyChecklist(babyId: babyId, category: .home, item: "Prize koruyucu takıldı mı?"),
            SafetyChecklist(babyId: babyId, category: .home, item: "Keskin köşeler korundu mu?"),
            SafetyChecklist(babyId: babyId, category: .home, item: "Mobilyalar duvara sabitlendi mi?"),
            SafetyChecklist(babyId: babyId, category: .home, item: "Temizlik malzemeleri erişilemez yerde mi?"),
            SafetyChecklist(babyId: babyId, category: .home, item: "Pencere kilitleri takıldı mı?"),
            SafetyChecklist(babyId: babyId, category: .home, item: "Merdiven kapıları var mı?"),
            SafetyChecklist(babyId: babyId, category: .home, item: "Küçük nesneler erişilemez yerde mi?")
        ])
        
        // Oyuncak Güvenliği
        items.append(contentsOf: [
            SafetyChecklist(babyId: babyId, category: .toys, item: "Oyuncaklar yaşa uygun mu?"),
            SafetyChecklist(babyId: babyId, category: .toys, item: "Küçük parçalar yok mu?"),
            SafetyChecklist(babyId: babyId, category: .toys, item: "Keskin kenarlar yok mu?"),
            SafetyChecklist(babyId: babyId, category: .toys, item: "Boyalar toksik değil mi?"),
            SafetyChecklist(babyId: babyId, category: .toys, item: "Pil bölmeleri güvenli mi?")
        ])
        
        // Uyku Ortamı Güvenliği
        items.append(contentsOf: [
            SafetyChecklist(babyId: babyId, category: .sleep, item: "Yatak sert ve düz mü?"),
            SafetyChecklist(babyId: babyId, category: .sleep, item: "Yatakta yastık, oyuncak yok mu?"),
            SafetyChecklist(babyId: babyId, category: .sleep, item: "Battaniye güvenli şekilde örtülü mü?"),
            SafetyChecklist(babyId: babyId, category: .sleep, item: "Yatak yanında yumuşak yüzey var mı?"),
            SafetyChecklist(babyId: babyId, category: .sleep, item: "Oda sıcaklığı uygun mu? (18-22°C)"),
            SafetyChecklist(babyId: babyId, category: .sleep, item: "Bebek sırt üstü yatıyor mu?")
        ])
        
        // Bebek Bakım Ürünleri
        items.append(contentsOf: [
            SafetyChecklist(babyId: babyId, category: .products, item: "Ürünler bebek için uygun mu?"),
            SafetyChecklist(babyId: babyId, category: .products, item: "Son kullanma tarihleri kontrol edildi mi?"),
            SafetyChecklist(babyId: babyId, category: .products, item: "Alerjen içerikler kontrol edildi mi?"),
            SafetyChecklist(babyId: babyId, category: .products, item: "Ürünler güvenli yerde saklanıyor mu?")
        ])
        
        checklistItems = items
        saveChecklist()
    }
    
    func toggleItem(_ item: SafetyChecklist) {
        if let index = checklistItems.firstIndex(where: { $0.id == item.id }) {
            var updated = item
            updated.isChecked.toggle()
            updated.checkedDate = updated.isChecked ? Date() : nil
            checklistItems[index] = updated
            saveChecklist()
        }
    }
    
    func getProgressByCategory() -> [SafetyChecklist.Category: (checked: Int, total: Int)] {
        var progress: [SafetyChecklist.Category: (checked: Int, total: Int)] = [:]
        
        for category in SafetyChecklist.Category.allCases {
            let categoryItems = checklistItems.filter { $0.category == category }
            let checked = categoryItems.filter { $0.isChecked }.count
            progress[category] = (checked, categoryItems.count)
        }
        
        return progress
    }
    
    func getOverallProgress() -> Double {
        let checked = checklistItems.filter { $0.isChecked }.count
        return checklistItems.isEmpty ? 0 : Double(checked) / Double(checklistItems.count) * 100.0
    }
    
    private func saveChecklist() {
        if let encoded = try? JSONEncoder().encode(checklistItems) {
            UserDefaults.standard.set(encoded, forKey: "safetyChecklist_\(babyId.uuidString)")
        }
    }
    
    private func loadChecklist() {
        if let data = UserDefaults.standard.data(forKey: "safetyChecklist_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([SafetyChecklist].self, from: data) {
            checklistItems = decoded
        }
    }
}
