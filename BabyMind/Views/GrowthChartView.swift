//
//  GrowthChartView.swift
//  BabyMind
//
//  Büyüme grafikleri görünümü (WHO percentile)
//

import SwiftUI

struct GrowthChartView: View {
    let baby: Baby
    @StateObject private var percentileService: GrowthPercentileService
    @State private var growthData: [GrowthData] = []
    @State private var selectedMetric: GrowthMetric = .weight
    @State private var showAddData = false
    @State private var showHeadCircumference = false
    
    enum GrowthMetric: String, CaseIterable {
        case weight = "Ağırlık"
        case height = "Boy"
        case headCircumference = "Baş Çevresi"
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    init(baby: Baby) {
        self.baby = baby
        _percentileService = StateObject(wrappedValue: GrowthPercentileService(babyId: baby.id, isMale: baby.gender == .male))
    }
    
    var body: some View {
        let theme = ColorTheme.theme(for: baby.gender)
        return ZStack {
            // Gradient Arka Plan
            LinearGradient(
                colors: theme.backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Persentil ve Trend Özeti
                    PercentileSummaryCard(percentileService: percentileService, baby: baby, theme: theme)
                        .padding(.horizontal, 20)
                    
                    // Büyüme Uyarıları
                    let alerts = percentileService.checkAbnormalGrowth()
                    if !alerts.isEmpty {
                        GrowthAlertsCard(alerts: alerts, theme: theme)
                            .padding(.horizontal, 20)
                    }
                    
                    // Metrik seçici
                    Picker("Metrik", selection: $selectedMetric) {
                        ForEach(GrowthMetric.allCases, id: \.self) { metric in
                            Text(metric.rawValue).tag(metric)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 24)
                    
                    // Büyüme Hızı
                    GrowthRateCard(
                        percentileService: percentileService,
                        metric: selectedMetric,
                        theme: theme
                    )
                    .padding(.horizontal, 20)
                    
                    // Grafik kartı
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(selectedMetric == .weight ? "Ağırlık Gelişimi" : "Boy Gelişimi")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                            
                            Spacer()
                            
                            Button(action: {
                                showAddData = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(theme.primary)
                            }
                        }
                        
                        if growthData.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                                
                                Text("Henüz veri yok")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.45))
                                
                                Text("Bebeğinizin büyümesini takip etmek için veri ekleyin")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(Color(red: 0.6, green: 0.5, blue: 0.55))
                                    .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    showAddData = true
                                }) {
                                    Text("İlk Veriyi Ekle")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(
                                            LinearGradient(
                                                colors: [
                                                    theme.primary,
                                                    theme.primaryDark
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(20)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                        } else {
                            // Basit grafik gösterimi
                            GrowthChart(data: growthData, metric: selectedMetric, baby: baby)
                                .frame(height: 300)
                        }
                        
                        // Percentile bilgisi
                        if let latestData = growthData.first {
                            PercentileInfoCard(
                                data: latestData,
                                metric: selectedMetric,
                                baby: baby
                            )
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: theme.cardShadow, radius: 15, x: 0, y: 5)
                    )
                    .padding(.horizontal, 24)
                    
                    // Geçmiş veriler
                    if !growthData.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Geçmiş Ölçümler")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                                .padding(.horizontal, 24)
                            
                            ForEach(growthData.prefix(5)) { data in
                                GrowthDataRow(data: data, metric: selectedMetric, theme: theme)
                                    .padding(.horizontal, 24)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Büyüme Takibi")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddData) {
            AddGrowthDataView(baby: baby, onSave: { newData in
                growthData.insert(newData, at: 0)
                growthData.sort { $0.date > $1.date }
                
                // GrowthPercentileService'e de ekle
                let ageInMonths = Calendar.current.dateComponents([.month], from: baby.birthDate, to: newData.date).month ?? 0
                let record = GrowthRecord(
                    babyId: baby.id,
                    date: newData.date,
                    weight: newData.weight,
                    height: newData.height,
                    headCircumference: newData.headCircumference,
                    ageInMonths: ageInMonths
                )
                percentileService.addRecord(record)
            })
        }
        .onAppear {
            loadGrowthData()
            // GrowthPercentileService'den verileri yükle
            syncGrowthData()
        }
    }
    
    private func syncGrowthData() {
        // GrowthPercentileService'deki verileri GrowthData'ya dönüştür
        for record in percentileService.growthRecords {
            let data = GrowthData(
                date: record.date,
                weight: record.weight,
                height: record.height,
                headCircumference: record.headCircumference
            )
            if !growthData.contains(where: { $0.id == data.id }) {
                growthData.append(data)
            }
        }
        growthData.sort { $0.date > $1.date }
    }
}

// Analytics Circles View - Görüntüdeki gibi
struct AnalyticsCirclesView: View {
    let baby: Baby
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 40) {
            // Age Circle (Büyük, ortada)
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(theme.primary.opacity(0.15))
                        .frame(width: 200, height: 200)
                    
                    VStack(spacing: 4) {
                        Text(ageString)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(theme.primary)
                        
                        Text("Age")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Weight and Height Circles (Yanlarda)
            HStack(spacing: 30) {
                // Weight Circle
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.2, green: 0.7, blue: 0.8).opacity(0.15))
                            .frame(width: 140, height: 140)
                        
                        VStack(spacing: 4) {
                            Text(weightString)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.8))
                            
