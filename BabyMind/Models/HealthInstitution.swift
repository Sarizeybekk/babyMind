//
//  HealthInstitution.swift
//
//  Sağlık kurumu modeli
//

import Foundation
import CoreLocation

struct HealthInstitution: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: InstitutionType
    let address: String
    let city: String
    let district: String?
    let phone: String
    let emergencyPhone: String?
    let latitude: Double?
    let longitude: Double?
    let website: String?
    let workingHours: String?
    let services: [String] // Hizmetler: "Acil Servis", "Çocuk Doktoru", "Aşı", vb.
    let is24Hours: Bool
    let notes: String?
    
    enum InstitutionType: String, Codable, CaseIterable {
        case hospital = "Hastane"
        case clinic = "Sağlık Ocağı"
        case pharmacy = "Eczane"
        case emergency = "Acil Servis"
        case privateClinic = "Özel Klinik"
        case laboratory = "Laboratuvar"
        case radiology = "Radyoloji"
        case vaccinationCenter = "Aşı Merkezi"
        
        var icon: String {
            switch self {
            case .hospital: return "cross.case.fill"
            case .clinic: return "stethoscope"
            case .pharmacy: return "pills.fill"
            case .emergency: return "cross.case.circle.fill"
            case .privateClinic: return "building.2.fill"
            case .laboratory: return "testtube.2"
            case .radiology: return "waveform.path.ecg"
            case .vaccinationCenter: return "syringe"
            }
        }
        
        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .hospital: return (0.2, 0.6, 0.9) // Mavi
            case .clinic: return (0.3, 0.7, 0.4) // Yeşil
            case .pharmacy: return (0.9, 0.5, 0.2) // Turuncu
            case .emergency: return (1.0, 0.2, 0.2) // Kırmızı
            case .privateClinic: return (0.6, 0.4, 0.9) // Mor
            case .laboratory: return (0.4, 0.7, 0.9) // Açık Mavi
            case .radiology: return (0.8, 0.6, 0.4) // Kahverengi
            case .vaccinationCenter: return (0.2, 0.8, 0.5) // Yeşil
            }
        }
    }
    
    var location: CLLocation? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocation(latitude: lat, longitude: lon)
    }
    
    init(id: UUID = UUID(),
         name: String,
         type: InstitutionType,
         address: String,
         city: String,
         district: String? = nil,
         phone: String,
         emergencyPhone: String? = nil,
         latitude: Double? = nil,
         longitude: Double? = nil,
         website: String? = nil,
         workingHours: String? = nil,
         services: [String] = [],
         is24Hours: Bool = false,
         notes: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.address = address
        self.city = city
        self.district = district
        self.phone = phone
        self.emergencyPhone = emergencyPhone
        self.latitude = latitude
        self.longitude = longitude
        self.website = website
        self.workingHours = workingHours
        self.services = services
        self.is24Hours = is24Hours
        self.notes = notes
    }
}
