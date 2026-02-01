//
//  DoctorNote.swift
//  BabyMind
//
//  Doktor notu modeli
//

import Foundation

struct DoctorNote: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let date: Date
    let doctorName: String
    let specialty: String? // Uzmanlık alanı
    let reason: String // Ziyaret nedeni
    let diagnosis: String? // Teşhis
    let notes: String? // Doktor notları
    let recommendations: [String] // Öneriler
    let testResults: [TestResult]? // Tahlil sonuçları
    let nextAppointment: Date? // Sonraki randevu
    let photos: [Data]? // Reçete/tahlil fotoğrafları
    
    struct TestResult: Codable {
        let name: String // Tahlil adı
        let value: String // Değer
        let unit: String? // Birim
        let normalRange: String? // Normal aralık
        let isNormal: Bool? // Normal mi?
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         date: Date = Date(),
         doctorName: String,
         specialty: String? = nil,
         reason: String,
         diagnosis: String? = nil,
         notes: String? = nil,
         recommendations: [String] = [],
         testResults: [TestResult]? = nil,
         nextAppointment: Date? = nil,
         photos: [Data]? = nil) {
        self.id = id
        self.babyId = babyId
        self.date = date
        self.doctorName = doctorName
        self.specialty = specialty
        self.reason = reason
        self.diagnosis = diagnosis
        self.notes = notes
        self.recommendations = recommendations
        self.testResults = testResults
        self.nextAppointment = nextAppointment
        self.photos = photos
    }
}







