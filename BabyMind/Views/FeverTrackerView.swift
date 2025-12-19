//
//  FeverTrackerView.swift
//  BabyMind
//
//  Ateş takip görünümü
//

import SwiftUI
import Charts

struct FeverTrackerView: View {
    let baby: Baby
    @StateObject private var feverService: FeverService
    @State private var showAddFever = false
    @State private var selectedRecord: FeverRecord?
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case day = "Gün"
        case week = "Hafta"
        case month = "Ay"
    }
    
    init(baby: Baby) {
        self.baby = baby
        _feverService = StateObject(wrappedValue: FeverService(babyId: baby.id))
    }
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: theme.backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Özet Kartlar
                    summaryCards
                    
                    // Grafik
                    feverChart
                    
                    // Son Kayıtlar
                    recentRecords
                }
                .padding()
            }
        }
        .navigationTitle("Ateş Takibi")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddFever = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(theme.primary)
                }
            }
        }
        .sheet(isPresented: $showAddFever) {
            AddFeverRecordView(baby: baby, feverService: feverService, theme: theme)
        }
        .sheet(item: $selectedRecord) { record in
            FeverRecordDetailView(record: record, feverService: feverService, theme: theme)
        }
    }
    
    @ViewBuilder
    private var summaryCards: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                SummaryCard(
                    title: "Son Ateş",
                    value: lastTemperature,
                    subtitle: lastTemperatureTime,
                    icon: "thermometer",
                    color: lastTemperatureColor,
                    theme: theme
                )
                
                SummaryCard(
                    title: "Ortalama (7 gün)",
                    value: averageTemperature,
                    subtitle: nil,
                    icon: "chart.line.uptrend.xyaxis",
                    color: theme.primary,
                    theme: theme
                )
            }
            
            if let highest = feverService.getHighestTemperature() {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("En Yüksek: \(String(format: "%.1f", highest.temperature))°C")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    Text("(\(highest.date, style: .date))")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.1))
                )
            }
        }
    }
    
    @ViewBuilder
    private var feverChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Ateş Grafiği")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(theme.text)
                
                Spacer()
                
                Picker("Zaman", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
            }
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(chartData) { data in
                        LineMark(
                            x: .value("Tarih", data.date),
                            y: .value("Ateş", data.temperature)
                        )
                        .foregroundStyle(theme.primary)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Tarih", data.date),
                            y: .value("Ateş", data.temperature)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [theme.primary.opacity(0.3), theme.primary.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Tarih", data.date),
                            y: .value("Ateş", data.temperature)
                        )
                        .foregroundStyle(theme.primary)
                        .symbolSize(60)
                    }
                    
                    // Normal ateş çizgisi
                    RuleMark(y: .value("Normal", 37.0))
                        .foregroundStyle(.green.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    
                    // Yüksek ateş çizgisi
                    RuleMark(y: .value("Yüksek", 38.5))
                        .foregroundStyle(.red.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                }
                .frame(height: 250)
                .chartYScale(domain: 35.0...40.0)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day().hour())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let temp = value.as(Double.self) {
                                Text("\(String(format: "%.1f", temp))°")
                                    .font(.system(size: 10))
                            }
                        }
                    }
                }
            } else {
                // iOS 15 için basit görünüm
                Text("Grafik iOS 16+ gerektirir")
                    .foregroundColor(.gray)
                    .frame(height: 250)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: theme.cardShadow, radius: 10, x: 0, y: 3)
        )
    }
    
    @ViewBuilder
    private var recentRecords: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Son Kayıtlar")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)
            
            if filteredRecords.isEmpty {
                EmptyFeverRecordsView(theme: theme)
            } else {
                ForEach(filteredRecords) { record in
                    FeverRecordRow(record: record, theme: theme) {
                        selectedRecord = record
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: theme.cardShadow, radius: 10, x: 0, y: 3)
        )
    }
    
    private var chartData: [FeverChartData] {
        let records = filteredRecords.sorted { $0.date < $1.date }
        return records.map { FeverChartData(date: $0.date, temperature: $0.temperature) }
    }
    
    private var filteredRecords: [FeverRecord] {
        let cutoffDate: Date
        switch selectedTimeRange {
        case .day:
            cutoffDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        case .week:
            cutoffDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        case .month:
            cutoffDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        }
        return feverService.records.filter { $0.date >= cutoffDate }
    }
    
    private var lastTemperature: String {
        guard let last = feverService.records.first else {
            return "-"
        }
        return String(format: "%.1f°C", last.temperature)
    }
    
    private var lastTemperatureTime: String? {
        guard let last = feverService.records.first else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: last.date)
    }
    
    private var lastTemperatureColor: Color {
        guard let last = feverService.records.first else {
            return .gray
        }
        switch last.severity {
        case .normal: return .green
        case .low: return .yellow
        case .moderate: return .orange
        case .high, .veryHigh: return .red
        }
    }
    
    private var averageTemperature: String {
        guard let avg = feverService.getAverageTemperature() else {
            return "-"
        }
        return String(format: "%.1f°C", avg)
    }
}

struct FeverChartData: Identifiable {
    let id = UUID()
    let date: Date
    let temperature: Double
}

struct SummaryCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let color: Color
    let theme: ColorTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)
            
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(theme.text.opacity(0.7))
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(theme.text.opacity(0.5))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: theme.cardShadow, radius: 10, x: 0, y: 3)
        )
    }
}

