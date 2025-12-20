//
//  ContentView.swift
//  BabyMind
//
//  Ana görünüm
//

import SwiftUI

struct ContentView: View {
    @StateObject private var aiService = AIService()
    @StateObject private var babyManager = BabyManager()
    @ObservedObject private var alertManager = ReminderAlertManager.shared
    @State private var showAddBaby = false
    @State private var selectedTab = 0
    
    init() {
        // ReminderService'i başlat (singleton)
        _ = ReminderService.shared
        // ReminderAlertManager'ı başlat (singleton)
        _ = ReminderAlertManager.shared
    }
    
    var body: some View {
        Group {
            if babyManager.babies.isEmpty {
                // İlk bebek ekleme ekranı
                BabyInfoView(babyManager: babyManager, isFirstBaby: true)
            } else if let selectedBaby = babyManager.selectedBaby {
                // Ana uygulama
                MainTabView(babyManager: babyManager, aiService: aiService)
            } else {
                // Bebek seçim ekranı
                BabySelectionView(babyManager: babyManager)
            }
        }
        .overlay(
            // Reminder Alert Overlay
            Group {
                if alertManager.showAlert, let reminder = alertManager.currentReminder {
                    ReminderAlertView(
                        reminder: reminder,
                        onDismiss: {
                            alertManager.dismiss()
                        },
                        onComplete: {
                            ReminderService.shared.completeReminder(reminder)
                        }
                    )
                    .zIndex(999)
                }
            }
        )
    }
}

struct MainTabView: View {
    @ObservedObject var babyManager: BabyManager
    @ObservedObject var aiService: AIService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // İlk 4 tab - Ana ekranda görünür (en önemli özellikler)
            NavigationView {
                DashboardView(babyManager: babyManager, aiService: aiService)
            }
            .tabItem {
                Label("Ana Sayfa", systemImage: "house.fill")
            }
            .tag(0)
            
            if let baby = babyManager.selectedBaby {
                NavigationView {
                    HealthView(baby: baby)
                }
                .tabItem {
                    Label("Sağlık", systemImage: "heart.text.square.fill")
                }
                .tag(1)
                
                NavigationView {
                    ActivityLogView(baby: baby)
                }
                .tabItem {
                    Label("Takip", systemImage: "list.bullet.clipboard.fill")
                }
                .tag(2)
                
                NavigationView {
                    GrowthChartView(baby: baby)
                }
                .tabItem {
                    Label("Büyüme", systemImage: "chart.bar.fill")
                }
                .tag(3)
                
                // "More" sekmesine gidecek tab'lar (5'ten fazla olduğu için)
                NavigationView {
                    FeedingView(baby: baby, aiService: aiService)
                }
                .tabItem {
                    Label("Beslenme", systemImage: "fork.knife")
                }
                .tag(4)
                
                NavigationView {
                    SleepView(baby: baby, aiService: aiService)
                }
                .tabItem {
                    Label("Uyku", systemImage: "bed.double.fill")
                }
                .tag(5)
                
                NavigationView {
                    DevelopmentView(baby: baby, aiService: aiService)
                }
                .tabItem {
                    Label("Gelişim", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(6)
                
                NavigationView {
                    MilestoneAlbumView(baby: baby)
                }
                .tabItem {
                    Label("Albüm", systemImage: "photo.on.rectangle.angled")
                }
                .tag(7)
                
                NavigationView {
                    ChatView(baby: baby)
                }
                .tabItem {
                    Label("AI Asistan", systemImage: "sparkles")
                }
                .tag(8)
                
                NavigationView {
                    RemindersView(baby: baby)
                }
                .tabItem {
                    Label("Hatırlatıcılar", systemImage: "bell.fill")
                }
                .tag(9)
                
                // Yeni özellikler - "More" sekmesinde görünecek
                NavigationView {
                    FamilyCalendarView(baby: baby)
                }
                .tabItem {
                    Label("Takvim", systemImage: "calendar")
                }
                .tag(10)
                
                NavigationView {
                    SettingsView(baby: baby)
                }
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
                .tag(11)
                
                NavigationView {
                    ImmunityTrackerView(baby: baby)
                }
                .tabItem {
                    Label("Bağışıklık", systemImage: "cross.case.fill")
                }
                .tag(13)
                
                NavigationView {
                    VitaminSupplementView(baby: baby)
                }
                .tabItem {
                    Label("Vitamin", systemImage: "pills.fill")
                }
                .tag(14)
                
                NavigationView {
                    BondingActivitiesView(baby: baby)
                }
                .tabItem {
                    Label("Bağlanma", systemImage: "heart.circle.fill")
                }
                .tag(15)
                
                NavigationView {
                    EmergencyGuideView(baby: baby)
                }
                .tabItem {
                    Label("Acil Durum", systemImage: "cross.case.fill")
                }
                .tag(16)
                
                NavigationView {
                    RoutinesView(baby: baby)
                }
                .tabItem {
                    Label("Rutinler", systemImage: "clock.fill")
                }
                .tag(17)
                
                NavigationView {
                    SafetyChecklistView(baby: baby)
                }
                .tabItem {
                    Label("Güvenlik", systemImage: "checkmark.shield.fill")
                }
                .tag(18)
                
                NavigationView {
                    NewbornHealthView(baby: baby)
                }
                .tabItem {
                    Label("Yenidoğan", systemImage: "heart.text.square.fill")
                }
                .tag(19)
                
                NavigationView {
                    PostpartumDepressionView(baby: baby)
                }
                .tabItem {
                    Label("Ruh Sağlığı", systemImage: "brain.head.profile")
                }
                .tag(20)
                
                NavigationView {
                    HealthInstitutionsView(baby: baby)
                }
                .tabItem {
                    Label("Sağlık Kurumları", systemImage: "cross.case.fill")
                }
                .tag(21)
                
                NavigationView {
                    TasksView(baby: baby)
                }
                .tabItem {
                    Label("Görevler", systemImage: "checkmark.circle.fill")
                }
                .tag(22)
            }
        }
        .accentColor(babyManager.selectedBaby.map { ColorTheme.theme(for: $0.gender).primary } ?? Color(red: 1.0, green: 0.5, blue: 0.7))
    }
}

#Preview {
    ContentView()
}
