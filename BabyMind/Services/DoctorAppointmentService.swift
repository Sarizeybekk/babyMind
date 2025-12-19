//
//  DoctorAppointmentService.swift
//  BabyMind
//
//  Doktor randevu yönetim servisi
//

import Foundation
import Combine

class DoctorAppointmentService: ObservableObject {
    @Published var appointments: [DoctorAppointment] = []
    
    private let appointmentsKey = "savedDoctorAppointments"
    private let reminderService: ReminderService
    
    init(reminderService: ReminderService) {
        self.reminderService = reminderService
        loadAppointments()
    }
    
    func addAppointment(_ appointment: DoctorAppointment, createReminder: Bool = true) {
        var newAppointment = appointment
        
        // Hatırlatıcı oluştur
        if createReminder {
            let reminder = Reminder(
                title: "Doktor Randevusu: \(appointment.doctorName)",
                description: "\(appointment.specialty) - \(appointment.clinicName)",
                type: .doctor,
                date: appointment.date.addingTimeInterval(-24 * 60 * 60), // 24 saat önce hatırlat
                babyId: appointment.babyId
            )
            reminderService.addReminder(reminder)
            newAppointment.reminderId = reminder.id
        }
        
        appointments.append(newAppointment)
        saveAppointments()
    }
    
    func updateAppointment(_ appointment: DoctorAppointment) {
        if let index = appointments.firstIndex(where: { $0.id == appointment.id }) {
            appointments[index] = appointment
            saveAppointments()
        }
    }
    
    func deleteAppointment(_ appointment: DoctorAppointment) {
        // İlişkili hatırlatıcıyı sil
        if let reminderId = appointment.reminderId,
           let reminder = reminderService.reminders.first(where: { $0.id == reminderId }) {
            reminderService.deleteReminder(reminder)
        }
        
        appointments.removeAll { $0.id == appointment.id }
        saveAppointments()
    }
    
    func appointments(for babyId: UUID) -> [DoctorAppointment] {
        appointments.filter { $0.babyId == babyId }
            .sorted { $0.date < $1.date }
    }
    
    func upcomingAppointments(for babyId: UUID, limit: Int = 5) -> [DoctorAppointment] {
        let now = Date()
        return appointments(for: babyId)
            .filter { !$0.isCompleted && $0.date >= now }
            .prefix(limit)
            .map { $0 }
    }
    
    private func saveAppointments() {
        if let encoded = try? JSONEncoder().encode(appointments) {
            UserDefaults.standard.set(encoded, forKey: appointmentsKey)
        }
    }
    
    private func loadAppointments() {
        if let data = UserDefaults.standard.data(forKey: appointmentsKey),
           let decoded = try? JSONDecoder().decode([DoctorAppointment].self, from: data) {
            appointments = decoded
        }
    }
}

