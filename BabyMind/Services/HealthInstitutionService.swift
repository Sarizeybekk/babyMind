//
//  HealthInstitutionService.swift
//
//  Sağlık kurumu servisi
//

import Foundation
import Combine
import CoreLocation

class HealthInstitutionService: ObservableObject {
    @Published var institutions: [HealthInstitution] = []
    @Published var userLocation: CLLocation?
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadData()
        initializeDefaultInstitutions()
    }
    
    func initializeDefaultInstitutions() {
        // Demo verileri - gerçek uygulamada API'den çekilecek
        if institutions.isEmpty {
            institutions = [
                // İSTANBUL - Hastaneler
                HealthInstitution(
                    name: "İstanbul Çocuk Hastanesi",
                    type: .hospital,
                    address: "Çapa, Fatih",
                    city: "İstanbul",
                    district: "Fatih",
                    phone: "0212 414 20 00",
                    emergencyPhone: "112",
                    latitude: 41.0082,
                    longitude: 28.9784,
                    website: "https://istanbulcocukhastanesi.gov.tr",
                    workingHours: "24 Saat",
                    services: ["Acil Servis", "Çocuk Doktoru", "Aşı", "Yenidoğan Bakımı"],
                    is24Hours: true
                ),
                HealthInstitution(
                    name: "Acıbadem Çocuk Hastanesi",
                    type: .hospital,
                    address: "Kozyatağı",
                    city: "İstanbul",
                    district: "Kadıköy",
                    phone: "0216 555 00 00",
                    emergencyPhone: "112",
                    latitude: 40.9700,
                    longitude: 29.1000,
                    services: ["Acil Servis", "Çocuk Doktoru", "Özel Muayene"],
                    is24Hours: true
                ),
                HealthInstitution(
                    name: "Memorial Çocuk Hastanesi",
                    type: .hospital,
                    address: "Şişli",
                    city: "İstanbul",
                    district: "Şişli",
                    phone: "0212 314 66 66",
                    emergencyPhone: "112",
                    latitude: 41.0600,
                    longitude: 28.9800,
                    services: ["Acil Servis", "Çocuk Doktoru"],
                    is24Hours: true
                ),
                HealthInstitution(
                    name: "Liv Hospital Çocuk Kliniği",
                    type: .hospital,
                    address: "Ulus",
                    city: "İstanbul",
                    district: "Beşiktaş",
                    phone: "0212 373 00 00",
                    emergencyPhone: "112",
                    latitude: 41.0400,
                    longitude: 29.0100,
                    services: ["Acil Servis", "Çocuk Doktoru", "Özel Muayene"],
                    is24Hours: true
                ),
                HealthInstitution(
                    name: "Florence Nightingale Çocuk Hastanesi",
                    type: .hospital,
                    address: "Gayrettepe",
                    city: "İstanbul",
                    district: "Beşiktaş",
                    phone: "0212 288 00 00",
                    emergencyPhone: "112",
                    latitude: 41.0700,
                    longitude: 29.0000,
                    services: ["Acil Servis", "Çocuk Doktoru"],
                    is24Hours: true
                ),
                
                // ANKARA - Hastaneler
                HealthInstitution(
                    name: "Ankara Çocuk Sağlığı ve Hastalıkları EAH",
                    type: .hospital,
                    address: "Altındağ",
                    city: "Ankara",
                    district: "Altındağ",
                    phone: "0312 595 70 00",
                    emergencyPhone: "112",
                    latitude: 39.9334,
                    longitude: 32.8597,
                    services: ["Acil Servis", "Çocuk Doktoru", "Aşı"],
                    is24Hours: true
                ),
                HealthInstitution(
                    name: "Ankara Üniversitesi Çocuk Hastanesi",
                    type: .hospital,
                    address: "Cebeci",
                    city: "Ankara",
                    district: "Altındağ",
                    phone: "0312 595 60 00",
                    emergencyPhone: "112",
                    latitude: 39.9400,
                    longitude: 32.8700,
                    services: ["Acil Servis", "Çocuk Doktoru", "Aşı"],
                    is24Hours: true
                ),
                HealthInstitution(
                    name: "Gazi Üniversitesi Çocuk Hastanesi",
                    type: .hospital,
                    address: "Emek",
                    city: "Ankara",
                    district: "Yenimahalle",
                    phone: "0312 202 60 00",
                    emergencyPhone: "112",
                    latitude: 39.9500,
                    longitude: 32.8200,
                    services: ["Acil Servis", "Çocuk Doktoru"],
                    is24Hours: true
                ),
                
                // İZMİR - Hastaneler
                HealthInstitution(
                    name: "İzmir Çocuk Hastanesi",
                    type: .hospital,
                    address: "Konak",
                    city: "İzmir",
                    district: "Konak",
                    phone: "0232 489 50 00",
                    emergencyPhone: "112",
                    latitude: 38.4237,
                    longitude: 27.1428,
                    services: ["Acil Servis", "Çocuk Doktoru"],
                    is24Hours: true
                ),
                HealthInstitution(
                    name: "Ege Üniversitesi Çocuk Hastanesi",
                    type: .hospital,
                    address: "Bornova",
                    city: "İzmir",
                    district: "Bornova",
                    phone: "0232 390 00 00",
                    emergencyPhone: "112",
                    latitude: 38.4500,
                    longitude: 27.2200,
                    services: ["Acil Servis", "Çocuk Doktoru", "Aşı"],
                    is24Hours: true
                ),
                
                // BURSA - Hastaneler
                HealthInstitution(
                    name: "Bursa Çocuk Hastanesi",
                    type: .hospital,
                    address: "Osmangazi",
                    city: "Bursa",
                    district: "Osmangazi",
                    phone: "0224 295 00 00",
                    emergencyPhone: "112",
                    latitude: 40.1900,
                    longitude: 29.0500,
                    services: ["Acil Servis", "Çocuk Doktoru"],
                    is24Hours: true
                ),
                
                // ANTALYA - Hastaneler
                HealthInstitution(
                    name: "Antalya Çocuk Hastanesi",
                    type: .hospital,
                    address: "Muratpaşa",
                    city: "Antalya",
                    district: "Muratpaşa",
                    phone: "0242 249 00 00",
                    emergencyPhone: "112",
                    latitude: 36.8900,
                    longitude: 30.7000,
                    services: ["Acil Servis", "Çocuk Doktoru"],
                    is24Hours: true
                ),
                
                // İSTANBUL - Sağlık Ocakları
                HealthInstitution(
                    name: "Merkez Aile Sağlığı Merkezi",
                    type: .clinic,
                    address: "Bağdat Caddesi No:123",
                    city: "İstanbul",
                    district: "Kadıköy",
                    phone: "0216 345 67 89",
                    latitude: 40.9850,
                    longitude: 29.0280,
                    workingHours: "08:00 - 17:00",
                    services: ["Aşı", "Çocuk Takibi", "Genel Muayene"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Bostancı Aile Sağlığı Merkezi",
                    type: .clinic,
                    address: "Bostancı Mahallesi",
                    city: "İstanbul",
                    district: "Kadıköy",
                    phone: "0216 456 78 90",
                    latitude: 40.9600,
                    longitude: 29.1100,
                    workingHours: "08:00 - 17:00",
                    services: ["Aşı", "Çocuk Takibi"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Beşiktaş Aile Sağlığı Merkezi",
                    type: .clinic,
                    address: "Beşiktaş Merkez",
                    city: "İstanbul",
                    district: "Beşiktaş",
                    phone: "0212 567 89 01",
                    latitude: 41.0500,
                    longitude: 29.0100,
                    workingHours: "08:00 - 17:00",
                    services: ["Aşı", "Genel Muayene"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Şişli Aile Sağlığı Merkezi",
                    type: .clinic,
                    address: "Şişli Merkez",
                    city: "İstanbul",
                    district: "Şişli",
                    phone: "0212 678 90 12",
                    latitude: 41.0550,
                    longitude: 28.9850,
                    workingHours: "08:00 - 17:00",
                    services: ["Aşı", "Çocuk Takibi"],
                    is24Hours: false
                ),
                
                // ANKARA - Sağlık Ocakları
                HealthInstitution(
                    name: "Çocuk Sağlığı Merkezi",
                    type: .clinic,
                    address: "Atatürk Bulvarı No:45",
                    city: "Ankara",
                    district: "Çankaya",
                    phone: "0312 123 45 67",
                    latitude: 39.9250,
                    longitude: 32.8600,
                    workingHours: "08:00 - 17:00",
                    services: ["Aşı", "Çocuk Takibi"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Kızılay Aile Sağlığı Merkezi",
                    type: .clinic,
                    address: "Kızılay Merkez",
                    city: "Ankara",
                    district: "Çankaya",
                    phone: "0312 234 56 78",
                    latitude: 39.9200,
                    longitude: 32.8550,
                    workingHours: "08:00 - 17:00",
                    services: ["Aşı", "Genel Muayene"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Yenimahalle Aile Sağlığı Merkezi",
                    type: .clinic,
                    address: "Yenimahalle Merkez",
                    city: "Ankara",
                    district: "Yenimahalle",
                    phone: "0312 345 67 89",
                    latitude: 39.9600,
                    longitude: 32.8100,
                    workingHours: "08:00 - 17:00",
                    services: ["Aşı", "Çocuk Takibi"],
                    is24Hours: false
                ),
                
                // İZMİR - Sağlık Ocakları
                HealthInstitution(
                    name: "Aile Sağlığı Merkezi",
                    type: .clinic,
                    address: "Kordon Boyu",
                    city: "İzmir",
                    district: "Konak",
                    phone: "0232 456 78 90",
                    latitude: 38.4300,
                    longitude: 27.1500,
                    workingHours: "08:00 - 17:00",
                    services: ["Aşı", "Genel Muayene"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Bornova Aile Sağlığı Merkezi",
                    type: .clinic,
                    address: "Bornova Merkez",
                    city: "İzmir",
                    district: "Bornova",
                    phone: "0232 567 89 01",
                    latitude: 38.4600,
                    longitude: 27.2100,
                    workingHours: "08:00 - 17:00",
                    services: ["Aşı", "Çocuk Takibi"],
                    is24Hours: false
                ),
                
                // BURSA - Sağlık Ocakları
                HealthInstitution(
                    name: "Bursa Aile Sağlığı Merkezi",
                    type: .clinic,
                    address: "Osmangazi Merkez",
                    city: "Bursa",
                    district: "Osmangazi",
                    phone: "0224 123 45 67",
                    latitude: 40.2000,
                    longitude: 29.0600,
                    workingHours: "08:00 - 17:00",
                    services: ["Aşı", "Genel Muayene"],
                    is24Hours: false
                ),
                
                // ANTALYA - Sağlık Ocakları
                HealthInstitution(
                    name: "Antalya Aile Sağlığı Merkezi",
                    type: .clinic,
                    address: "Muratpaşa Merkez",
                    city: "Antalya",
                    district: "Muratpaşa",
                    phone: "0242 234 56 78",
                    latitude: 36.9000,
                    longitude: 30.7100,
                    workingHours: "08:00 - 17:00",
                    services: ["Aşı", "Çocuk Takibi"],
                    is24Hours: false
                ),
                
                // İSTANBUL - Eczaneler
                HealthInstitution(
                    name: "Merkez Eczanesi",
                    type: .pharmacy,
                    address: "Bağdat Caddesi No:456",
                    city: "İstanbul",
                    district: "Kadıköy",
                    phone: "0216 234 56 78",
                    latitude: 40.9780,
                    longitude: 29.0400,
                    workingHours: "09:00 - 20:00",
                    services: ["İlaç", "Bebek Ürünleri"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Bostancı Eczanesi",
                    type: .pharmacy,
                    address: "Bostancı Mahallesi",
                    city: "İstanbul",
                    district: "Kadıköy",
                    phone: "0216 345 67 89",
                    latitude: 40.9650,
                    longitude: 29.1050,
                    workingHours: "09:00 - 20:00",
                    services: ["İlaç", "Bebek Ürünleri"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Nöbetçi Eczane - Şişli",
                    type: .pharmacy,
                    address: "Şişli Merkez",
                    city: "İstanbul",
                    district: "Şişli",
                    phone: "0212 456 78 90",
                    latitude: 41.0580,
                    longitude: 28.9880,
                    workingHours: "24 Saat",
                    services: ["İlaç", "Acil İlaç"],
                    is24Hours: true
                ),
                HealthInstitution(
                    name: "Beşiktaş Eczanesi",
                    type: .pharmacy,
                    address: "Beşiktaş Merkez",
                    city: "İstanbul",
                    district: "Beşiktaş",
                    phone: "0212 567 89 01",
                    latitude: 41.0450,
                    longitude: 29.0050,
                    workingHours: "09:00 - 20:00",
                    services: ["İlaç", "Bebek Ürünleri"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Nişantaşı Eczanesi",
                    type: .pharmacy,
                    address: "Nişantaşı",
                    city: "İstanbul",
                    district: "Şişli",
                    phone: "0212 678 90 12",
                    latitude: 41.0480,
                    longitude: 28.9900,
                    workingHours: "09:00 - 20:00",
                    services: ["İlaç"],
                    is24Hours: false
                ),
                
                // ANKARA - Eczaneler
                HealthInstitution(
                    name: "Nöbetçi Eczane",
                    type: .pharmacy,
                    address: "Tunalı Hilmi Caddesi No:78",
                    city: "Ankara",
                    district: "Çankaya",
                    phone: "0312 987 65 43",
                    latitude: 39.9150,
                    longitude: 32.8500,
                    workingHours: "24 Saat",
                    services: ["İlaç", "Acil İlaç"],
                    is24Hours: true
                ),
                HealthInstitution(
                    name: "Kızılay Eczanesi",
                    type: .pharmacy,
                    address: "Kızılay Merkez",
                    city: "Ankara",
                    district: "Çankaya",
                    phone: "0312 234 56 78",
                    latitude: 39.9180,
                    longitude: 32.8520,
                    workingHours: "09:00 - 20:00",
                    services: ["İlaç", "Bebek Ürünleri"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Çankaya Eczanesi",
                    type: .pharmacy,
                    address: "Çankaya Merkez",
                    city: "Ankara",
                    district: "Çankaya",
                    phone: "0312 345 67 89",
                    latitude: 39.9220,
                    longitude: 32.8580,
                    workingHours: "09:00 - 20:00",
                    services: ["İlaç"],
                    is24Hours: false
                ),
                
                // İZMİR - Eczaneler
                HealthInstitution(
                    name: "Çocuk Eczanesi",
                    type: .pharmacy,
                    address: "Alsancak",
                    city: "İzmir",
                    district: "Konak",
                    phone: "0232 321 54 76",
                    latitude: 38.4200,
                    longitude: 27.1400,
                    workingHours: "09:00 - 19:00",
                    services: ["İlaç", "Bebek Ürünleri"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Bornova Eczanesi",
                    type: .pharmacy,
                    address: "Bornova Merkez",
                    city: "İzmir",
                    district: "Bornova",
                    phone: "0232 432 65 87",
                    latitude: 38.4550,
                    longitude: 27.2150,
                    workingHours: "09:00 - 20:00",
                    services: ["İlaç"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Nöbetçi Eczane - İzmir",
                    type: .pharmacy,
                    address: "Konak Merkez",
                    city: "İzmir",
                    district: "Konak",
                    phone: "0232 543 76 98",
                    latitude: 38.4250,
                    longitude: 27.1450,
                    workingHours: "24 Saat",
                    services: ["İlaç", "Acil İlaç"],
                    is24Hours: true
                ),
                
                // BURSA - Eczaneler
                HealthInstitution(
                    name: "Bursa Eczanesi",
                    type: .pharmacy,
                    address: "Osmangazi Merkez",
                    city: "Bursa",
                    district: "Osmangazi",
                    phone: "0224 234 56 78",
                    latitude: 40.1950,
                    longitude: 29.0550,
                    workingHours: "09:00 - 20:00",
                    services: ["İlaç", "Bebek Ürünleri"],
                    is24Hours: false
                ),
                
                // ANTALYA - Eczaneler
                HealthInstitution(
                    name: "Antalya Eczanesi",
                    type: .pharmacy,
                    address: "Muratpaşa Merkez",
                    city: "Antalya",
                    district: "Muratpaşa",
                    phone: "0242 345 67 89",
                    latitude: 36.8950,
                    longitude: 30.7050,
                    workingHours: "09:00 - 20:00",
                    services: ["İlaç"],
                    is24Hours: false
                ),
                
                // İSTANBUL - Özel Klinikler
                HealthInstitution(
                    name: "Çocuk Sağlığı Özel Klinik",
                    type: .privateClinic,
                    address: "Nişantaşı Teşvikiye Caddesi",
                    city: "İstanbul",
                    district: "Şişli",
                    phone: "0212 555 12 34",
                    latitude: 41.0500,
                    longitude: 28.9900,
                    website: "https://example.com",
                    workingHours: "09:00 - 18:00",
                    services: ["Çocuk Doktoru", "Aşı", "Özel Muayene"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Kadıköy Özel Çocuk Kliniği",
                    type: .privateClinic,
                    address: "Kadıköy Merkez",
                    city: "İstanbul",
                    district: "Kadıköy",
                    phone: "0216 666 77 88",
                    latitude: 40.9900,
                    longitude: 29.0200,
                    workingHours: "09:00 - 18:00",
                    services: ["Çocuk Doktoru", "Özel Muayene"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Beşiktaş Özel Çocuk Kliniği",
                    type: .privateClinic,
                    address: "Beşiktaş Merkez",
                    city: "İstanbul",
                    district: "Beşiktaş",
                    phone: "0212 777 88 99",
                    latitude: 41.0420,
                    longitude: 29.0080,
                    workingHours: "09:00 - 18:00",
                    services: ["Çocuk Doktoru", "Aşı"],
                    is24Hours: false
                ),
                
                // ANKARA - Özel Klinikler
                HealthInstitution(
                    name: "Özel Çocuk Kliniği",
                    type: .privateClinic,
                    address: "Kızılay",
                    city: "Ankara",
                    district: "Çankaya",
                    phone: "0312 111 22 33",
                    latitude: 39.9300,
                    longitude: 32.8650,
                    workingHours: "09:00 - 18:00",
                    services: ["Çocuk Doktoru", "Özel Muayene"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Çankaya Özel Çocuk Kliniği",
                    type: .privateClinic,
                    address: "Çankaya Merkez",
                    city: "Ankara",
                    district: "Çankaya",
                    phone: "0312 222 33 44",
                    latitude: 39.9280,
                    longitude: 32.8620,
                    workingHours: "09:00 - 18:00",
                    services: ["Çocuk Doktoru", "Aşı"],
                    is24Hours: false
                ),
                
                // İZMİR - Özel Klinikler
                HealthInstitution(
                    name: "İzmir Özel Çocuk Kliniği",
                    type: .privateClinic,
                    address: "Alsancak",
                    city: "İzmir",
                    district: "Konak",
                    phone: "0232 333 44 55",
                    latitude: 38.4350,
                    longitude: 27.1450,
                    workingHours: "09:00 - 18:00",
                    services: ["Çocuk Doktoru", "Özel Muayene"],
                    is24Hours: false
                ),
                
                // İSTANBUL - Aşı Merkezleri
                HealthInstitution(
                    name: "İstanbul Aşı Merkezi",
                    type: .vaccinationCenter,
                    address: "Sarıyer",
                    city: "İstanbul",
                    district: "Sarıyer",
                    phone: "0212 777 88 99",
                    latitude: 41.1000,
                    longitude: 29.0500,
                    workingHours: "08:00 - 16:00",
                    services: ["Aşı", "Aşı Takibi"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Kadıköy Aşı Merkezi",
                    type: .vaccinationCenter,
                    address: "Kadıköy Merkez",
                    city: "İstanbul",
                    district: "Kadıköy",
                    phone: "0216 888 99 00",
                    latitude: 40.9800,
                    longitude: 29.0300,
                    workingHours: "08:00 - 16:00",
                    services: ["Aşı", "Aşı Takibi"],
                    is24Hours: false
                ),
                
                // ANKARA - Aşı Merkezleri
                HealthInstitution(
                    name: "Aşı Merkezi",
                    type: .vaccinationCenter,
                    address: "Sağlık Bakanlığı Binası",
                    city: "Ankara",
                    district: "Çankaya",
                    phone: "0312 444 55 66",
                    latitude: 39.9100,
                    longitude: 32.8450,
                    workingHours: "08:00 - 16:00",
                    services: ["Aşı", "Aşı Takibi"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Kızılay Aşı Merkezi",
                    type: .vaccinationCenter,
                    address: "Kızılay Merkez",
                    city: "Ankara",
                    district: "Çankaya",
                    phone: "0312 555 66 77",
                    latitude: 39.9160,
                    longitude: 32.8510,
                    workingHours: "08:00 - 16:00",
                    services: ["Aşı", "Aşı Takibi"],
                    is24Hours: false
                ),
                
                // İZMİR - Aşı Merkezleri
                HealthInstitution(
                    name: "İzmir Aşı Merkezi",
                    type: .vaccinationCenter,
                    address: "Konak Merkez",
                    city: "İzmir",
                    district: "Konak",
                    phone: "0232 666 77 88",
                    latitude: 38.4280,
                    longitude: 27.1480,
                    workingHours: "08:00 - 16:00",
                    services: ["Aşı", "Aşı Takibi"],
                    is24Hours: false
                ),
                
                // Laboratuvarlar
                HealthInstitution(
                    name: "İstanbul Çocuk Laboratuvarı",
                    type: .laboratory,
                    address: "Şişli",
                    city: "İstanbul",
                    district: "Şişli",
                    phone: "0212 999 00 11",
                    latitude: 41.0620,
                    longitude: 28.9820,
                    workingHours: "08:00 - 18:00",
                    services: ["Kan Tahlili", "İdrar Tahlili", "Bebek Tahlilleri"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Ankara Çocuk Laboratuvarı",
                    type: .laboratory,
                    address: "Çankaya",
                    city: "Ankara",
                    district: "Çankaya",
                    phone: "0312 777 88 99",
                    latitude: 39.9320,
                    longitude: 32.8630,
                    workingHours: "08:00 - 18:00",
                    services: ["Kan Tahlili", "İdrar Tahlili"],
                    is24Hours: false
                ),
                
                // Radyoloji Merkezleri
                HealthInstitution(
                    name: "İstanbul Çocuk Radyoloji",
                    type: .radiology,
                    address: "Kadıköy",
                    city: "İstanbul",
                    district: "Kadıköy",
                    phone: "0216 111 22 33",
                    latitude: 40.9750,
                    longitude: 29.0350,
                    workingHours: "08:00 - 17:00",
                    services: ["Ultrason", "Röntgen", "Bebek Görüntüleme"],
                    is24Hours: false
                ),
                HealthInstitution(
                    name: "Ankara Çocuk Radyoloji",
                    type: .radiology,
                    address: "Kızılay",
                    city: "Ankara",
                    district: "Çankaya",
                    phone: "0312 888 99 00",
                    latitude: 39.9240,
                    longitude: 32.8570,
                    workingHours: "08:00 - 17:00",
                    services: ["Ultrason", "Röntgen"],
                    is24Hours: false
                ),
                
                // Acil Servisler
                HealthInstitution(
                    name: "İstanbul Acil Servis",
                    type: .emergency,
                    address: "Fatih",
                    city: "İstanbul",
                    district: "Fatih",
                    phone: "112",
                    emergencyPhone: "112",
                    latitude: 41.0050,
                    longitude: 28.9750,
                    workingHours: "24 Saat",
                    services: ["Acil Müdahale", "Ambulans"],
                    is24Hours: true
                ),
                HealthInstitution(
                    name: "Ankara Acil Servis",
                    type: .emergency,
                    address: "Altındağ",
                    city: "Ankara",
                    district: "Altındağ",
                    phone: "112",
                    emergencyPhone: "112",
                    latitude: 39.9350,
                    longitude: 32.8610,
                    workingHours: "24 Saat",
                    services: ["Acil Müdahale", "Ambulans"],
                    is24Hours: true
                ),
                HealthInstitution(
                    name: "İzmir Acil Servis",
                    type: .emergency,
                    address: "Konak",
                    city: "İzmir",
                    district: "Konak",
                    phone: "112",
                    emergencyPhone: "112",
                    latitude: 38.4260,
                    longitude: 27.1430,
                    workingHours: "24 Saat",
                    services: ["Acil Müdahale", "Ambulans"],
                    is24Hours: true
                )
            ]
            saveData()
        }
    }
    
    func addInstitution(_ institution: HealthInstitution) {
        institutions.append(institution)
        saveData()
    }
    
    func deleteInstitution(_ institution: HealthInstitution) {
        institutions.removeAll { $0.id == institution.id }
        saveData()
    }
    
    func getNearbyInstitutions(radiusKm: Double = 10.0) -> [HealthInstitution] {
        guard let userLocation = userLocation else {
            return institutions.sorted { $0.name < $1.name }
        }
        
        return institutions
            .compactMap { institution -> (HealthInstitution, Double)? in
                guard let location = institution.location else { return nil }
                let distance = userLocation.distance(from: location) / 1000.0 // km
                if distance <= radiusKm {
                    return (institution, distance)
                }
                return nil
            }
            .sorted { $0.1 < $1.1 } // Mesafeye göre sırala
            .map { $0.0 }
    }
    
    func getInstitutionsByType(_ type: HealthInstitution.InstitutionType) -> [HealthInstitution] {
        return institutions.filter { $0.type == type }
            .sorted { $0.name < $1.name }
    }
    
    func getEmergencyServices() -> [HealthInstitution] {
        return institutions.filter { $0.type == .emergency || $0.is24Hours }
            .sorted { $0.name < $1.name }
    }
    
    func searchInstitutions(query: String) -> [HealthInstitution] {
        let lowerQuery = query.lowercased()
        return institutions.filter { institution in
            institution.name.lowercased().contains(lowerQuery) ||
            institution.address.lowercased().contains(lowerQuery) ||
            institution.city.lowercased().contains(lowerQuery) ||
            institution.district?.lowercased().contains(lowerQuery) ?? false ||
            institution.services.contains { $0.lowercased().contains(lowerQuery) }
        }
        .sorted { $0.name < $1.name }
    }
    
    func setUserLocation(_ location: CLLocation) {
        userLocation = location
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(institutions) {
            UserDefaults.standard.set(encoded, forKey: "healthInstitutions_\(babyId.uuidString)")
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "healthInstitutions_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([HealthInstitution].self, from: data) {
            institutions = decoded
        }
    }
}
