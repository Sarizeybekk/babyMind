//
//  SettingsView.swift
//  BabyMind
//
//  Ayarlar görünümü
//

import SwiftUI

struct SettingsView: View {
    let baby: Baby
    @AppStorage("darkModeEnabled") private var isDarkMode = false
    @State private var syncStatus: String = ""
    @State private var isSyncing = false
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    var body: some View {
            List {
                Section("Görünüm") {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                        .onChange(of: isDarkMode) { oldValue, newValue in
                        // AppStorage otomatik olarak UserDefaults'a kaydeder
                        // preferredColorScheme otomatik güncellenir
                        }
                }
                
                Section("iCloud Sync") {
                    Button(action: {
                    syncStatus = "iCloud Sync yakında eklenecek"
                    }) {
                        HStack {
                            Text("iCloud'a Yedekle")
                            Spacer()
                        if isSyncing {
                                ProgressView()
                        }
                    }
                }
                .disabled(isSyncing)
                    
                    if !syncStatus.isEmpty {
                        Text(syncStatus)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                    syncStatus = "iCloud Sync yakında eklenecek"
                    }) {
                        Text("iCloud'dan Geri Yükle")
                    }
                }
                
                Section("Hakkında") {
                    HStack {
                        Text("Versiyon")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Ayarlar")
        .navigationBarTitleDisplayMode(.large)
        }
    
}




