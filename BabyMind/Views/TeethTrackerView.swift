//
//  TeethTrackerView.swift
//  BabyMind
//
//  Diş çıkarma takip görünümü
//

import SwiftUI

struct TeethTrackerView: View {
    let baby: Baby
    @StateObject private var teethService: TeethService
    @State private var showAddTooth = false
    @State private var selectedToothNumber: Int? = nil
    
    init(baby: Baby) {
        self.baby = baby
        _teethService = StateObject(wrappedValue: TeethService(babyId: baby.id))
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
                    // İstatistikler
                    teethStatistics
                    
                    // Diş Haritası
                    teethMap
                    
                    // Çıkan Dişler Listesi
                    eruptedTeethList
                }
                .padding()
            }
        }
        .navigationTitle("Diş Çıkarma")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddTooth = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(theme.primary)
                }
            }
        }
        .sheet(isPresented: $showAddTooth) {
            AddToothView(baby: baby, teethService: teethService, theme: theme, selectedToothNumber: selectedToothNumber)
        }
        .onChange(of: selectedToothNumber) { oldValue, newValue in
            if newValue != nil {
                showAddTooth = true
            }
        }
    }
    
    @ViewBuilder
    private var teethStatistics: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Çıkan Diş",
                value: "\(teethService.teeth.count)",
                icon: "mouth.fill",
                color: theme.primary,
                theme: theme
            )
            
            StatCard(
                title: "Kalan Diş",
                value: "\(20 - teethService.teeth.count)",
                icon: "circle.dashed",
                color: theme.text.opacity(0.5),
                theme: theme
            )
        }
    }
    
    @ViewBuilder
    private var teethMap: some View {
        VStack(spacing: 20) {
            Text("Diş Haritası")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)
            
            // Üst çene
            TeethRow(
                teeth: Array(ToothRecord.babyTeeth.prefix(10)),
                teethService: teethService,
                theme: theme
            ) { toothNumber in
                selectedToothNumber = toothNumber
            }
            
            // Alt çene
            TeethRow(
                teeth: Array(ToothRecord.babyTeeth.suffix(10)),
                teethService: teethService,
                theme: theme
            ) { toothNumber in
                selectedToothNumber = toothNumber
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
    private var eruptedTeethList: some View {
        if teethService.teeth.isEmpty {
            EmptyTeethView(theme: theme)
        } else {
            VStack(alignment: .leading, spacing: 16) {
                Text("Çıkan Dişler")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(theme.text)
                
                ForEach(teethService.teeth.sorted { $0.eruptionDate > $1.eruptionDate }) { tooth in
                    ToothRecordRow(tooth: tooth, theme: theme)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: theme.cardShadow, radius: 10, x: 0, y: 3)
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let theme: ColorTheme
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)
            
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(theme.text.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: theme.cardShadow, radius: 10, x: 0, y: 3)
        )
    }
}

struct TeethRow: View {
    let teeth: [(number: Int, name: String, position: (row: Int, col: Int))]
    @ObservedObject var teethService: TeethService
    let theme: ColorTheme
    let onToothTap: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(teeth, id: \.number) { toothInfo in
                ToothButton(
                    toothNumber: toothInfo.number,
                    toothName: toothInfo.name,
                    isErupted: teethService.hasTooth(by: toothInfo.number),
                    theme: theme
                ) {
                    onToothTap(toothInfo.number)
                }
            }
        }
    }
}

struct ToothButton: View {
    let toothNumber: Int
    let toothName: String
    let isErupted: Bool
    let theme: ColorTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isErupted ? theme.primary.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 30, height: 40)
                
                if isErupted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(theme.primary)
                } else {
                    Circle()
                        .stroke(theme.text.opacity(0.3), lineWidth: 2)
                        .frame(width: 16, height: 16)
                }
            }
        }
    }
}

struct ToothRecordRow: View {
    let tooth: ToothRecord
    let theme: ColorTheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(theme.primary.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "mouth.fill")
                    .font(.system(size: 24))
                    .foregroundColor(theme.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tooth.toothName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(theme.text)
                
                Text(tooth.eruptionDate, style: .date)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(theme.text.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

struct EmptyTeethView: View {
    let theme: ColorTheme
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "mouth")
                .font(.system(size: 50))
                .foregroundColor(theme.text.opacity(0.3))
            
            Text("Henüz diş çıkarma kaydı yok")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(theme.text.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Add Tooth View
struct AddToothView: View {
    let baby: Baby
    @ObservedObject var teethService: TeethService
    let theme: ColorTheme
    let selectedToothNumber: Int?
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTooth: (number: Int, name: String)? = nil
    @State private var eruptionDate: Date = Date()
    @State private var symptoms: [String] = []
    @State private var newSymptom: String = ""
    @State private var notes: String = ""
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section("Diş Seçimi") {
                    Picker("Diş", selection: Binding(
                        get: { selectedTooth?.number ?? (selectedToothNumber ?? 1) },
                        set: { number in
                            if let tooth = ToothRecord.babyTeeth.first(where: { $0.number == number }) {
                                selectedTooth = (tooth.number, tooth.name)
                            }
                        }
                    )) {
                        ForEach(ToothRecord.babyTeeth, id: \.number) { tooth in
                            Text(tooth.name).tag(tooth.number)
                        }
                    }
                    .onAppear {
                        if let number = selectedToothNumber,
                           let tooth = ToothRecord.babyTeeth.first(where: { $0.number == number }) {
                            selectedTooth = (tooth.number, tooth.name)
                        } else if selectedTooth == nil {
                            selectedTooth = (ToothRecord.babyTeeth.first!.number, ToothRecord.babyTeeth.first!.name)
                        }
                    }
                }
                
                Section("Çıkış Bilgisi") {
                    DatePicker("Çıkış Tarihi", selection: $eruptionDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Semptomlar") {
                    ForEach(symptoms, id: \.self) { symptom in
                        HStack {
                            Text(symptom)
                            Spacer()
                            Button(action: {
                                symptoms.removeAll { $0 == symptom }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    HStack {
                        TextField("Semptom ekle", text: $newSymptom)
                        Button("Ekle") {
                            if !newSymptom.isEmpty {
                                symptoms.append(newSymptom)
                                newSymptom = ""
                            }
                        }
                        .disabled(newSymptom.isEmpty)
                    }
                }
                
                Section("Notlar") {
                    TextField("Notlar (opsiyonel)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Diş Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveTooth()
                    }
                    .disabled(selectedTooth == nil)
                }
            }
        }
    }
    
    private func saveTooth() {
        guard let tooth = selectedTooth else { return }
        
        let photoData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        let toothRecord = ToothRecord(
            babyId: baby.id,
            toothNumber: tooth.number,
            toothName: tooth.name,
            eruptionDate: eruptionDate,
            symptoms: symptoms,
            photoData: photoData,
            notes: notes.isEmpty ? nil : notes
        )
        
        teethService.addTooth(toothRecord)
        HapticManager.shared.notification(type: .success)
        dismiss()
    }
}





