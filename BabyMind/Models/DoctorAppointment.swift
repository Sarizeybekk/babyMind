//
//  DoctorAppointment.swift
//  BabyMind
//
//  Doktor randevu modeli
//

import Foundation

struct DoctorAppointment: Identifiable, Codable, Equatable {
    let id: UUID
    var doctorName: String
    var specialty: String
    var clinicName: String
    var address: String
    var phoneNumber: String
    var date: Date
    var notes: String
    var isCompleted: Bool
    var reminderId: UUID?
    var babyId: UUID
    
    init(id: UUID = UUID(),
         doctorName: String = "",
         specialty: String = "",
         clinicName: String = "",
         address: String = "",
         phoneNumber: String = "",
         date: Date = Date(),
         notes: String = "",
         isCompleted: Bool = false,
         reminderId: UUID? = nil,
         babyId: UUID) {
        self.id = id
        self.doctorName = doctorName
        self.specialty = specialty
        self.clinicName = clinicName
        self.address = address
        self.phoneNumber = phoneNumber
        self.date = date
        self.notes = notes
        self.isCompleted = isCompleted
        self.reminderId = reminderId
        self.babyId = babyId
    }
}

