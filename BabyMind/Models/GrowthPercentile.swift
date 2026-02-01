//
//  GrowthPercentile.swift
//
//  Büyüme persentil modeli
//

import Foundation

struct GrowthRecord: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let date: Date
    let weight: Double // kg
    let height: Double // cm
    let headCircumference: Double? // cm
    let ageInMonths: Int
    
    init(id: UUID = UUID(),
         babyId: UUID,
         date: Date = Date(),
         weight: Double,
         height: Double,
         headCircumference: Double? = nil,
         ageInMonths: Int) {
        self.id = id
        self.babyId = babyId
        self.date = date
        self.weight = weight
        self.height = height
        self.headCircumference = headCircumference
        self.ageInMonths = ageInMonths
    }
}

// Persentil değerlerini ayrı saklamak için extension
extension GrowthRecord {
    func getWeightPercentile(isMale: Bool) -> Double {
        return WHOGrowthStandard.getWeightPercentile(
            ageInMonths: ageInMonths,
            weight: weight,
            isMale: isMale
        )
    }
    
    func getHeightPercentile(isMale: Bool) -> Double {
        return WHOGrowthStandard.getHeightPercentile(
            ageInMonths: ageInMonths,
            height: height,
            isMale: isMale
        )
    }
    
    func getHeadCircumferencePercentile(isMale: Bool) -> Double? {
        guard let hc = headCircumference else { return nil }
        return WHOGrowthStandard.getHeadCircumferencePercentile(
            ageInMonths: ageInMonths,
            headCircumference: hc,
            isMale: isMale
        )
    }
}

struct WHOGrowthStandard {
    // WHO büyüme standartları için referans değerler
    // Bu değerler gerçek WHO verilerinden alınmalı
    static func getWeightPercentile(ageInMonths: Int, weight: Double, isMale: Bool) -> Double {
        // Basitleştirilmiş hesaplama (gerçek implementasyonda WHO tabloları kullanılmalı)
        // Örnek: 6 aylık erkek bebek için ortalama ağırlık ~7.5 kg
        let averageWeight = isMale ? 
            (ageInMonths <= 6 ? 3.3 + Double(ageInMonths) * 0.7 : 7.5 + Double(ageInMonths - 6) * 0.4) :
            (ageInMonths <= 6 ? 3.2 + Double(ageInMonths) * 0.65 : 7.0 + Double(ageInMonths - 6) * 0.35)
        
        let deviation = weight - averageWeight
        let percentile = 50.0 + (deviation / averageWeight) * 30.0
        return max(0, min(100, percentile))
    }
    
    static func getHeightPercentile(ageInMonths: Int, height: Double, isMale: Bool) -> Double {
        // Basitleştirilmiş hesaplama
        let averageHeight = isMale ?
            (ageInMonths <= 6 ? 50.0 + Double(ageInMonths) * 2.5 : 67.0 + Double(ageInMonths - 6) * 1.2) :
            (ageInMonths <= 6 ? 49.0 + Double(ageInMonths) * 2.4 : 65.0 + Double(ageInMonths - 6) * 1.1)
        
        let deviation = height - averageHeight
        let percentile = 50.0 + (deviation / averageHeight) * 30.0
        return max(0, min(100, percentile))
    }
    
    static func getHeadCircumferencePercentile(ageInMonths: Int, headCircumference: Double, isMale: Bool) -> Double {
        // Basitleştirilmiş hesaplama
        let averageHC = isMale ?
            (ageInMonths <= 6 ? 35.0 + Double(ageInMonths) * 0.8 : 43.0 + Double(ageInMonths - 6) * 0.3) :
            (ageInMonths <= 6 ? 34.0 + Double(ageInMonths) * 0.75 : 42.0 + Double(ageInMonths - 6) * 0.25)
        
        let deviation = headCircumference - averageHC
        let percentile = 50.0 + (deviation / averageHC) * 30.0
        return max(0, min(100, percentile))
    }
}