struct FeverRecordRow: View {
    let record: FeverRecord
    let theme: ColorTheme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Ateş ikonu
                ZStack {
                    Circle()
                        .fill(severityColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "thermometer")
                        .font(.system(size: 24))
                        .foregroundColor(severityColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(String(format: "%.1f°C", record.temperature))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(theme.text)
                        
                        Spacer()
                        
                        Text(record.date, style: .time)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(theme.text.opacity(0.5))
                    }
                    
                    HStack {
                        Text(record.measurementLocation.rawValue)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(theme.text.opacity(0.7))
                        
                        if record.isHighFever {
                            Text("• Yüksek Ateş")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(theme.text.opacity(0.3))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var severityColor: Color {
        switch record.severity {
        case .normal: return .green
        case .low: return .yellow
        case .moderate: return .orange
        case .high, .veryHigh: return .red
        }
    }
}

struct EmptyFeverRecordsView: View {
    let theme: ColorTheme
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "thermometer")
                .font(.system(size: 50))
                .foregroundColor(theme.text.opacity(0.3))
            
            Text("Henüz ateş kaydı yok")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(theme.text.opacity(0.5))
            
            Text("İlk ateş ölçümünüzü ekleyin")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(theme.text.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Add Fever Record View
struct AddFeverRecordView: View {
    let baby: Baby
    @ObservedObject var feverService: FeverService
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    
    @State private var temperature: String = ""
    @State private var selectedLocation: FeverRecord.MeasurementLocation = .armpit
    @State private var notes: String = ""
    @State private var medicationGiven: Bool = false
    @State private var medicationName: String = ""
    @State private var medicationTime: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Ateş Ölçümü") {
                    HStack {
                        TextField("Ateş (°C)", text: $temperature)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        
                        Text("°C")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(theme.text.opacity(0.7))
                    }
                    
                    Picker("Ölçüm Yeri", selection: $selectedLocation) {
                        ForEach(FeverRecord.MeasurementLocation.allCases, id: \.self) { location in
                            Text(location.rawValue).tag(location)
                        }
                    }
                    
                    DatePicker("Tarih ve Saat", selection: .constant(Date()), displayedComponents: [.date, .hourAndMinute])
                        .disabled(true)
                }
                
                Section("Notlar") {
                    TextField("Notlar (opsiyonel)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("İlaç Bilgisi") {
                    Toggle("İlaç Verildi", isOn: $medicationGiven)
                    
                    if medicationGiven {
                        TextField("İlaç Adı", text: $medicationName)
                        DatePicker("İlaç Verilme Zamanı", selection: $medicationTime, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                if let temp = Double(temperature), temp >= 38.5 {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Yüksek ateş tespit edildi! Doktora danışmanız önerilir.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Ateş Kaydı Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveRecord()
                    }
                    .disabled(temperature.isEmpty || Double(temperature) == nil)
                }
            }
        }
    }
    
    private func saveRecord() {
        guard let temp = Double(temperature) else { return }
        
        let record = FeverRecord(
            babyId: baby.id,
            temperature: temp,
            measurementLocation: selectedLocation,
            date: Date(),
            notes: notes.isEmpty ? nil : notes,
            medicationGiven: medicationGiven,
            medicationName: medicationName.isEmpty ? nil : medicationName,
            medicationTime: medicationGiven ? medicationTime : nil
        )
        
        feverService.addRecord(record)
        HapticManager.shared.notification(type: .success)
        dismiss()
    }
}

// MARK: - Fever Record Detail View
struct FeverRecordDetailView: View {
    let record: FeverRecord
    @ObservedObject var feverService: FeverService
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Ateş değeri
                    VStack(spacing: 8) {
                        Text(String(format: "%.1f°C", record.temperature))
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(severityColor)
                        
                        Text(record.severity.description)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(theme.text.opacity(0.7))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(severityColor.opacity(0.1))
                    )
                    
                    // Detaylar
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(title: "Ölçüm Yeri", value: record.measurementLocation.rawValue, theme: theme)
                        DetailRow(title: "Tarih", value: record.date, dateStyle: .date, theme: theme)
                        DetailRow(title: "Saat", value: record.date, dateStyle: .time, theme: theme)
                        
                        if let notes = record.notes {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notlar")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.text.opacity(0.7))
                                Text(notes)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(theme.text)
                            }
                        }
                        
                        if record.medicationGiven {
                            Divider()
                            VStack(alignment: .leading, spacing: 8) {
                                Text("İlaç Bilgisi")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.text.opacity(0.7))
                                
                                if let medName = record.medicationName {
                                    Text("İlaç: \(medName)")
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(theme.text)
                                }
                                
                                if let medTime = record.medicationTime {
                                    Text("Zaman: \(medTime, style: .time)")
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(theme.text)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: theme.cardShadow, radius: 10, x: 0, y: 3)
                    )
                }
                .padding()
            }
            .navigationTitle("Ateş Kaydı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive, action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
            .alert("Kaydı Sil", isPresented: $showDeleteAlert) {
                Button("İptal", role: .cancel) { }
                Button("Sil", role: .destructive) {
                    feverService.deleteRecord(record)
                    dismiss()
                }
            } message: {
                Text("Bu ateş kaydını silmek istediğinizden emin misiniz?")
            }
        }
    }
    
    private var severityColor: Color {
        switch record.severity {
        case .normal: return .green
        case .low: return .yellow
        case .moderate: return .orange
        case .high, .veryHigh: return .red
        }
    }
}


