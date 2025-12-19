//
//  VisionAnalysisView.swift
//  BabyMind
//
//  AI Görüntü Analizi görünümü - Premium Profesyonel Tasarım
//

import SwiftUI
import PhotosUI
import AVFoundation

struct VisionAnalysisView: View {
    let baby: Baby
    @StateObject private var visionService = GeminiVisionService()
    @State private var selectedImage: UIImage? = nil
    @State private var analysisResult: String? = nil
    @State private var isLoading = false
    @State private var analysisType: AnalysisType = .feeding
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showCameraError = false
    @State private var cameraErrorMessage = ""
    @State private var showTestImageOptions = false
    @State private var animateCards = false
    @State private var showResult = false
    
    enum AnalysisType: String, CaseIterable {
        case feeding = "Beslenme"
        case skin = "Cilt"
        case milestone = "Gelişim"
        case age = "Yaş"
        
        var icon: String {
            switch self {
            case .feeding: return "drop.fill"
            case .skin: return "heart.text.square.fill"
            case .milestone: return "star.fill"
            case .age: return "calendar"
            }
        }
        
        var fullName: String {
            switch self {
            case .feeding: return "Beslenme Miktarı"
            case .skin: return "Cilt Durumu"
            case .milestone: return "Gelişim Milestone"
            case .age: return "Yaş Tahmini"
            }
        }
    }
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Beyaz arka plan (görüntüdeki gibi)
            Color.white
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("AI Analiz")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Spacer()
                        
                        // Baby Avatar
                        BabyAvatarView(baby: baby)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Analiz Tipi Seçimi - Basit Tasarım
                    simpleAnalysisTypeSelector
                        .padding(.horizontal, 20)
                    
                    // Görüntü Seçimi - Basit Tasarım
                    simpleImageSelectionSection
                        .padding(.horizontal, 20)
                    
                    // Analiz Sonucu - Basit Tasarım
                    if isLoading {
                        simpleLoadingCard
                            .padding(.horizontal, 20)
                    } else if let result = analysisResult {
                        simpleAnalysisResultSection(result: result)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .onAppear {
            withAnimation {
                animateCards = true
            }
        }
    }
    
    // MARK: - Simple Analysis Type Selector
    @ViewBuilder
    private var simpleAnalysisTypeSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analiz Tipi")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
            
            // Grid Layout
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(AnalysisType.allCases, id: \.self) { type in
                    SimpleAnalysisTypeCard(
                        type: type,
                        isSelected: analysisType == type,
                        theme: theme
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            analysisType = type
                            HapticManager.shared.selection()
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                .shadow(color: theme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Simple Image Selection Section
    @ViewBuilder
    private var simpleImageSelectionSection: some View {
        if let image = selectedImage {
            VStack(spacing: 16) {
                // Image Preview
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(theme.primary.opacity(0.3), lineWidth: 2)
                    )
                
                // Change Image Button
                Button(action: {
                    selectedImage = nil
                }) {
                    Text("Görüntü Değiştir")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(theme.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(theme.primary.opacity(0.1))
                        )
                }
                
                // Analyze Button
                Button(action: {
                    Task {
                        await analyzeImage(image)
                    }
                }) {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "sparkles")
                            Text("Analiz Et")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.primary)
                    )
                }
                .disabled(isLoading)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                    .shadow(color: theme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
            )
        } else {
            // Empty State
            VStack(spacing: 20) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 50))
                    .foregroundColor(theme.primary.opacity(0.5))
                
