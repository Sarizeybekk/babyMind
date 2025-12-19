//
//  BabyManager.swift
//  BabyMind
//
//  Bebek yönetimi servisi
//

import Foundation
import Combine
import UIKit
import WidgetKit

class BabyManager: ObservableObject {
    @Published var babies: [Baby] = []
    @Published var selectedBabyId: UUID?
    
    var selectedBaby: Baby? {
        guard let id = selectedBabyId else { return nil }
        return babies.first { $0.id == id }
    }
    
    init() {
        loadBabies()
    }
    
    func addBaby(_ baby: Baby) {
        babies.append(baby)
        if babies.count == 1 {
            selectedBabyId = baby.id
        }
        saveBabies()
        updateWidget()
        HapticManager.shared.notification(type: .success)
    }
    
    func deleteBaby(_ baby: Baby) {
        babies.removeAll { $0.id == baby.id }
        if selectedBabyId == baby.id {
            selectedBabyId = babies.first?.id
        }
        saveBabies()
        HapticManager.shared.impact(style: .medium)
    }
    
    func selectBaby(_ baby: Baby) {
        selectedBabyId = baby.id
        saveBabies()
        updateWidget()
        HapticManager.shared.selection()
    }
    
    private func updateWidget() {
        if let baby = selectedBaby {
            WidgetDataService.shared.saveBabyForWidget(baby)
        }
    }
    
    private func saveBabies() {
        if let encoded = try? JSONEncoder().encode(babies) {
            UserDefaults.standard.set(encoded, forKey: "savedBabies")
        }
        if let selectedId = selectedBabyId {
            UserDefaults.standard.set(selectedId.uuidString, forKey: "selectedBabyId")
        }
    }
    
    private func loadBabies() {
        if let data = UserDefaults.standard.data(forKey: "savedBabies"),
           let decoded = try? JSONDecoder().decode([Baby].self, from: data) {
            babies = decoded
        }
        if let idString = UserDefaults.standard.string(forKey: "selectedBabyId"),
           let id = UUID(uuidString: idString) {
            selectedBabyId = id
        } else {
            selectedBabyId = babies.first?.id
        }
    }
}

