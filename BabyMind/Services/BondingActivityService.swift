//
//  BondingActivityService.swift
//
//  Anne-bebek bağlanma aktivite servisi
//

import Foundation
import Combine

class BondingActivityService: ObservableObject {
    @Published var activities: [BondingActivity] = []
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadActivities()
    }
    
    func addActivity(_ activity: BondingActivity) {
        activities.append(activity)
        activities.sort { $0.date > $1.date }
        saveActivities()
    }
    
    func deleteActivity(_ activity: BondingActivity) {
        activities.removeAll { $0.id == activity.id }
        saveActivities()
    }
    
    func getPlaySuggestions(ageInMonths: Int) -> [PlaySuggestion] {
        var suggestions: [PlaySuggestion] = []
        
        if ageInMonths < 3 {
            suggestions.append(PlaySuggestion(
                ageRange: "0-3 ay",
                activities: [
                    "Yüz yüze göz teması",
                    "Yumuşak seslerle konuşma",
                    "Ninni söyleme",
                    "Hafif sallama",
                    "Ten tene temas"
                ],
                benefits: [
                    "Güven duygusu geliştirir",
                    "Bağlanmayı güçlendirir",
                    "Duygusal gelişimi destekler"
                ]
            ))
        } else if ageInMonths < 6 {
            suggestions.append(PlaySuggestion(
                ageRange: "3-6 ay",
                activities: [
                    "Çıngıraklı oyuncaklar",
                    "Ayna oyunu",
                    "Yüz ifadelerini taklit",
                    "Şarkı söyleme",
                    "Hafif masaj"
                ],
                benefits: [
                    "Motor gelişimi destekler",
                    "Sosyal becerileri geliştirir",
                    "Dil gelişimini başlatır"
                ]
            ))
        } else if ageInMonths < 12 {
            suggestions.append(PlaySuggestion(
                ageRange: "6-12 ay",
                activities: [
                    "Ce-ee oyunu",
                    "Parmak kuklaları",
                    "Kitap okuma",
                    "Müzikli oyuncaklar",
                    "Banyo oyunları"
                ],
                benefits: [
                    "Bilişsel gelişimi destekler",
                    "Dil becerilerini geliştirir",
                    "Sosyal etkileşimi artırır"
                ]
            ))
        } else {
            suggestions.append(PlaySuggestion(
                ageRange: "12+ ay",
                activities: [
                    "Blok oyunları",
                    "Puzzle",
                    "Hikaye okuma",
                    "Dans ve müzik",
                    "Dışarıda oyun"
                ],
                benefits: [
                    "Problem çözme becerileri",
                    "Yaratıcılığı geliştirir",
                    "Fiziksel gelişimi destekler"
                ]
            ))
        }
        
        return suggestions
    }
    
    func getMassageTechniques() -> [String] {
        return [
            "Yumuşak, dairesel hareketlerle başlayın",
            "Bebeğinizin yüz ifadelerini izleyin",
            "Ilık yağ kullanın (bebek için uygun)",
            "5-10 dakika yeterlidir",
            "Rahat ve sakin bir ortam seçin",
            "Bebeğiniz rahatsız olursa durdurun"
        ]
    }
    
    func getReadingRoutines() -> [String] {
        return [
            "Günlük rutin oluşturun (uyku öncesi)",
            "Yüksek sesle ve yavaş okuyun",
            "Resimli kitaplar seçin",
            "Bebeğinizin tepkilerini gözlemleyin",
            "Aynı kitabı tekrar okumaktan çekinmeyin",
            "10-15 dakika yeterlidir"
        ]
    }
    
    func getMusicTherapyTips() -> [String] {
        return [
            "Yumuşak, sakin müzikler seçin",
            "Klasik müzik veya doğa sesleri",
            "Kendi sesinizle ninni söyleyin",
            "Müzik eşliğinde dans edin",
            "Bebeğinizin tepkilerini gözlemleyin"
        ]
    }
    
    func getWeeklyActivitySummary() -> (completed: Int, total: Int) {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? Date()
        
        let weekActivities = activities.filter { $0.date >= weekStart && $0.date < weekEnd }
        let completed = weekActivities.filter { $0.isCompleted }.count
        
        return (completed, weekActivities.count)
    }
    
    private func saveActivities() {
        if let encoded = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(encoded, forKey: "bondingActivities_\(babyId.uuidString)")
        }
    }
    
    private func loadActivities() {
        if let data = UserDefaults.standard.data(forKey: "bondingActivities_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([BondingActivity].self, from: data) {
            activities = decoded.sorted { $0.date > $1.date }
        }
    }
}


