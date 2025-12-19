//
//  MedicineHistoryView.swift
//  BabyMind
//
//  İlaç geçmişi görünümü
//

import SwiftUI

struct MedicineHistoryView: View {
    let baby: Baby
    @StateObject private var medicineService: MedicineHistoryService
    @State private var showAddMedicine = false
    @State private var selectedMedicine: MedicineHistory?
    @State private var showActiveOnly = false
    
    init(baby: Baby) {
        self.baby = baby
        _medicineService = StateObject(wrappedValue: MedicineHistoryService(babyId: baby.id))
    }
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    var filteredMedicines: [MedicineHistory] {
        if showActiveOnly {
            return medicineService.getActiveMedicines()
        }
        return medicineService.medicines
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: theme.backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if filteredMedicines.isEmpty {
                EmptyMedicineHistoryView(theme: theme, onAdd: {
                    showAddMedicine = true
                })
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Filtre
                        Toggle("Sadece Aktif İlaçlar", isOn: $showActiveOnly)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: theme.cardShadow, radius: 10, x: 0, y: 3)
                            )
                        
                        // İlaç Listesi
                        ForEach(filteredMedicines) { medicine in
                            MedicineCard(medicine: medicine, theme: theme) {
                                selectedMedicine = medicine
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("İlaç Geçmişi")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddMedicine = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(theme.primary)
                }
            }
        }
        .sheet(isPresented: $showAddMedicine) {
            AddMedicineHistoryView(baby: baby, medicineService: medicineService, theme: theme)
        }
        .sheet(item: $selectedMedicine) { medicine in
            MedicineHistoryDetailView(medicine: medicine, medicineService: medicineService, theme: theme)
        }
    }
}

struct MedicineCard: View {
    let medicine: MedicineHistory
    let theme: ColorTheme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(medicine.name)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(theme.text)
                    
                    Spacer()
                    
                    if medicine.isActive {
                        Text("Aktif")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color.green)
                            )
                    }
                }
                
                HStack {
                    Text("Dozaj: \(medicine.dosage)")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(theme.text.opacity(0.7))
                    
                    Text("•")
                        .foregroundColor(theme.text.opacity(0.5))
                    
                    Text(medicine.frequency)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(theme.text.opacity(0.7))
                }
                
                if let reason = medicine.reason {
                    Text("Neden: \(reason)")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(theme.text.opacity(0.6))
                        .lineLimit(1)
                }
                
                if !medicine.sideEffects.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text("\(medicine.sideEffects.count) yan etki kaydedildi")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.orange)
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
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyMedicineHistoryView: View {
    let theme: ColorTheme
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "pills.fill")
                .font(.system(size: 60))
                .foregroundColor(theme.primary.opacity(0.5))
            
            Text("Henüz ilaç kaydı yok")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)
            
            Text("Bebeğinizin ilaç geçmişini takip edin")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(theme.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onAdd) {
                Text("İlaç Ekle")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [theme.primary, theme.primaryDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Add/Edit Medicine Views
struct AddMedicineHistoryView: View {
    let baby: Baby
    @ObservedObject var medicineService: MedicineHistoryService
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var frequency: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date? = nil
    @State private var isActive: Bool = true
    @State private var reason: String = ""
    @State private var doctorName: String = ""
    @State private var sideEffects: [String] = []
    @State private var newSideEffect: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("İlaç Bilgisi") {
                    TextField("İlaç Adı", text: $name)
                    TextField("Dozaj (örn: 5ml, 1 tablet)", text: $dosage)
                    TextField("Sıklık (örn: Günde 3 kez)", text: $frequency)
                }
                
                Section("Kullanım Süresi") {
                    DatePicker("Başlangıç", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Toggle("Hala kullanılıyor", isOn: $isActive)
                    
                    if !isActive {
                        DatePicker("Bitiş", selection: Binding(
                            get: { endDate ?? Date() },
                            set: { endDate = $0 }
                        ), displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section("Bilgiler") {
                    TextField("Kullanım nedeni (opsiyonel)", text: $reason)
                    TextField("Reçete eden doktor (opsiyonel)", text: $doctorName)
                }
                
                Section("Yan Etkiler") {
                    ForEach(sideEffects, id: \.self) { effect in
                        HStack {
                            Text(effect)
                            Spacer()
                            Button(action: {
                                sideEffects.removeAll { $0 == effect }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    HStack {
                        TextField("Yan etki ekle", text: $newSideEffect)
                        Button("Ekle") {
                            if !newSideEffect.isEmpty {
                                sideEffects.append(newSideEffect)
                                newSideEffect = ""
                            }
                        }
                        .disabled(newSideEffect.isEmpty)
                    }
                }
                
                Section("Notlar") {
                    TextField("Notlar (opsiyonel)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("İlaç Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveMedicine()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty || frequency.isEmpty)
                }
            }
        }
    }
    
    private func saveMedicine() {
        let medicine = MedicineHistory(
            babyId: baby.id,
            name: name,
            dosage: dosage,
            frequency: frequency,
            startDate: startDate,
            endDate: isActive ? nil : endDate,
            reason: reason.isEmpty ? nil : reason,
            doctorName: doctorName.isEmpty ? nil : doctorName,
            sideEffects: sideEffects,
            notes: notes.isEmpty ? nil : notes
        )
        
        medicineService.addMedicine(medicine)
        HapticManager.shared.notification(type: .success)
        dismiss()
    }
}

struct MedicineHistoryDetailView: View {
    let medicine: MedicineHistory
    @ObservedObject var medicineService: MedicineHistoryService
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // İlaç Bilgileri
                    VStack(alignment: .leading, spacing: 16) {
                        Text(medicine.name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(theme.text)
                        
                        DetailRow(title: "Dozaj", value: medicine.dosage, theme: theme)
                        DetailRow(title: "Sıklık", value: medicine.frequency, theme: theme)
                        DetailRow(title: "Başlangıç", value: medicine.startDate, dateStyle: .date, theme: theme)
                        
                        if let endDate = medicine.endDate {
                            DetailRow(title: "Bitiş", value: endDate, dateStyle: .date, theme: theme)
                            
                            if let duration = medicine.duration {
                                DetailRow(title: "Süre", value: "\(duration) gün", theme: theme)
                            }
                        }
                        
                        if let reason = medicine.reason {
                            DetailRow(title: "Kullanım Nedeni", value: reason, theme: theme)
                        }
                        
                        if let doctorName = medicine.doctorName {
                            DetailRow(title: "Doktor", value: doctorName, theme: theme)
                        }
                        
                        if !medicine.sideEffects.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Yan Etkiler")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.text)
                                
                                ForEach(medicine.sideEffects, id: \.self) { effect in
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                        Text(effect)
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(theme.text)
                                    }
                                }
                            }
                        }
                        
                        if let notes = medicine.notes {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notlar")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.text)
                                Text(notes)
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(theme.text.opacity(0.8))
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
            .navigationTitle("İlaç Detayı")
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
            .alert("İlacı Sil", isPresented: $showDeleteAlert) {
                Button("İptal", role: .cancel) { }
                Button("Sil", role: .destructive) {
                    medicineService.deleteMedicine(medicine)
                    dismiss()
                }
            } message: {
                Text("Bu ilaç kaydını silmek istediğinizden emin misiniz?")
            }
        }
    }
}