                Text("Görüntü Seçin")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                HStack(spacing: 12) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Label("Galeri", systemImage: "photo.on.rectangle")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(theme.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(theme.primary.opacity(0.1))
                            )
                    }
                    
                    #if targetEnvironment(simulator)
                    Button(action: {
                        showTestImageOptions = true
                    }) {
                        Label("Test", systemImage: "camera.fill")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(theme.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(theme.primary.opacity(0.1))
                            )
                    }
                    #else
                    Button(action: {
                        checkCameraPermission { granted in
                            if granted {
                                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                    showCamera = true
                                } else {
                                    cameraErrorMessage = "Kamera kullanılamıyor."
                                    showCameraError = true
                                }
                            } else {
                                cameraErrorMessage = "Kamera erişim izni gerekli."
                                showCameraError = true
                            }
                        }
                    }) {
                        Label("Kamera", systemImage: "camera.fill")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(theme.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(theme.primary.opacity(0.1))
                            )
                    }
                    #endif
                }
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                    .shadow(color: theme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
            )
        }
    }
    
    // MARK: - Simple Loading Card
    @ViewBuilder
    private var simpleLoadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: theme.primary))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Analiz Yapılıyor...")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Text("AI görüntünüzü analiz ediyor")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                .shadow(color: theme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Simple Analysis Result Section
    @ViewBuilder
    private func simpleAnalysisResultSection(result: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color.green)
                
                Text("Analiz Tamamlandı")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            ScrollView {
                Text(result)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.3, green: 0.3, blue: 0.35))
                    .lineSpacing(4)
            }
            .frame(maxHeight: 300)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                .shadow(color: theme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .onAppear {
            withAnimation {
                showResult = true
            }
        }
        .sheet(isPresented: $showImagePicker) {
            PhotoImagePicker(image: $selectedImage, sourceType: .photoLibrary)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showCamera) {
            PhotoImagePicker(image: $selectedImage, sourceType: .camera)
                .ignoresSafeArea()
        }
        .alert("Kamera Hatası", isPresented: $showCameraError) {
            Button("Tamam", role: .cancel) { }
            if cameraErrorMessage.contains("Ayarlar") {
                Button("Ayarlara Git") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        } message: {
            Text(cameraErrorMessage)
        }
        .confirmationDialog("Test Görüntüsü Seç", isPresented: $showTestImageOptions, titleVisibility: .visible) {
            Button("Galeriden Seç") {
                showImagePicker = true
            }
            Button("Örnek Görüntü Oluştur") {
                createSampleImage()
            }
            Button("İptal", role: .cancel) { }
        } message: {
            Text("Simülatörde test için görüntü seçin")
        }
    }
    
    // MARK: - Premium Header
    @ViewBuilder
    private var premiumHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [theme.primary, theme.primaryDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("AI Görüntü Analizi")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(theme.text)
                    }
                    
                    Text("Yapay zeka ile bebeğinizin görüntülerini analiz edin")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(theme.text.opacity(0.6))
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Premium Analysis Type Selector
    @ViewBuilder
    private var premiumAnalysisTypeSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
            Text("Analiz Tipi")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)
                Spacer()
            }
            
            // Modern Grid Layout
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(AnalysisType.allCases, id: \.self) { type in
                    PremiumAnalysisTypeCard(
                        type: type,
                        isSelected: analysisType == type,
                        theme: theme
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            analysisType = type
                            HapticManager.shared.selection()
                }
            }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: theme.cardShadow.opacity(0.3), radius: 20, x: 0, y: 8)
        )
    }
    
    // MARK: - Premium Image Selection Section
    @ViewBuilder
    private var premiumImageSelectionSection: some View {
        if let image = selectedImage {
            VStack(spacing: 20) {
                // Premium Image Preview
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .shadow(color: theme.cardShadow.opacity(0.3), radius: 20, x: 0, y: 8)
                    
        VStack(spacing: 16) {
                Image(uiImage: image)
                    .resizable()
                            .scaledToFill()
                            .frame(height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [theme.primary.opacity(0.3), theme.primaryDark.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: theme.primary.opacity(0.2), radius: 15, x: 0, y: 8)
                
                        // Change Image Button
                        Button(action: {
                            withAnimation {
                                selectedImage = nil
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "photo.badge.plus")
                                Text("Görüntü Değiştir")
                            }
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(theme.primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(theme.primary.opacity(0.1))
                            )
                        }
                    }
                    .padding(20)
                }
                
                // Premium Analyze Button
                Button(action: {
                    Task {
                        await analyzeImage(image)
                    }
                }) {
                    HStack(spacing: 12) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                        } else {
                            Image(systemName: "sparkles")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Analiz Et")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                        LinearGradient(
                            colors: [theme.primary, theme.primaryDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                                .shadow(color: theme.primary.opacity(0.4), radius: 15, x: 0, y: 8)
                            
                            if !isLoading {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.2), Color.clear],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            }
                        }
                    )
                }
                .disabled(isLoading)
                .scaleEffect(isLoading ? 0.98 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLoading)
            }
            } else {
            // Premium Empty State
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [theme.primary.opacity(0.2), theme.primaryDark.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 50, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [theme.primary, theme.primaryDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(spacing: 8) {
                    Text("Görüntü Seçin")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(theme.text)
                    
                    Text("Analiz için bir fotoğraf seçin veya çekin")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(theme.text.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                    
                    HStack(spacing: 16) {
                    PremiumImageSourceButton(
                        icon: "photo.on.rectangle",
                        title: "Galeri",
                        theme: theme
                    ) {
                            showImagePicker = true
                    }
                    
                    #if targetEnvironment(simulator)
                    PremiumImageSourceButton(
                        icon: "camera.fill",
                        title: "Test",
                        theme: theme
                    ) {
                        showTestImageOptions = true
                    }
                    #else
                    PremiumImageSourceButton(
                        icon: "camera.fill",
                        title: "Kamera",
                        theme: theme
                    ) {
                            checkCameraPermission { granted in
                                if granted {
                                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                        showCamera = true
                                    } else {
                                        cameraErrorMessage = "Kamera kullanılamıyor. Lütfen gerçek bir cihazda deneyin."
                                        showCameraError = true
                                    }
                                } else {
                                    cameraErrorMessage = "Kamera erişim izni gerekli. Lütfen Ayarlar > BabyMind > Kamera iznini açın."
                                    showCameraError = true
                                }
                            }
                    }
                    #endif
                }
            }
            .padding(32)
                                .frame(maxWidth: .infinity)
                                .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .shadow(color: theme.cardShadow.opacity(0.3), radius: 20, x: 0, y: 8)
                                )
                        }
                    }
    
    // MARK: - Premium Loading Card
    @ViewBuilder
    private var premiumLoadingCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.primary))
                    .scaleEffect(1.2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Analiz Yapılıyor...")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(theme.text)
                    
                    Text("AI görüntünüzü analiz ediyor")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(theme.text.opacity(0.6))
                }
                
                Spacer()
            }
            
            ShimmerView()
                .frame(height: 4)
                .clipShape(Capsule())
        }
        .padding(24)
                .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: theme.cardShadow.opacity(0.3), radius: 20, x: 0, y: 8)
                )
            }
    
    // MARK: - Premium Analysis Result Section
    @ViewBuilder
    private func premiumAnalysisResultSection(result: String) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [theme.primary, theme.primaryDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Analiz Tamamlandı")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(theme.text)
                    
                    Text(analysisType.fullName)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(theme.text.opacity(0.6))
                }
                
                Spacer()
            }
            
            Divider()
                .background(theme.primary.opacity(0.2))
            
            ScrollView {
            Text(result)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(theme.text.opacity(0.9))
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxHeight: 300)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: theme.cardShadow.opacity(0.3), radius: 20, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [theme.primary.opacity(0.3), theme.primaryDark.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showResult = true
            }
        }
    }
    
    // MARK: - Helper Functions
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    private func createSampleImage() {
        let size = CGSize(width: 400, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let primaryColor = UIColor(theme.primary)
            let primaryDarkColor = UIColor(theme.primaryDark)
            let colors = [primaryColor.cgColor, primaryDarkColor.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
            context.cgContext.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: size.height), options: [])
            
            let iconSize: CGFloat = 150
            let iconRect = CGRect(
                x: (size.width - iconSize) / 2,
                y: (size.height - iconSize) / 2,
                width: iconSize,
                height: iconSize
            )
            
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillEllipse(in: iconRect)
            
            let eyeSize: CGFloat = 15
            let leftEye = CGRect(x: iconRect.midX - 30, y: iconRect.midY - 10, width: eyeSize, height: eyeSize)
            let rightEye = CGRect(x: iconRect.midX + 15, y: iconRect.midY - 10, width: eyeSize, height: eyeSize)
            context.cgContext.setFillColor(primaryColor.cgColor)
            context.cgContext.fillEllipse(in: leftEye)
            context.cgContext.fillEllipse(in: rightEye)
            
            context.cgContext.setStrokeColor(primaryColor.cgColor)
            context.cgContext.setLineWidth(3)
            context.cgContext.addArc(center: CGPoint(x: iconRect.midX, y: iconRect.midY + 20), radius: 20, startAngle: 0, endAngle: .pi, clockwise: false)
            context.cgContext.strokePath()
            
            let text = "Test Görüntüsü"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: size.height - 60,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
        }
        
        withAnimation {
            selectedImage = image
        }
    }
    
    private func analyzeImage(_ image: UIImage) async {
        isLoading = true
        analysisResult = nil
        showResult = false
        
        do {
            let result: String
            switch analysisType {
            case .feeding:
                result = try await visionService.analyzeFeedingAmount(image: image)
            case .skin:
                result = try await visionService.analyzeSkinCondition(image: image)
            case .milestone:
                result = try await visionService.analyzeMilestone(image: image, babyAgeInWeeks: baby.ageInWeeks)
            case .age:
                result = try await visionService.estimateBabyAge(image: image)
            }
            
            await MainActor.run {
                analysisResult = result
                isLoading = false
                HapticManager.shared.notification(type: .success)
            }
        } catch {
            let errorMessage: String
            if let visionError = error as? VisionError {
                errorMessage = visionError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
            
            print("❌ Vision Analysis Error: \(errorMessage)")
            print("Error details: \(error)")
            
            await MainActor.run {
                analysisResult = """
                ⚠️ Analiz Hatası
                
                \(errorMessage)
                
                Lütfen şunları kontrol edin:
                • İnternet bağlantınızın aktif olduğundan emin olun
                • API anahtarının doğru yapılandırıldığından emin olun
                • Görüntünün yüklenebilir olduğundan emin olun
                
                Sorun devam ederse lütfen tekrar deneyin.
                """
                isLoading = false
                showResult = true
                HapticManager.shared.notification(type: .error)
            }
        }
    }
}

