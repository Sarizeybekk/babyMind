//
//  Allergy.swift
//  BabyMind
//
//  Alerji modeli
//

import Foundation

struct Allergy: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let allergen: String // Alerjen (örn: Fıstık, Süt, Yumurta)
    let category: AllergyCategory
    let severity: Severity
    let firstObserved: Date
    let symptoms: [String]
    let notes: String?
    let testResult: String? // Test sonucu varsa
    let testDate: Date?
    
    enum AllergyCategory: String, Codable, CaseIterable {
        case food = "Gıda"
        case medication = "İlaç"
        case environmental = "Çevresel"
        case other = "Diğer"
    }
    
    enum Severity: String, Codable, CaseIterable {
        case mild = "Hafif"
        case moderate = "Orta"
        case severe = "Şiddetli"
        case lifeThreatening = "Hayati Risk"
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         allergen: String,
         category: AllergyCategory,
         severity: Severity,
         firstObserved: Date = Date(),
         symptoms: [String] = [],
         notes: String? = nil,
         testResult: String? = nil,
         testDate: Date? = nil) {
        self.id = id
        self.babyId = babyId
        self.allergen = allergen
        self.category = category
        self.severity = severity
        self.firstObserved = firstObserved
        self.symptoms = symptoms
        self.notes = notes
        self.testResult = testResult
        self.testDate = testDate
    }
}

struct AllergyReaction: Identifiable, Codable {
    let id: UUID
    let allergyId: UUID
    let date: Date
    let severity: Allergy.Severity
    let symptoms: [String]
    let notes: String?
    let medicationGiven: String?
    
    init(id: UUID = UUID(),
         allergyId: UUID,
         date: Date = Date(),
         severity: Allergy.Severity,
         symptoms: [String] = [],
         notes: String? = nil,
         medicationGiven: String? = nil) {
        self.id = id
        self.allergyId = allergyId
        self.date = date
        self.severity = severity
        self.symptoms = symptoms
        self.notes = notes
        self.medicationGiven = medicationGiven
    }
}







