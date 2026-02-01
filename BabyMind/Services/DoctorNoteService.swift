//
//  DoctorNoteService.swift
//  BabyMind
//
//  Doktor notları servisi
//

import Foundation
import Combine

class DoctorNoteService: ObservableObject {
    @Published var notes: [DoctorNote] = []
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadNotes()
    }
    
    func addNote(_ note: DoctorNote) {
        notes.append(note)
        notes.sort { $0.date > $1.date }
        saveNotes()
    }
    
    func updateNote(_ note: DoctorNote) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            notes.sort { $0.date > $1.date }
            saveNotes()
        }
    }
    
    func deleteNote(_ note: DoctorNote) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
    
    func getUpcomingAppointments() -> [DoctorNote] {
        let now = Date()
        return notes.filter { note in
            if let nextAppointment = note.nextAppointment {
                return nextAppointment >= now
            }
            return false
        }
        .sorted { ($0.nextAppointment ?? Date()) < ($1.nextAppointment ?? Date()) }
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "doctorNotes_\(babyId.uuidString)")
        }
    }
    
    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: "doctorNotes_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([DoctorNote].self, from: data) {
            notes = decoded.sorted { $0.date > $1.date }
        }
    }
}







