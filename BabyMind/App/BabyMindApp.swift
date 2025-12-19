//
//  BabyMindApp.swift
//  BabyMind
//
//  Ana uygulama giriş noktası
//

import SwiftUI

@main
struct BabyMindApp: App {
    @AppStorage("darkModeEnabled") private var isDarkMode = false
    
    init() {
        // Uygulama genelinde Türkçe locale ayarla
        UserDefaults.standard.set(["tr_TR"], forKey: "AppleLanguages")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, Locale(identifier: "tr_TR"))
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}