                            Text("Weight")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Height Circle
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.15))
                            .frame(width: 140, height: 140)
                        
                        VStack(spacing: 4) {
                            Text(heightString)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                            
                            Text("Height")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    private var ageString: String {
        if baby.ageInMonths < 12 {
            return "\(baby.ageInMonths)m"
        } else {
            let years = baby.ageInMonths / 12
            let months = baby.ageInMonths % 12
            if months == 0 {
                return "\(years)y"
            } else {
                return "\(years)y \(months)m"
            }
        }
    }
    
    private var weightString: String {
        let weight = baby.currentWeight ?? baby.birthWeight
        return String(format: "%.2fkg", weight)
    }
    
    private var heightString: String {
        let height = baby.currentHeight ?? baby.birthHeight
        return String(format: "%.0fcm", height)
    }
}

extension GrowthChartView {
    func loadGrowthData() {
        // Örnek veri - gerçek uygulamada UserDefaults veya CoreData'dan yüklenecek
        if growthData.isEmpty {
            // İlk veri olarak doğum verilerini ekle
            let birthData = GrowthData(
                date: baby.birthDate,
                weight: baby.birthWeight,
                height: baby.birthHeight
            )
            growthData.append(birthData)
            
            if let currentWeight = baby.currentWeight,
               let currentHeight = baby.currentHeight {
                let currentData = GrowthData(
                    date: Date(),
                    weight: currentWeight,
                    height: currentHeight
                )
                growthData.append(currentData)
            }
        }
    }
}

struct GrowthChart: View {
    let data: [GrowthData]
    let metric: GrowthChartView.GrowthMetric
    let baby: Baby
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid çizgileri
                Path { path in
                    for i in 0...4 {
                        let y = geometry.size.height / 4 * CGFloat(i)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                }
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                
                // Veri çizgisi
                if data.count > 1 {
                    Path { path in
                        let sortedData = data.sorted { $0.date < $1.date }
                        let maxValue = sortedData.map { metric == .weight ? $0.weight : $0.height }.max() ?? 1
                        let minValue = sortedData.map { metric == .weight ? $0.weight : $0.height }.min() ?? 0
                        let range = maxValue - minValue
                        
                        for (index, point) in sortedData.enumerated() {
                            let value = metric == .weight ? point.weight : point.height
                            let x = geometry.size.width / CGFloat(sortedData.count - 1) * CGFloat(index)
                            let y = geometry.size.height - ((value - minValue) / range * geometry.size.height)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(
                        LinearGradient(
                            colors: [
                                theme.primary,
                                theme.primaryDark
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    
                    // Noktalar
                    ForEach(Array(sortedData.enumerated()), id: \.element.id) { index, point in
                        let _ = metric == .weight ? point.weight : point.height
                        let maxValue = sortedData.map { metric == .weight ? $0.weight : $0.height }.max() ?? 1
                        let minValue = sortedData.map { metric == .weight ? $0.weight : $0.height }.min() ?? 0
                        let range = maxValue - minValue
                        let pointValue = metric == .weight ? point.weight : point.height
                        let x = geometry.size.width / CGFloat(sortedData.count - 1) * CGFloat(index)
                        let y = geometry.size.height - ((pointValue - minValue) / range * geometry.size.height)
                        
                        Circle()
                            .fill(theme.primary)
                            .frame(width: 10, height: 10)
                            .position(x: x, y: y)
                    }
                }
            }
        }
    }
    
    private var sortedData: [GrowthData] {
        data.sorted { $0.date < $1.date }
    }
}

struct PercentileInfoCard: View {
    let data: GrowthData
    let metric: GrowthChartView.GrowthMetric
    let baby: Baby
    
    var percentile: GrowthPercentile {
        let ageInWeeks = Calendar.current.dateComponents([.weekOfYear], from: baby.birthDate, to: data.date).weekOfYear ?? 0
        let value = metric == .weight ? data.weight : data.height
        return GrowthCalculator.calculatePercentile(
            ageInWeeks: ageInWeeks,
            weight: data.weight,
            height: data.height,
            gender: baby.gender
        )
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Percentile")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.45))
                
                Text("\(Int(metric == .weight ? percentile.weight : percentile.height))%")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(metric == .weight ? percentile.weightCategory : percentile.heightCategory)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                
                Text("\(String(format: "%.2f", metric == .weight ? data.weight : data.height)) \(metric == .weight ? "kg" : "cm")")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.45))
            }
        }
        .padding(16)
        .background(Color(red: 0.98, green: 0.95, blue: 0.98))
        .cornerRadius(12)
    }
}

