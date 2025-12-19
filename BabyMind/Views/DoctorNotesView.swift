//
//  DoctorNotesView.swift
//  BabyMind
//
//  Doktor notları görünümü
//

import SwiftUI

struct DoctorNotesView: View {
    let baby: Baby
    @StateObject private var noteService: DoctorNoteService
    @State private var showAddNote = false
    @State private var selectedNote: DoctorNote?
    
    init(baby: Baby) {
        self.baby = baby
        _noteService = StateObject(wrappedValue: DoctorNoteService(babyId: baby.id))
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
            
            if noteService.notes.isEmpty {
                EmptyDoctorNotesView(theme: theme, onAdd: {
                    showAddNote = true
                })
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Yaklaşan Randevular
                        if !noteService.getUpcomingAppointments().isEmpty {
                            upcomingAppointments
                        }
                        
                        // Tüm Notlar
                        allNotes
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Doktor Notları")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddNote = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(theme.primary)
                }
            }
        }
        .sheet(isPresented: $showAddNote) {
            AddDoctorNoteView(baby: baby, noteService: noteService, theme: theme)
        }
        .sheet(item: $selectedNote) { note in
            DoctorNoteDetailView(note: note, noteService: noteService, theme: theme)
        }
    }
    
    @ViewBuilder
    private var upcomingAppointments: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Yaklaşan Randevular")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)
            
            ForEach(noteService.getUpcomingAppointments()) { note in
                if let nextAppointment = note.nextAppointment {
                    UpcomingAppointmentCard(note: note, appointmentDate: nextAppointment, theme: theme) {
                        selectedNote = note
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
    
    @ViewBuilder
    private var allNotes: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tüm Notlar")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)
            
            ForEach(noteService.notes) { note in
                DoctorNoteCard(note: note, theme: theme) {
                    selectedNote = note
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
}

struct DoctorNoteCard: View {
    let note: DoctorNote
    let theme: ColorTheme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(note.doctorName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(theme.text)
                    
                    Spacer()
                    
                    Text(note.date, style: .date)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(theme.text.opacity(0.6))
                }
                
                if let specialty = note.specialty {
                    Text(specialty)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(theme.primary)
                }
                
                Text(note.reason)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(theme.text.opacity(0.8))
                    .lineLimit(2)
                
                if let diagnosis = note.diagnosis {
                    HStack {
                        Image(systemName: "stethoscope")
                            .font(.system(size: 12))
                        Text(diagnosis)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(theme.primary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct UpcomingAppointmentCard: View {
    let note: DoctorNote
    let appointmentDate: Date
    let theme: ColorTheme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(theme.primary.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 24))
                        .foregroundColor(theme.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.doctorName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(theme.text)
                    
                    Text(appointmentDate, style: .date)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(theme.text.opacity(0.7))
                    
                    Text(appointmentDate, style: .time)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(theme.primary)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.primary.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyDoctorNotesView: View {
    let theme: ColorTheme
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "stethoscope")
                .font(.system(size: 60))
                .foregroundColor(theme.primary.opacity(0.5))
            
            Text("Henüz doktor notu yok")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)
            
            Text("Doktor ziyaretlerinizi ve notlarınızı kaydedin")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(theme.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onAdd) {
                Text("Not Ekle")
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

// MARK: - Add/Edit Doctor Note Views
struct AddDoctorNoteView: View {
    let baby: Baby
    @ObservedObject var noteService: DoctorNoteService
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    
    @State private var doctorName: String = ""
    @State private var specialty: String = ""
    @State private var reason: String = ""
    @State private var diagnosis: String = ""
    @State private var notes: String = ""
    @State private var recommendations: [String] = []
    @State private var newRecommendation: String = ""
    @State private var date: Date = Date()
    @State private var hasNextAppointment: Bool = false
    @State private var nextAppointment: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Doktor Bilgisi") {
                    TextField("Doktor Adı", text: $doctorName)
                    TextField("Uzmanlık (opsiyonel)", text: $specialty)
                    DatePicker("Ziyaret Tarihi", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Ziyaret Bilgisi") {
                    TextField("Ziyaret Nedeni", text: $reason, axis: .vertical)
                        .lineLimit(2...4)
                    
                    TextField("Teşhis (opsiyonel)", text: $diagnosis, axis: .vertical)
                        .lineLimit(2...4)
                    
                    TextField("Notlar", text: $notes, axis: .vertical)
                        .lineLimit(4...8)
                }
                
                Section("Öneriler") {
                    ForEach(recommendations, id: \.self) { recommendation in
                        HStack {
                            Text(recommendation)
                            Spacer()
                            Button(action: {
                                recommendations.removeAll { $0 == recommendation }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    HStack {
                        TextField("Öneri ekle", text: $newRecommendation)
                        Button("Ekle") {
                            if !newRecommendation.isEmpty {
                                recommendations.append(newRecommendation)
                                newRecommendation = ""
                            }
                        }
                        .disabled(newRecommendation.isEmpty)
                    }
                }
                
                Section("Sonraki Randevu") {
                    Toggle("Sonraki randevu var", isOn: $hasNextAppointment)
                    
                    if hasNextAppointment {
                        DatePicker("Randevu Tarihi", selection: $nextAppointment, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("Doktor Notu Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveNote()
                    }
                    .disabled(doctorName.isEmpty || reason.isEmpty)
                }
            }
        }
    }
    
    private func saveNote() {
        let note = DoctorNote(
            babyId: baby.id,
            date: date,
            doctorName: doctorName,
            specialty: specialty.isEmpty ? nil : specialty,
            reason: reason,
            diagnosis: diagnosis.isEmpty ? nil : diagnosis,
            notes: notes.isEmpty ? nil : notes,
            recommendations: recommendations,
            nextAppointment: hasNextAppointment ? nextAppointment : nil
        )
        
        noteService.addNote(note)
        HapticManager.shared.notification(type: .success)
        dismiss()
    }
}

struct DoctorNoteDetailView: View {
    let note: DoctorNote
    @ObservedObject var noteService: DoctorNoteService
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Doktor Bilgileri
                    VStack(alignment: .leading, spacing: 16) {
                        Text(note.doctorName)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(theme.text)
                        
                        if let specialty = note.specialty {
                            Text(specialty)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(theme.primary)
                        }
                        
                        DetailRow(title: "Tarih", value: note.date, dateStyle: .date, theme: theme)
                        DetailRow(title: "Saat", value: note.date, dateStyle: .time, theme: theme)
                        DetailRow(title: "Neden", value: note.reason, theme: theme)
                        
                        if let diagnosis = note.diagnosis {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Teşhis")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.text)
                                Text(diagnosis)
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(theme.text.opacity(0.8))
                            }
                        }
                        
                        if let notes = note.notes {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notlar")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.text)
                                Text(notes)
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(theme.text.opacity(0.8))
                            }
                        }
                        
                        if !note.recommendations.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Öneriler")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.text)
                                
                                ForEach(note.recommendations, id: \.self) { recommendation in
                                    HStack(alignment: .top) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(theme.primary)
                                        Text(recommendation)
                                            .font(.system(size: 15, design: .rounded))
                                            .foregroundColor(theme.text)
                                    }
                                }
                            }
                        }
                        
                        if let nextAppointment = note.nextAppointment {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sonraki Randevu")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.text)
                                Text(nextAppointment, style: .date)
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(theme.primary)
                                Text(nextAppointment, style: .time)
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(theme.text.opacity(0.7))
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
            .navigationTitle("Doktor Notu")
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
            .alert("Notu Sil", isPresented: $showDeleteAlert) {
                Button("İptal", role: .cancel) { }
                Button("Sil", role: .destructive) {
                    noteService.deleteNote(note)
                    dismiss()
                }
            } message: {
                Text("Bu doktor notunu silmek istediğinizden emin misiniz?")
            }
        }
    }
}

