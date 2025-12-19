//
//  Baby.swift
//  BabyMind
//
//  Bebek bilgileri modeli
//

import Foundation

struct Baby: Codable, Identifiable {
    let id: UUID
    var name: String
    var birthDate: Date
    var gender: Gender
    var birthWeight: Double // kilogram cinsinden
    var currentWeight: Double? // kilogram cinsinden
    var birthHeight: Double // santimetre cinsinden
    var currentHeight: Double? // santimetre cinsinden
    
    enum Gender: String, Codable, CaseIterable {
        case male = "Erkek"
        case female = "Kız"
    }
    
    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: birthDate, to: Date()).day ?? 0
    }
    
    var ageInWeeks: Int {
        ageInDays / 7
    }
    
    var ageInMonths: Int {
        Calendar.current.dateComponents([.month], from: birthDate, to: Date()).month ?? 0
    }
    
    var ageDescription: String {
        if ageInMonths < 1 {
            return "\(ageInWeeks) haftalık"
        } else if ageInMonths < 12 {
            return "\(ageInMonths) aylık"
        } else {
            let years = ageInMonths / 12
            let months = ageInMonths % 12
            if months == 0 {
                return "\(years) yaşında"
            } else {
                return "\(years) yaş \(months) ay"
            }
        }
    }
    
    init(id: UUID = UUID(), 
         name: String = "",
         birthDate: Date = Date(),
         gender: Gender = .male,
         birthWeight: Double = 0.0,
         currentWeight: Double? = nil,
         birthHeight: Double = 0.0,
         currentHeight: Double? = nil) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.gender = gender
        self.birthWeight = birthWeight
        self.currentWeight = currentWeight
        self.birthHeight = birthHeight
        self.currentHeight = currentHeight
    }
}




