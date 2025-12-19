//
//  WidgetDataService.swift
//  BabyMind
//
//  Widget veri paylaşım servisi
//

import Foundation
import WidgetKit

class WidgetDataService {
    static let shared = WidgetDataService()
    private let appGroupID = "group.com.babymind.app"
    
    private init() {}
    
    // Bebek bilgilerini widget için kaydet
    func saveBabyForWidget(_ baby: Baby) {
        guard let userDefaults = UserDefaults(suiteName: appGroupID),
              let encoded = try? JSONEncoder().encode(baby) else {
            return
        }
        userDefaults.set(encoded, forKey: "selectedBaby")
        userDefaults.synchronize()
        
        // Widget'ı güncelle
        WidgetCenter.shared.reloadTimelines(ofKind: "BabyMindWidget")
    }
    
    // Son aktiviteyi kaydet
    func saveLastActivity(type: ActivityLog.ActivityType, date: Date) {
        guard let userDefaults = UserDefaults(suiteName: appGroupID) else {
            return
        }
        
        let key: String
        switch type {
        case .feeding:
            key = "lastFeeding"
        case .sleep:
            key = "lastSleep"
        case .diaper:
            key = "lastDiaper"
        default:
            return
        }
        
        // Date'i timestamp olarak kaydet
        userDefaults.set(date.timeIntervalSince1970, forKey: key)
        userDefaults.synchronize()
        
        // Widget'ı güncelle
        WidgetCenter.shared.reloadTimelines(ofKind: "BabyMindWidget")
    }
    
    // Widget verilerini temizle
    func clearWidgetData() {
        guard let userDefaults = UserDefaults(suiteName: appGroupID) else {
            return
        }
        userDefaults.removeObject(forKey: "selectedBaby")
        userDefaults.removeObject(forKey: "lastFeeding")
        userDefaults.removeObject(forKey: "lastSleep")
        userDefaults.removeObject(forKey: "lastDiaper")
        userDefaults.synchronize()
        
        // Widget'ı güncelle
        WidgetCenter.shared.reloadTimelines(ofKind: "BabyMindWidget")
    }
}

