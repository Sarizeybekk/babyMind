//
//  TeethService.swift
//  BabyMind
//
//  Diş çıkarma takip servisi
//

import Foundation
import Combine

class TeethService: ObservableObject {
    @Published var teeth: [ToothRecord] = []
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadTeeth()
    }
    
    func addTooth(_ tooth: ToothRecord) {
        teeth.append(tooth)
        saveTeeth()
    }
    
    func deleteTooth(_ tooth: ToothRecord) {
        teeth.removeAll { $0.id == tooth.id }
        saveTeeth()
    }
    
    func getTooth(by number: Int) -> ToothRecord? {
        return teeth.first { $0.toothNumber == number }
    }
    
    func hasTooth(by number: Int) -> Bool {
        return getTooth(by: number) != nil
    }
    
    func getTeethByRow(_ row: Int) -> [ToothRecord] {
        return teeth.filter { tooth in
            if let toothInfo = ToothRecord.babyTeeth.first(where: { $0.number == tooth.toothNumber }) {
                return toothInfo.position.row == row
            }
            return false
        }
    }
    
    private func saveTeeth() {
        if let encoded = try? JSONEncoder().encode(teeth) {
            UserDefaults.standard.set(encoded, forKey: "teeth_\(babyId.uuidString)")
        }
    }
    
    private func loadTeeth() {
        if let data = UserDefaults.standard.data(forKey: "teeth_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([ToothRecord].self, from: data) {
            teeth = decoded
        }
    }
}







