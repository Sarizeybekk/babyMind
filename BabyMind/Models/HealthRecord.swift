//
//  HealthRecord.swift
//  BabyMind
//
//  Sağlık kayıtları modeli
//

import Foundation

struct HealthRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let type: RecordType
    let title: String
    let description: String
    let doctorName: String?
    let notes: String?
    
    enum RecordType: String, Codable, CaseIterable {
        case vaccination = "Aşı"
        case checkup = "Kontrol"
        case illness = "Hastalık"
        case medication = "İlaç"
        case measurement = "Ölçüm"
        case other = "Diğer"
    }
    
    init(id: UUID = UUID(),
         date: Date = Date(),
         type: RecordType,
         title: String,
         description: String,
         doctorName: String? = nil,
         notes: String? = nil) {
        self.id = id
        self.date = date
        self.type = type
        self.title = title
        self.description = description
        self.doctorName = doctorName
        self.notes = notes
    }
}

struct Vaccination: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let recommendedAge: Int // hafta cinsinden
    let isCompleted: Bool
    let dateCompleted: Date?
    
    init(id: UUID = UUID(),
         name: String,
         description: String,
         recommendedAge: Int,
         isCompleted: Bool = false,
         dateCompleted: Date? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.recommendedAge = recommendedAge
        self.isCompleted = isCompleted
        self.dateCompleted = dateCompleted
    }
}



