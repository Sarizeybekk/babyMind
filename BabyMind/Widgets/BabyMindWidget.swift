//
//  BabyMindWidget.swift
//  BabyMind
//
//  iOS Widget Extension
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct BabyMindWidgetEntry: TimelineEntry {
    let date: Date
    let baby: BabyWidgetData?
    let nextFeeding: Date?
    let lastFeeding: Date?
    let lastSleep: Date?
}

struct BabyWidgetData {
    let name: String
    let ageInWeeks: Int
    let ageInMonths: Int
    let gender: Baby.Gender
}

// MARK: - Timeline Provider
struct BabyMindTimelineProvider: TimelineProvider {
    typealias Entry = BabyMindWidgetEntry
    
    func placeholder(in context: Context) -> Entry {
        Entry(
            date: Date(),
            baby: BabyWidgetData(name: "Bebek", ageInWeeks: 12, ageInMonths: 3, gender: .female),
            nextFeeding: Date().addingTimeInterval(3600),
            lastFeeding: Date().addingTimeInterval(-7200),
            lastSleep: Date().addingTimeInterval(-1800)
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let entry = loadWidgetData()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentEntry = loadWidgetData()
        
        // Her 15 dakikada bir güncelle
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [currentEntry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadWidgetData() -> Entry {
        // UserDefaults'tan bebek bilgilerini yükle
        guard let babyData = UserDefaults(suiteName: "group.com.babymind.app")?.data(forKey: "selectedBaby"),
              let baby = try? JSONDecoder().decode(Baby.self, from: babyData) else {
            return Entry(date: Date(), baby: nil, nextFeeding: nil, lastFeeding: nil, lastSleep: nil)
        }
        
        // Son aktiviteleri yükle
        let lastFeeding = loadLastActivity(type: "feeding")
        let lastSleep = loadLastActivity(type: "sleep")
        let nextFeeding = calculateNextFeeding(lastFeeding: lastFeeding)
        
        let ageInWeeks = Calendar.current.dateComponents([.weekOfYear], from: baby.birthDate, to: Date()).weekOfYear ?? 0
        let ageInMonths = Calendar.current.dateComponents([.month], from: baby.birthDate, to: Date()).month ?? 0
        
        let widgetData = BabyWidgetData(
            name: baby.name,
            ageInWeeks: ageInWeeks,
            ageInMonths: ageInMonths,
            gender: baby.gender
        )
        
        return Entry(
            date: Date(),
            baby: widgetData,
            nextFeeding: nextFeeding,
            lastFeeding: lastFeeding,
            lastSleep: lastSleep
        )
    }
    
    private func loadLastActivity(type: String) -> Date? {
        guard let userDefaults = UserDefaults(suiteName: "group.com.babymind.app"),
              let timestamp = userDefaults.object(forKey: "last\(type.capitalized)") as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }
    
    private func calculateNextFeeding(lastFeeding: Date?) -> Date? {
        guard let lastFeeding = lastFeeding else { return nil }
        // Ortalama 3 saatte bir beslenme varsayımı
        return Calendar.current.date(byAdding: .hour, value: 3, to: lastFeeding)
    }
}

// MARK: - Widget Views

// Small Widget
struct BabyMindSmallWidget: View {
    var entry: BabyMindWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let baby = entry.baby {
            let theme = getTheme(for: baby.gender)
            
            ZStack {
                LinearGradient(
                    colors: theme.backgroundGradient,
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                VStack(spacing: 8) {
                    // Bebek adı ve yaşı
                    VStack(spacing: 4) {
                        Text(baby.name)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(theme.text)
                        
                        Text(formatAge(baby))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(theme.text.opacity(0.7))
                    }
                    
                    Divider()
                        .background(theme.primary.opacity(0.3))
                    
                    // Son beslenme
                    if let lastFeeding = entry.lastFeeding {
                        VStack(spacing: 4) {
                            HStack {
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 12))
                                    .foregroundColor(theme.primary)
                                Text("Son Beslenme")
                                    .font(.system(size: 10, weight: .medium, design: .rounded))
                                    .foregroundColor(theme.text.opacity(0.7))
                            }
                            
                            Text(timeAgo(from: lastFeeding))
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(theme.text)
                        }
                    }
                }
                .padding()
            }
        } else {
            EmptyWidgetView()
        }
    }
    
    private func getTheme(for gender: Baby.Gender) -> ColorTheme {
        ColorTheme.theme(for: gender)
    }
    
    private func formatAge(_ baby: BabyWidgetData) -> String {
        if baby.ageInMonths > 0 {
            return "\(baby.ageInMonths) aylık"
        } else {
            return "\(baby.ageInWeeks) haftalık"
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        
        if hours > 0 {
            return "\(hours) saat önce"
        } else {
            return "\(minutes) dakika önce"
        }
    }
}

// Medium Widget
struct BabyMindMediumWidget: View {
    var entry: BabyMindWidgetEntry
    
    var body: some View {
        if let baby = entry.baby {
            let theme = getTheme(for: baby.gender)
            
            ZStack {
                LinearGradient(
                    colors: theme.backgroundGradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                HStack(spacing: 16) {
                    // Sol taraf - Bebek bilgileri
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(baby.name)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(theme.text)
                            
                            Text(formatAge(baby))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(theme.text.opacity(0.7))
                        }
                        
                        Divider()
                            .background(theme.primary.opacity(0.3))
                        
                        // Son aktiviteler
                        VStack(alignment: .leading, spacing: 8) {
                            if let lastFeeding = entry.lastFeeding {
                                ActivityRow(
                                    icon: "fork.knife",
                                    title: "Son Beslenme",
                                    time: timeAgo(from: lastFeeding),
                                    theme: theme
                                )
                            }
                            
                            if let lastSleep = entry.lastSleep {
                                ActivityRow(
                                    icon: "bed.double.fill",
                                    title: "Son Uyku",
                                    time: timeAgo(from: lastSleep),
                                    theme: theme
                                )
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Sağ taraf - Sonraki hatırlatıcı
                    if let nextFeeding = entry.nextFeeding {
                        VStack(spacing: 8) {
                            Text("Sonraki")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(theme.text.opacity(0.7))
                            
                            Image(systemName: "bell.fill")
                                .font(.system(size: 24))
                                .foregroundColor(theme.primary)
                            
                            Text(timeUntil(from: nextFeeding))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(theme.text)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.primary.opacity(0.15))
                        )
                    }
                }
                .padding()
            }
        } else {
            EmptyWidgetView()
        }
    }
    
    private func getTheme(for gender: Baby.Gender) -> ColorTheme {
        ColorTheme.theme(for: gender)
    }
    
    private func formatAge(_ baby: BabyWidgetData) -> String {
        if baby.ageInMonths > 0 {
            return "\(baby.ageInMonths) aylık"
        } else {
            return "\(baby.ageInWeeks) haftalık"
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        
        if hours > 0 {
            return "\(hours) saat önce"
        } else {
            return "\(minutes) dakika önce"
        }
    }
    
    private func timeUntil(from date: Date) -> String {
        let interval = date.timeIntervalSince(Date())
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        
        if hours > 0 {
            return "\(hours) saat"
        } else if minutes > 0 {
            return "\(minutes) dk"
        } else {
            return "Şimdi"
        }
    }
}

// Large Widget
struct BabyMindLargeWidget: View {
    var entry: BabyMindWidgetEntry
    
    var body: some View {
        if let baby = entry.baby {
            let theme = getTheme(for: baby.gender)
            
            ZStack {
                LinearGradient(
                    colors: theme.backgroundGradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(spacing: 16) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(baby.name)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(theme.text)
                            
                            Text(formatAge(baby))
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(theme.text.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        // Yaş badge
                        Text("\(baby.ageInWeeks) hafta")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(theme.primary)
                            )
                    }
                    
                    Divider()
                        .background(theme.primary.opacity(0.3))
                    
                    // Aktivite kartları
                    VStack(spacing: 12) {
                        if let lastFeeding = entry.lastFeeding {
                            ActivityCard(
                                icon: "fork.knife",
                                title: "Son Beslenme",
                                time: timeAgo(from: lastFeeding),
                                theme: theme
                            )
                        }
                        
                        if let lastSleep = entry.lastSleep {
                            ActivityCard(
                                icon: "bed.double.fill",
                                title: "Son Uyku",
                                time: timeAgo(from: lastSleep),
                                theme: theme
                            )
                        }
                        
                        if let nextFeeding = entry.nextFeeding {
                            NextFeedingCard(
                                time: timeUntil(from: nextFeeding),
                                date: nextFeeding,
                                theme: theme
                            )
                        }
                    }
                }
                .padding()
            }
        } else {
            EmptyWidgetView()
        }
    }
    
    private func getTheme(for gender: Baby.Gender) -> ColorTheme {
        ColorTheme.theme(for: gender)
    }
    
    private func formatAge(_ baby: BabyWidgetData) -> String {
        if baby.ageInMonths > 0 {
            return "\(baby.ageInMonths) aylık"
        } else {
            return "\(baby.ageInWeeks) haftalık"
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        
        if hours > 0 {
            return "\(hours) saat önce"
        } else {
            return "\(minutes) dakika önce"
        }
    }
    
    private func timeUntil(from date: Date) -> String {
        let interval = date.timeIntervalSince(Date())
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        
        if hours > 0 {
            return "\(hours) saat sonra"
        } else if minutes > 0 {
            return "\(minutes) dakika sonra"
        } else {
            return "Şimdi"
        }
    }
}

// MARK: - Helper Views
struct ActivityRow: View {
    let icon: String
    let title: String
    let time: String
    let theme: ColorTheme
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(theme.primary)
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(theme.text.opacity(0.7))
            
            Spacer()
            
            Text(time)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(theme.text)
        }
    }
}

struct ActivityCard: View {
    let icon: String
    let title: String
    let time: String
    let theme: ColorTheme
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(theme.primary.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(theme.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(theme.text.opacity(0.7))
                
                Text(time)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(theme.text)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.3))
        )
    }
}

