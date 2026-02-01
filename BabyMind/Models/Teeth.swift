//
//  Teeth.swift
//  BabyMind
//
//  Diş çıkarma modeli
//

import Foundation

struct ToothRecord: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let toothNumber: Int // 1-20 (bebek dişleri)
    let toothName: String
    let eruptionDate: Date
    let symptoms: [String]
    let photoData: Data?
    let notes: String?
    
    init(id: UUID = UUID(),
         babyId: UUID,
         toothNumber: Int,
         toothName: String,
         eruptionDate: Date = Date(),
         symptoms: [String] = [],
         photoData: Data? = nil,
         notes: String? = nil) {
        self.id = id
        self.babyId = babyId
        self.toothNumber = toothNumber
        self.toothName = toothName
        self.eruptionDate = eruptionDate
        self.symptoms = symptoms
        self.photoData = photoData
        self.notes = notes
    }
    
    static let babyTeeth: [(number: Int, name: String, position: (row: Int, col: Int))] = [
        // Üst çene (sağdan sola)
        (1, "Üst Sağ 2. Azı", (0, 0)),
        (2, "Üst Sağ 1. Azı", (0, 1)),
        (3, "Üst Sağ Köpek", (0, 2)),
        (4, "Üst Sağ Yan Kesici", (0, 3)),
        (5, "Üst Sağ Orta Kesici", (0, 4)),
        (6, "Üst Sol Orta Kesici", (0, 5)),
        (7, "Üst Sol Yan Kesici", (0, 6)),
        (8, "Üst Sol Köpek", (0, 7)),
        (9, "Üst Sol 1. Azı", (0, 8)),
        (10, "Üst Sol 2. Azı", (0, 9)),
        // Alt çene (soldan sağa)
        (11, "Alt Sol 2. Azı", (1, 0)),
        (12, "Alt Sol 1. Azı", (1, 1)),
        (13, "Alt Sol Köpek", (1, 2)),
        (14, "Alt Sol Yan Kesici", (1, 3)),
        (15, "Alt Sol Orta Kesici", (1, 4)),
        (16, "Alt Sağ Orta Kesici", (1, 5)),
        (17, "Alt Sağ Yan Kesici", (1, 6)),
        (18, "Alt Sağ Köpek", (1, 7)),
        (19, "Alt Sağ 1. Azı", (1, 8)),
        (20, "Alt Sağ 2. Azı", (1, 9))
    ]
}