// MARK: - Simple Analysis Type Card
struct SimpleAnalysisTypeCard: View {
    let type: VisionAnalysisView.AnalysisType
    let isSelected: Bool
    let theme: ColorTheme
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ? theme.primary : theme.primary.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isSelected ? .white : theme.primary)
                }
                
                Text(type.rawValue)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? theme.primary : (colorScheme == .dark ? Color.white.opacity(0.7) : Color(red: 0.3, green: 0.3, blue: 0.35)))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? theme.primary.opacity(0.1) : (colorScheme == .dark ? Color(red: 0.25, green: 0.25, blue: 0.3) : Color.white))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? theme.primary : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Premium Analysis Type Card (Eski)
struct PremiumAnalysisTypeCard: View {
    let type: VisionAnalysisView.AnalysisType
    let isSelected: Bool
    let theme: ColorTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [theme.primary, theme.primaryDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [theme.primary.opacity(0.1), theme.primaryDark.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(isSelected ? .white : theme.primary)
                }
                
                Text(type.rawValue)
                    .font(.system(size: 14, weight: isSelected ? .bold : .semibold, design: .rounded))
                    .foregroundColor(isSelected ? theme.text : theme.text.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? theme.primary.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ?
                                LinearGradient(
                                    colors: [theme.primary, theme.primaryDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 2 : 0
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Premium Image Source Button
struct PremiumImageSourceButton: View {
    let icon: String
    let title: String
    let theme: ColorTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [theme.primary.opacity(0.15), theme.primaryDark.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 80)
                    
                    Image(systemName: icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [theme.primary, theme.primaryDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: theme.cardShadow.opacity(0.2), radius: 10, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Photo Image Picker
struct PhotoImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        
        if sourceType == .camera {
            #if targetEnvironment(simulator)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                context.coordinator.showError("Kamera simülatörde kullanılamıyor. Lütfen gerçek bir cihazda veya galeriden fotoğraf seçerek deneyin.")
            }
            return picker
            #else
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    context.coordinator.showError("Kamera kullanılamıyor. Lütfen gerçek bir cihazda deneyin.")
                }
                return picker
            }
            
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            if status == .denied || status == .restricted {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    context.coordinator.showError("Kamera erişim izni gerekli. Lütfen Ayarlar > BabyMind > Kamera iznini açın.")
                }
                return picker
            }
            #endif
        }
        
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.modalPresentationStyle = .fullScreen
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoImagePicker
        
        init(_ parent: PhotoImagePicker) {
            self.parent = parent
        }
        
        func showError(_ message: String) {
            DispatchQueue.main.async {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                    self.parent.dismiss()
                    return
                }
                
                var topController = rootViewController
                while let presented = topController.presentedViewController {
                    topController = presented
                }
                
                let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: .default) { _ in
                    self.parent.dismiss()
                })
                
                topController.present(alert, animated: true)
            }
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
