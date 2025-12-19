//
//  GrowthData.swift
//  BabyMind
//
//  Büyüme verileri ve WHO percentile hesaplamaları
//

import Foundation

struct GrowthData: Identifiable, Codable {
    let id: UUID
    let date: Date
    let weight: Double // kg
    let height: Double // cm
    let headCircumference: Double? // cm
    
    init(id: UUID = UUID(),
         date: Date = Date(),
         weight: Double,
         height: Double,
         headCircumference: Double? = nil) {
        self.id = id
        self.date = date
        self.weight = weight
        self.height = height
        self.headCircumference = headCircumference
    }
}

struct GrowthPercentile {
    let weight: Double // 0-100
    let height: Double // 0-100
    let headCircumference: Double? // 0-100
    
    var weightCategory: String {
        if weight < 3 { return "Çok Düşük" }
        if weight < 15 { return "Düşük" }
        if weight < 85 { return "Normal" }
        if weight < 97 { return "Yüksek" }
        return "Çok Yüksek"
    }
    
    var heightCategory: String {
        if height < 3 { return "Çok Kısa" }
        if height < 15 { return "Kısa" }
        if height < 85 { return "Normal" }
        if height < 97 { return "Uzun" }
        return "Çok Uzun"
    }
}

// WHO percentile hesaplama servisi
class GrowthCalculator {
    // Basitleştirilmiş WHO percentile hesaplama
    // Gerçek uygulamada WHO veri tabloları kullanılmalı
    static func calculatePercentile(ageInWeeks: Int, weight: Double, height: Double, gender: Baby.Gender) -> GrowthPercentile {
        // Bu basitleştirilmiş bir örnek
        // Gerçek uygulamada WHO'nun resmi veri tabloları kullanılmalı
        
        let weightPercentile = min(100, max(0, 50 + (weight - 3.5) * 20))
        let heightPercentile = min(100, max(0, 50 + (height - 50) * 2))
        
        return GrowthPercentile(
            weight: weightPercentile,
            height: heightPercentile,
            headCircumference: nil
        )
    }
}

