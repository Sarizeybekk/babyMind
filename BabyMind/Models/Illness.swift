//
//  Illness.swift
//  BabyMind
//
//  Hastalık modeli
//

import Foundation

struct Illness: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let name: String // Hastalık adı (Nezle, Grip, İshal, vb.)
    let startDate: Date
    let endDate: Date?
    let symptoms: [Symptom]
    let notes: String?
    let doctorVisited: Bool
    let doctorName: String?
    let medications: [String] // Kullanılan ilaçlar
    let photos: [Data]? // Döküntü/kızarıklık fotoğrafları
    
    enum Symptom: String, Codable, CaseIterable {
        case fever = "Ateş"
        case cough = "Öksürük"
        case runnyNose = "Burun Akıntısı"
        case diarrhea = "İshal"
        case vomiting = "Kusma"
        case rash = "Döküntü"
        case irritability = "Huzursuzluk"
        case lossOfAppetite = "İştahsızlık"
        case sleepProblems = "Uyku Problemleri"
        case other = "Diğer"
    }
    
    var isActive: Bool {
        endDate == nil
    }
    
    var duration: Int? {
        guard let endDate = endDate else { return nil }
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day
    }
    
    init(id: UUID = UUID(),
         babyId: UUID,
         name: String,
         startDate: Date = Date(),
         endDate: Date? = nil,
         symptoms: [Symptom] = [],
         notes: String? = nil,
         doctorVisited: Bool = false,
         doctorName: String? = nil,
         medications: [String] = [],
         photos: [Data]? = nil) {
        self.id = id
        self.babyId = babyId
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.symptoms = symptoms
        self.notes = notes
        self.doctorVisited = doctorVisited
        self.doctorName = doctorName
        self.medications = medications
        self.photos = photos
    }
}