struct GrowthDataRow: View {
    let data: GrowthData
    let metric: GrowthChartView.GrowthMetric
    let theme: ColorTheme
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(data.date, style: .date)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                
                Text(data.date, style: .time)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.45))
            }
            
            Spacer()
            
            Text("\(String(format: "%.2f", metric == .weight ? data.weight : data.height)) \(metric == .weight ? "kg" : "cm")")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(theme.primary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.pink.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Persentil Özet Kartı
struct PercentileSummaryCard: View {
    @ObservedObject var percentileService: GrowthPercentileService
    let baby: Baby
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20))
                    .foregroundColor(theme.primary)
                
                Text("WHO Persentil Analizi")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            if let latest = percentileService.growthRecords.last {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    PercentileMiniCard(
                        title: "Ağırlık",
                        value: latest.weight,
                        unit: "kg",
                        percentile: latest.getWeightPercentile(isMale: baby.gender == .male),
                        color: Color(red: 0.2, green: 0.7, blue: 0.9)
                    )
                    
                    PercentileMiniCard(
                        title: "Boy",
                        value: latest.height,
                        unit: "cm",
                        percentile: latest.getHeightPercentile(isMale: baby.gender == .male),
                        color: Color(red: 0.3, green: 0.8, blue: 0.5)
                    )
                    
                    if let hc = latest.headCircumference, let hcPercentile = latest.getHeadCircumferencePercentile(isMale: baby.gender == .male) {
                        PercentileMiniCard(
                            title: "Baş Çevresi",
                            value: hc,
                            unit: "cm",
                            percentile: hcPercentile,
                            color: Color(red: 0.9, green: 0.6, blue: 0.3)
                        )
                    }
                }
            } else {
                Text("Henüz ölçüm kaydı yok")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
        )
    }
}

struct PercentileMiniCard: View {
    let title: String
    let value: Double
    let unit: String
    let percentile: Double?
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
            
            Text(String(format: "%.2f", value))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            
            Text(unit)
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(.secondary)
            
            if let percentile = percentile {
                Text("%\(Int(percentile))")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(red: 0.25, green: 0.25, blue: 0.3) : Color(red: 0.98, green: 0.98, blue: 0.99))
        )
    }
}

// MARK: - Büyüme Uyarıları Kartı
struct GrowthAlertsCard: View {
    let alerts: [GrowthPercentileService.GrowthAlert]
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                
                Text("Büyüme Uyarıları")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                
                Spacer()
            }
            
            ForEach(Array(alerts.enumerated()), id: \.offset) { _, alert in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                    
                    Text(alert.message)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.25))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 1.0, green: 0.95, blue: 0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 1.0, green: 0.4, blue: 0.4).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Büyüme Hızı Kartı
struct GrowthRateCard: View {
    @ObservedObject var percentileService: GrowthPercentileService
    let metric: GrowthChartView.GrowthMetric
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var growthRate: Double? {
        let growthMetric: GrowthPercentileService.GrowthMetric
        switch metric {
        case .weight:
            growthMetric = .weight
        case .height:
            growthMetric = .height
        case .headCircumference:
            growthMetric = .headCircumference
        }
        return percentileService.getGrowthRate(metric: growthMetric)
    }
    
    var body: some View {
        if let rate = growthRate {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 18))
                        .foregroundColor(theme.primary)
                    
                    Text("Büyüme Hızı (Son 30 Gün)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    Spacer()
                }
                
                HStack {
                    Text(metric == .weight ? String(format: "+%.2f kg/ay", rate) : 
                         metric == .height ? String(format: "+%.1f cm/ay", rate) :
                         String(format: "+%.1f cm/ay", rate))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(theme.primary)
                    
                    Spacer()
                    
                    if rate > 0 {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                    } else {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
    }
}

struct AddGrowthDataView: View {
    let baby: Baby
    let onSave: (GrowthData) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var headCircumference: String = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Ölçüm Bilgileri") {
                    DatePicker("Tarih", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    HStack {
                        Text("Ağırlık (kg)")
                        Spacer()
                        TextField("0.00", text: $weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Boy (cm)")
                        Spacer()
                        TextField("0.0", text: $height)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Baş Çevresi (cm)")
                        Spacer()
                        TextField("Opsiyonel", text: $headCircumference)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }
            }
            .navigationTitle("Yeni Ölçüm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        if let weightValue = Double(weight),
                           let heightValue = Double(height) {
                            let hc = headCircumference.isEmpty ? nil : Double(headCircumference)
                            let newData = GrowthData(
                                date: date,
                                weight: weightValue,
                                height: heightValue,
                                headCircumference: hc
                            )
                            onSave(newData)
                            dismiss()
                        }
                    }
                    .disabled(weight.isEmpty || height.isEmpty)
                }
            }
        }
    }
}

