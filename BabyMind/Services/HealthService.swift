//
//  HealthService.swift
//  BabyMind
//
//  Sağlık servisi
//

import Foundation

class HealthService {
    
    func getVaccinations(for baby: Baby) -> [Vaccination] {
        let ageInWeeks = baby.ageInWeeks
        
        var vaccinations: [Vaccination] = []
        
        // Doğumda
        vaccinations.append(Vaccination(
            name: "Hepatit B (1. Doz)",
            description: "Doğumda yapılan ilk aşı",
            recommendedAge: 0,
            isCompleted: ageInWeeks >= 0
        ))
        
        // 1. ay
        if ageInWeeks >= 4 {
            vaccinations.append(Vaccination(
                name: "BCG (Verem)",
                description: "Tüberküloz aşısı",
                recommendedAge: 4,
                isCompleted: ageInWeeks >= 4
            ))
            
            vaccinations.append(Vaccination(
                name: "Hepatit B (2. Doz)",
                description: "Hepatit B aşısı ikinci doz",
                recommendedAge: 4,
                isCompleted: ageInWeeks >= 4
            ))
        }
        
        // 2. ay
        if ageInWeeks >= 8 {
            vaccinations.append(Vaccination(
                name: "KPA (Pnömokok)",
                description: "Pnömokok aşısı",
                recommendedAge: 8,
                isCompleted: ageInWeeks >= 8
            ))
            
            vaccinations.append(Vaccination(
                name: "Beşli Karma (DTP-IPV-Hib)",
                description: "Difteri, tetanos, boğmaca, çocuk felci, menenjit aşısı",
                recommendedAge: 8,
                isCompleted: ageInWeeks >= 8
            ))
        }
        
        // 4. ay
        if ageInWeeks >= 16 {
            vaccinations.append(Vaccination(
                name: "KPA (2. Doz)",
                description: "Pnömokok aşısı ikinci doz",
                recommendedAge: 16,
                isCompleted: ageInWeeks >= 16
            ))
            
            vaccinations.append(Vaccination(
                name: "Beşli Karma (2. Doz)",
                description: "Beşli karma aşı ikinci doz",
                recommendedAge: 16,
                isCompleted: ageInWeeks >= 16
            ))
        }
        
        // 6. ay
        if ageInWeeks >= 24 {
            vaccinations.append(Vaccination(
                name: "KPA (3. Doz)",
                description: "Pnömokok aşısı üçüncü doz",
                recommendedAge: 24,
                isCompleted: ageInWeeks >= 24
            ))
            
            vaccinations.append(Vaccination(
                name: "Beşli Karma (3. Doz)",
                description: "Beşli karma aşı üçüncü doz",
                recommendedAge: 24,
                isCompleted: ageInWeeks >= 24
            ))
        }
        
        return vaccinations
    }
    
    func getHealthTips(for baby: Baby) -> [String] {
        let ageInWeeks = baby.ageInWeeks
        
        var tips: [String] = []
        
        if ageInWeeks < 4 {
            tips = [
                "Bebeğinizin göbek bağı temizliğine dikkat edin",
                "Bebeğinizin cildini nemli tutun",
                "Bebeğinizin vücut sıcaklığını düzenli kontrol edin",
                "Bebeğinizin nefes alışını gözlemleyin"
            ]
        } else if ageInWeeks < 12 {
            tips = [
                "Bebeğinizin başını destekleyin",
                "Bebeğinizi sırt üstü yatırın",
                "Bebeğinizin cildini düzenli kontrol edin",
                "Bebeğinizin göz teması kurmasını destekleyin"
            ]
        } else {
            tips = [
                "Bebeğinizin güvenliğini sağlayın",
                "Bebeğinizin gelişimini takip edin",
                "Düzenli sağlık kontrollerini yaptırın",
                "Bebeğinizin aşılarını takip edin"
            ]
        }
        
        return tips
    }
    
    func getEmergencyInfo() -> [EmergencyContact] {
        return [
            EmergencyContact(
                name: "112 Acil Servis",
                phone: "112",
                type: .emergency
            ),
            EmergencyContact(
                name: "Zehir Danışma",
                phone: "114",
                type: .poison
            ),
            EmergencyContact(
                name: "Çocuk Acil",
                phone: "112",
                type: .pediatric
            )
        ]
    }
}

struct EmergencyContact: Identifiable {
    let id = UUID()
    let name: String
    let phone: String
    let type: ContactType
    
    enum ContactType {
        case emergency
        case poison
        case pediatric
        case doctor
    }
}



