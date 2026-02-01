//
//  HealthInstitutionsView.swift
//
//  Sağlık kurumları görünümü
//

import SwiftUI
import CoreLocation
import MapKit

struct HealthInstitutionsView: View {
    let baby: Baby
    @StateObject private var institutionService: HealthInstitutionService
    @State private var selectedType: HealthInstitution.InstitutionType? = nil
    @State private var searchText = ""
    @State private var showMap = false
    @State private var showAddInstitution = false
    @State private var locationManager = CLLocationManager()
    @State private var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @State private var selectedInstitution: HealthInstitution? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    init(baby: Baby) {
        self.baby = baby
        _institutionService = StateObject(wrappedValue: HealthInstitutionService(babyId: baby.id))
    }
    
    var filteredInstitutions: [HealthInstitution] {
        var institutions = institutionService.institutions
        
        // Arama filtresi
        if !searchText.isEmpty {
            institutions = institutionService.searchInstitutions(query: searchText)
        }
        
        // Tip filtresi
        if let type = selectedType {
            institutions = institutions.filter { $0.type == type }
        }
        
        // Konum varsa mesafeye göre sırala
        if institutionService.userLocation != nil {
            return institutionService.getNearbyInstitutions(radiusKm: 50.0)
                .filter { institution in
                    if let type = selectedType {
                        return institution.type == type
                    }
                    return true
                }
        }
        
        return institutions.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: getBackgroundGradient(),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header - Navigation bar ile çakışmaması için kaldırıldı
                // Navigation bar'da zaten "Sağlık Kurumları" yazıyor
                
                // Toolbar Butonları
                HStack {
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            showMap.toggle()
                            HapticManager.shared.selection()
                        }) {
                            Image(systemName: showMap ? "list.bullet" : "map.fill")
                                .font(.system(size: 20))
                                .foregroundColor(theme.primary)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(theme.primary.opacity(0.1))
                                )
                        }
                        
                        Button(action: {
                            showAddInstitution = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(theme.primary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                // Arama ve Filtreler
                VStack(spacing: 12) {
                    // Arama
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Hastane, eczane, klinik ara...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                    )
                    
                    // Tip Filtreleri
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterButton(
                                title: "Tümü",
                                isSelected: selectedType == nil,
                                action: { selectedType = nil },
                                theme: theme
                            )
                            
                            ForEach(HealthInstitution.InstitutionType.allCases, id: \.self) { type in
                                FilterButton(
                                    title: type.rawValue,
                                    icon: type.icon,
                                    isSelected: selectedType == type,
                                    action: { selectedType = selectedType == type ? nil : type },
                                    theme: theme,
                                    color: type.color
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                if showMap {
                    // Harita Görünümü
                    MapView(
                        institutions: .constant(filteredInstitutions),
                        userLocation: .constant(institutionService.userLocation),
                        onInstitutionTap: { institution in
                            selectedInstitution = institution
                            openInGoogleMaps(institution: institution)
                        }
                    )
                    .frame(height: 500)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    
                    // Harita altında kurum listesi
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredInstitutions) { institution in
                                InstitutionCard(
                                    institution: institution,
                                    theme: theme,
                                    userLocation: institutionService.userLocation,
                                    onMapTap: {
                                        openInGoogleMaps(institution: institution)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                } else {
                    // Acil Servisler (Özel Kart)
                    if selectedType == nil || selectedType == .emergency {
                        EmergencyServicesCard(
                            institutions: institutionService.getEmergencyServices(),
                            theme: theme
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                    
                    // Kurum Listesi
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredInstitutions) { institution in
                                InstitutionCard(
                                    institution: institution,
                                    theme: theme,
                                    userLocation: institutionService.userLocation,
                                    onMapTap: {
                                        openInGoogleMaps(institution: institution)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationTitle("Sağlık Kurumları")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddInstitution) {
            AddHealthInstitutionView(
                institutionService: institutionService,
                theme: theme
            )
        }
        .onAppear {
            requestLocationPermission()
        }
    }
    
    private func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        authorizationStatus = locationManager.authorizationStatus
        
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            if let location = locationManager.location {
                institutionService.setUserLocation(location)
            }
        }
    }
    
    private func openInGoogleMaps(institution: HealthInstitution) {
        guard let latitude = institution.latitude,
              let longitude = institution.longitude else {
            // Konum yoksa sadece adres ile aç
            let address = "\(institution.address), \(institution.city)"
            if let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(encodedAddress)") {
                UIApplication.shared.open(url)
            }
            return
        }
        
        // Google Maps URL oluştur
        let googleMapsURL = "https://www.google.com/maps/search/?api=1&query=\(latitude),\(longitude)"
        
        // Alternatif olarak Apple Maps de dene
        let appleMapsURL = "http://maps.apple.com/?q=\(latitude),\(longitude)&ll=\(latitude),\(longitude)"
        
        // Önce Google Maps'i dene
        if let url = URL(string: googleMapsURL) {
            UIApplication.shared.open(url) { success in
                if !success {
                    // Google Maps açılamazsa Apple Maps'i dene
                    if let appleURL = URL(string: appleMapsURL) {
                        UIApplication.shared.open(appleURL)
                    }
                }
            }
        }
        
        HapticManager.shared.notification(type: .success)
    }
    
    private func getBackgroundGradient() -> [Color] {
        if colorScheme == .dark {
            return theme.backgroundGradient
        } else {
            switch baby.gender {
            case .female:
                return [
                    Color(red: 1.0, green: 0.98, blue: 0.99),
                    Color(red: 0.99, green: 0.96, blue: 0.98),
                    Color.white
                ]
            case .male:
                return [
                    Color(red: 0.98, green: 0.99, blue: 1.0),
                    Color(red: 0.97, green: 0.98, blue: 0.99),
                    Color.white
                ]
            }
        }
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    let theme: ColorTheme
    var color: (red: Double, green: Double, blue: Double)? = nil
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? 
                          (color != nil ? Color(red: color!.red, green: color!.green, blue: color!.blue) : theme.primary) :
                          Color(red: 0.95, green: 0.95, blue: 0.97))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Emergency Services Card
struct EmergencyServicesCard: View {
    let institutions: [HealthInstitution]
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if !institutions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "cross.case.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.2))
                    
                    Text("Acil Servisler")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.2))
                    
                    Spacer()
                }
                
                ForEach(institutions.prefix(3)) { institution in
                    EmergencyServiceRow(institution: institution)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 1.0, green: 0.95, blue: 0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 1.0, green: 0.2, blue: 0.2).opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

struct EmergencyServiceRow: View {
    let institution: HealthInstitution
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "phone.fill")
                .font(.system(size: 16))
                .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(institution.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                
                if let emergencyPhone = institution.emergencyPhone, !emergencyPhone.isEmpty {
                    Text("Acil: \(emergencyPhone)")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                let phone = institution.emergencyPhone ?? institution.phone
                if let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                    UIApplication.shared.open(url)
                }
            }) {
                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.2))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
    }
}

// MARK: - Institution Card
struct InstitutionCard: View {
    let institution: HealthInstitution
    let theme: ColorTheme
    let userLocation: CLLocation?
    var onMapTap: (() -> Void)? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var distance: Double? {
        guard let userLocation = userLocation,
              let institutionLocation = institution.location else { return nil }
        return userLocation.distance(from: institutionLocation) / 1000.0 // km
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(
                            red: institution.type.color.red,
                            green: institution.type.color.green,
                            blue: institution.type.color.blue
                        ).opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: institution.type.icon)
                        .font(.system(size: 22))
                        .foregroundColor(Color(
                            red: institution.type.color.red,
                            green: institution.type.color.green,
                            blue: institution.type.color.blue
                        ))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(institution.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    HStack(spacing: 8) {
                        Text(institution.type.rawValue)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        if institution.is24Hours {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 10))
                                Text("24 Saat")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.15))
                            )
                        }
                        
                        if let distance = distance {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 10))
                                Text(String(format: "%.1f km", distance))
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(theme.primary)
                        }
                    }
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text(institution.address)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text(institution.phone)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        if let url = URL(string: "tel://\(institution.phone.replacingOccurrences(of: " ", with: ""))") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "phone.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(theme.primary)
                    }
                }
                
                if !institution.services.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(institution.services.prefix(5), id: \.self) { service in
                                Text(service)
                                    .font(.system(size: 10, weight: .medium, design: .rounded))
                                    .foregroundColor(theme.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(theme.primary.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
                
                // Harita butonu
                if institution.latitude != nil && institution.longitude != nil {
                    Button(action: {
                        onMapTap?()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "map.fill")
                                .font(.system(size: 14))
                            Text("Haritada Aç")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(theme.primary)
                        )
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
        )
    }
}

// MARK: - Add Institution View
struct AddHealthInstitutionView: View {
    @ObservedObject var institutionService: HealthInstitutionService
    let theme: ColorTheme
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var type: HealthInstitution.InstitutionType = .hospital
    @State private var address = ""
    @State private var city = ""
    @State private var district = ""
    @State private var phone = ""
    @State private var emergencyPhone = ""
    @State private var website = ""
    @State private var workingHours = ""
    @State private var is24Hours = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kurum Bilgileri")) {
                    TextField("Kurum Adı", text: $name)
                    
                    Picker("Tip", selection: $type) {
                        ForEach(HealthInstitution.InstitutionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Adres")) {
                    TextField("Adres", text: $address)
                    TextField("Şehir", text: $city)
                    TextField("İlçe (Opsiyonel)", text: $district)
                }
                
                Section(header: Text("İletişim")) {
                    TextField("Telefon", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Acil Telefon (Opsiyonel)", text: $emergencyPhone)
                        .keyboardType(.phonePad)
                    TextField("Web Sitesi (Opsiyonel)", text: $website)
                        .keyboardType(.URL)
                    TextField("Çalışma Saatleri", text: $workingHours)
                }
                
                Section {
                    Toggle("24 Saat Açık", isOn: $is24Hours)
                }
            }
            .navigationTitle("Yeni Kurum Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let institution = HealthInstitution(
                            name: name,
                            type: type,
                            address: address,
                            city: city,
                            district: district.isEmpty ? nil : district,
                            phone: phone,
                            emergencyPhone: emergencyPhone.isEmpty ? nil : emergencyPhone,
                            website: website.isEmpty ? nil : website,
                            workingHours: workingHours.isEmpty ? nil : workingHours,
                            is24Hours: is24Hours
                        )
                        institutionService.addInstitution(institution)
                        HapticManager.shared.notification(type: .success)
                        dismiss()
                    }
                    .disabled(name.isEmpty || address.isEmpty || city.isEmpty || phone.isEmpty)
                }
            }
        }
    }
}


