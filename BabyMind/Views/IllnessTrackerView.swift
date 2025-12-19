//
//  IllnessTrackerView.swift
//  BabyMind
//
//  Hastalık takip görünümü
//

import SwiftUI

struct IllnessTrackerView: View {
    let baby: Baby
    @StateObject private var illnessService: IllnessService
    @State private var showAddIllness = false
    @State private var selectedIllness: Illness?
    @State private var showActiveOnly = false
    
    init(baby: Baby) {
        self.baby = baby
        _illnessService = StateObject(wrappedValue: IllnessService(babyId: baby.id))
    }
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    var filteredIllnesses: [Illness] {
        if showActiveOnly {
            return illnessService.getActiveIllnesses()
        }
        return illnessService.illnesses
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: theme.backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if filteredIllnesses.isEmpty {
                EmptyIllnessesView(theme: theme, onAdd: {
                    showAddIllness = true
                })
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Filtre
                        Toggle("Sadece Aktif Hastalıklar", isOn: $showActiveOnly)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: theme.cardShadow, radius: 10, x: 0, y: 3)
                            )
                        
                        // Hastalık Listesi
                        ForEach(filteredIllnesses) { illness in
                            IllnessCard(illness: illness, theme: theme) {
                                selectedIllness = illness
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Hastalık Takibi")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddIllness = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(theme.primary)
                }
            }
        }
        .sheet(isPresented: $showAddIllness) {
            AddIllnessView(baby: baby, illnessService: illnessService, theme: theme)
        }
        .sheet(item: $selectedIllness) { illness in
            IllnessDetailView(illness: illness, illnessService: illnessService, theme: theme)
        }
    }
}

struct IllnessCard: View {
    let illness: Illness
    let theme: ColorTheme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(illness.name)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(theme.text)
                    
                    Spacer()
                    