struct NextFeedingCard: View {
    let time: String
    let date: Date
    let theme: ColorTheme
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(theme.primary)
                    .frame(width: 40, height: 40)
                
                Image(systemName: "bell.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Sonraki Beslenme")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(theme.text.opacity(0.7))
                
                Text(time)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(theme.primary)
            }
            
            Spacer()
            
            Text(date, style: .time)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(theme.text.opacity(0.7))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.primary.opacity(0.15))
        )
    }
}

struct EmptyWidgetView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Bebek bilgisi ekleyin")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}

// MARK: - Widget Configuration
// NOT: @main attribute sadece Widget Extension target'ında olmalı
// Bu dosya widget extension'a eklendiğinde aşağıdaki kodu ekleyin:
//
// @main
// struct BabyMindWidgetBundle: WidgetBundle {
//     var body: some Widget {
//         BabyMindWidget()
//     }
// }

struct BabyMindWidget: Widget {
    let kind: String = "BabyMindWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BabyMindTimelineProvider()) { entry in
            BabyMindWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("BabyMind")
        .description("Bebeğinizin son aktivitelerini ve hatırlatıcılarını görüntüleyin.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct BabyMindWidgetEntryView: View {
    var entry: BabyMindWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            BabyMindSmallWidget(entry: entry)
        case .systemMedium:
            BabyMindMediumWidget(entry: entry)
        case .systemLarge:
            BabyMindLargeWidget(entry: entry)
        default:
            BabyMindSmallWidget(entry: entry)
        }
    }
}

// MARK: - Date Helper Extension
extension Date {
    func encodeToData() -> Data? {
        return try? JSONEncoder().encode(timeIntervalSince1970)
    }
    
    static func decodeFromData(_ data: Data) -> Date? {
        guard let timestamp = try? JSONDecoder().decode(Double.self, from: data) else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }
}