                    if illness.isActive {
                        Text("Aktif")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color.red)
                            )
                    } else {
                        Text("İyileşti")
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
                    Text("Başlangıç: \(illness.startDate, style: .date)")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(theme.text.opacity(0.7))
                    
                    if let endDate = illness.endDate {
                        Text("• Bitiş: \(endDate, style: .date)")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(theme.text.opacity(0.7))
                    }
                }
                
                if !illness.symptoms.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(illness.symptoms.prefix(5), id: \.self) { symptom in
                                Text(symptom.rawValue)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(theme.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(theme.primary.opacity(0.15))
                                    )
                            }
                        }
                    }
                }
                
                if illness.doctorVisited {
                    HStack {
                        Image(systemName: "stethoscope")
                            .font(.system(size: 12))
                        Text("Doktor ziyareti")
                            .font(.system(size: 12, design: .rounded))
                    }
                    .foregroundColor(theme.text.opacity(0.6))
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

struct EmptyIllnessesView: View {
    let theme: ColorTheme
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "cross.case.fill")
                .font(.system(size: 60))
                .foregroundColor(theme.primary.opacity(0.5))
            
            Text("Henüz hastalık kaydı yok")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)
            
            Text("Bebeğinizin hastalık geçmişini takip edin")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(theme.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onAdd) {
                Text("Hastalık Ekle")
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

// MARK: - Add/Edit Illness Views
struct AddIllnessView: View {
    let baby: Baby
    @ObservedObject var illnessService: IllnessService
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date? = nil
    @State private var isActive: Bool = true
    @State private var selectedSymptoms: Set<Illness.Symptom> = []
    @State private var notes: String = ""
    @State private var doctorVisited: Bool = false
    @State private var doctorName: String = ""
    @State private var medications: [String] = []
    @State private var newMedication: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Hastalık Bilgisi") {
                    TextField("Hastalık adı (örn: Nezle, Grip)", text: $name)
                    
                    DatePicker("Başlangıç Tarihi", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Toggle("Hala devam ediyor", isOn: $isActive)
                    
                    if !isActive {
                        DatePicker("Bitiş Tarihi", selection: Binding(
                            get: { endDate ?? Date() },
                            set: { endDate = $0 }
                        ), displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section("Semptomlar") {
                    ForEach(Illness.Symptom.allCases, id: \.self) { symptom in
                        Toggle(symptom.rawValue, isOn: Binding(
                            get: { selectedSymptoms.contains(symptom) },
                            set: { isOn in
                                if isOn {
                                    selectedSymptoms.insert(symptom)
                                } else {
                                    selectedSymptoms.remove(symptom)
                                }
                            }
                        ))
                    }
                }
                
                Section("Doktor Bilgisi") {
                    Toggle("Doktora gidildi", isOn: $doctorVisited)
                    
                    if doctorVisited {
                        TextField("Doktor adı", text: $doctorName)
                    }
                }
                
                Section("İlaçlar") {
                    ForEach(medications, id: \.self) { medication in
                        HStack {
                            Text(medication)
                            Spacer()
                            Button(action: {
                                medications.removeAll { $0 == medication }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    HStack {
                        TextField("İlaç adı", text: $newMedication)
                        Button("Ekle") {
                            if !newMedication.isEmpty {
                                medications.append(newMedication)
                                newMedication = ""
                            }
                        }
                        .disabled(newMedication.isEmpty)
                    }
                }
                
                Section("Notlar") {
                    TextField("Notlar (opsiyonel)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Hastalık Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveIllness()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveIllness() {
        let illness = Illness(
            babyId: baby.id,
            name: name,
            startDate: startDate,
            endDate: isActive ? nil : endDate,
            symptoms: Array(selectedSymptoms),
            notes: notes.isEmpty ? nil : notes,
            doctorVisited: doctorVisited,
            doctorName: doctorName.isEmpty ? nil : doctorName,
            medications: medications
        )
        
        illnessService.addIllness(illness)
        HapticManager.shared.notification(type: .success)
        dismiss()
    }
}

struct IllnessDetailView: View {
    let illness: Illness
    @ObservedObject var illnessService: IllnessService
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false
    @State private var showEdit = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Hastalık Bilgileri
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(illness.name)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(theme.text)
                            
                            Spacer()
                            
                            if illness.isActive {
                                Text("Aktif")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color.red)
                                    )
                            }
                        }
                        
                        DetailRow(title: "Başlangıç", value: illness.startDate, dateStyle: .date, theme: theme)
                        
                        if let endDate = illness.endDate {
                            DetailRow(title: "Bitiş", value: endDate, dateStyle: .date, theme: theme)
                            
                            if let duration = illness.duration {
                                DetailRow(title: "Süre", value: "\(duration) gün", theme: theme)
                            }
                        }
                        
                        if !illness.symptoms.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Semptomlar")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.text)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                    ForEach(illness.symptoms, id: \.self) { symptom in
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(theme.primary)
                                            Text(symptom.rawValue)
                                                .font(.system(size: 14, design: .rounded))
                                                .foregroundColor(theme.text)
                                        }
                                    }
                                }
                            }
                        }
                        
                        if illness.doctorVisited, let doctorName = illness.doctorName {
                            DetailRow(title: "Doktor", value: doctorName, theme: theme)
                        }
                        
                        if !illness.medications.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Kullanılan İlaçlar")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.text)
                                
                                ForEach(illness.medications, id: \.self) { medication in
                                    HStack {
                                        Image(systemName: "pills.fill")
                                            .foregroundColor(theme.primary)
                                        Text(medication)
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(theme.text)
                                    }
                                }
                            }
                        }
                        
                        if let notes = illness.notes {
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
            .navigationTitle("Hastalık Detayı")
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
            .alert("Hastalığı Sil", isPresented: $showDeleteAlert) {
                Button("İptal", role: .cancel) { }
                Button("Sil", role: .destructive) {
                    illnessService.deleteIllness(illness)
                    dismiss()
                }
            } message: {
                Text("Bu hastalık kaydını silmek istediğinizden emin misiniz?")
            }
        }
    }
}

