//
//  MilestoneAlbumView.swift
//  BabyMind
//
//  Milestone fotoğraf albümü görünümü
//

import SwiftUI
import PhotosUI
import AVFoundation
import AVKit

struct MilestoneAlbumView: View {
    let baby: Baby
    @StateObject private var albumService: MilestoneAlbumService
    @State private var showAddPhoto = false
    @State private var selectedView: ViewType = .timeline
    @State private var selectedPhoto: MilestonePhoto?
    @State private var showPhotoDetail = false
    
    enum ViewType: String, CaseIterable {
        case timeline = "Zaman Çizelgesi"
        case category = "Kategoriler"
        case all = "Tümü"
    }
    
    init(baby: Baby) {
        self.baby = baby
        _albumService = StateObject(wrappedValue: MilestoneAlbumService(babyId: baby.id))
    }
    
    var body: some View {
        let theme = ColorTheme.theme(for: baby.gender)
        return ZStack {
            // Gradient Arka Plan
            LinearGradient(
                colors: theme.backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Görünüm seçici
                Picker("Görünüm", selection: $selectedView) {
                    ForEach(ViewType.allCases, id: \.self) { viewType in
                        Text(viewType.rawValue).tag(viewType)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                if albumService.photos.isEmpty {
                    EmptyAlbumView(onAddPhoto: {
                        showAddPhoto = true
                    }, theme: theme)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            switch selectedView {
                            case .timeline:
                                TimelineView(photos: albumService.getTimelinePhotos(), baby: baby)
                            case .category:
                                CategoryView(albumService: albumService)
                            case .all:
                                AllPhotosView(photos: albumService.photos, onPhotoTap: { photo in
                                    selectedPhoto = photo
                                    showPhotoDetail = true
                                })
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationTitle("Anı Albümü")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddPhoto = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(theme.primary)
                }
            }
        }
        .sheet(isPresented: $showAddPhoto) {
            MediaRecorderView(baby: baby, onSave: { photo in
                albumService.addPhoto(photo)
            })
        }
        .sheet(item: $selectedPhoto) { photo in
            PhotoDetailView(photo: photo, albumService: albumService, baby: baby)
        }
    }
}

struct TimelineView: View {
    let photos: [MilestonePhoto]
    let baby: Baby
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                TimelineItemView(
                    photo: photo,
                    baby: baby,
                    isFirst: index == 0,
                    isLast: index == photos.count - 1
                )
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
            }
        }
    }
}

struct TimelineItemView: View {
    let photo: MilestonePhoto
    let baby: Baby
    let isFirst: Bool
    let isLast: Bool
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    private func mediaTypeIcon(for type: MilestonePhoto.MediaType) -> String {
        switch type {
        case .photo: return "photo"
        case .video: return "video.fill"
        case .audio: return "waveform"
        case .photoWithAudio: return "photo.on.rectangle.angled"
        }
    }
    
    var ageAtPhoto: String {
        let ageInWeeks = Calendar.current.dateComponents([.weekOfYear], from: baby.birthDate, to: photo.date).weekOfYear ?? 0
        let ageInMonths = Calendar.current.dateComponents([.month], from: baby.birthDate, to: photo.date).month ?? 0
        
        if ageInMonths > 0 {
            return "\(ageInMonths) aylık"
        } else {
            return "\(ageInWeeks) haftalık"
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline çizgisi
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(theme.primary.opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
                
                ZStack {
                    Circle()
                        .fill(theme.primary)
                        .frame(width: 16, height: 16)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }
                
                if !isLast {
                    Rectangle()
                        .fill(theme.primary.opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 16)
            
            // Medya ve bilgiler
            VStack(alignment: .leading, spacing: 12) {
                // Medya içeriği
                Group {
                    if let image = photo.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(theme.primary.opacity(0.2), lineWidth: 1)
                            )
                    } else if photo.videoURL != nil {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                VStack {
                                    Image(systemName: "video.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                    Text("Video")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            )
                    } else if photo.audioURL != nil {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.primary.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                VStack {
                                    Image(systemName: "waveform")
                                        .font(.system(size: 40))
                                        .foregroundColor(theme.primary)
                                    Text("Ses Kaydı")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(theme.text)
                                }
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            )
                    }
                }
                
                // Bilgiler
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(photo.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                        
                        Spacer()
                        
                        Text(ageAtPhoto)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(theme.primary)
                            )
                    }
                    
                    Text(photo.category.rawValue)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(theme.primary)
                    
                    Text(photo.date, style: .date)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.45))
                    
                    if let description = photo.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.45))
                            .lineLimit(3)
                    }
                }
            }
        }
    }
}

struct CategoryView: View {
    @ObservedObject var albumService: MilestoneAlbumService
    @State private var selectedCategory: MilestonePhoto.MilestoneCategory?
    
    var body: some View {
        VStack(spacing: 20) {
            // Kategori grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(MilestonePhoto.MilestoneCategory.allCases, id: \.self) { category in
                    CategoryCard(
                        category: category,
                        photoCount: albumService.getPhotosByCategory(category).count,
                        firstPhoto: albumService.getPhotosByCategory(category).first
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 24)
            
            // Seçili kategorinin fotoğrafları
            if let category = selectedCategory {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(category.rawValue)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                        
                        Spacer()
                        
                        Button(action: {
                            selectedCategory = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.45))
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    AllPhotosView(
                        photos: albumService.getPhotosByCategory(category),
                        onPhotoTap: { _ in }
                    )
                }
            }
        }
    }
}

struct CategoryCard: View {
    let category: MilestonePhoto.MilestoneCategory
    let photoCount: Int
    let firstPhoto: MilestonePhoto?
    let action: () -> Void
    
    var categoryIcon: String {
        switch category {
        case .firstSmile: return "face.smiling"
        case .firstLaugh: return "face.smiling.inverse"
        case .firstStep: return "figure.walk"
        case .firstWord: return "bubble.left.and.bubble.right"
        case .sitting: return "figure.seated.side"
        case .crawling: return "figure.crawl"
        case .standing: return "figure.stand"
        case .walking: return "figure.walk"
        case .feeding: return "fork.knife"
        case .sleep: return "bed.double"
        case .play: return "gamecontroller"
        case .bath: return "drop"
        case .other: return "photo"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    if let photo = firstPhoto, let image = photo.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.7, blue: 0.85),
                                        Color(red: 0.95, green: 0.6, blue: 0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: categoryIcon)
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            )
                    }
                }
                
                Text(category.rawValue)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text("\(photoCount) fotoğraf")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.45))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AllPhotosView: View {
    let photos: [MilestonePhoto]
    let onPhotoTap: (MilestonePhoto) -> Void
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(photos) { photo in
                Button(action: {
                    onPhotoTap(photo)
                }) {
                    ZStack {
                        // Medya içeriği
                        if let image = photo.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 110, height: 110)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else if photo.videoURL != nil {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 110, height: 110)
                                .overlay(
                                    Image(systemName: "video.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                )
                        } else if photo.audioURL != nil {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 110, height: 110)
                                .overlay(
                                    Image(systemName: "waveform")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 110, height: 110)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        // Medya tipi ikonu
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: mediaTypeIcon(for: photo.mediaType))
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                                    .padding(4)
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func mediaTypeIcon(for type: MilestonePhoto.MediaType) -> String {
        switch type {
        case .photo: return "photo"
        case .video: return "video.fill"
        case .audio: return "waveform"
        case .photoWithAudio: return "photo.on.rectangle.angled"
        }
    }
}

struct EmptyAlbumView: View {
    let onAddPhoto: () -> Void
    let theme: ColorTheme
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
            
            Text("Henüz fotoğraf yok")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.25))
            
            Text("Bebeğinizin ilk anısını kaydedin")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.45))
                .multilineTextAlignment(.center)
            
            Button(action: onAddPhoto) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("İlk Fotoğrafı Ekle")
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [
                            theme.primary,
                            theme.primaryDark
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

struct AddMilestonePhotoView: View {
    let baby: Baby
    let onSave: (MilestonePhoto) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: MilestonePhoto.MilestoneCategory = .other
    @State private var date = Date()
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Fotoğraf") {
                    PhotosPicker(selection: $photoPickerItem, matching: .images) {
                        HStack {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 100, height: 100)
                                    
                                    VStack {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.system(size: 30))
                                        Text("Fotoğraf Seç")
                                            .font(.system(size: 12))
                                    }
                                    .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .onChange(of: photoPickerItem) { oldValue, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedImage = image
                            }
                        }
                    }
                }
                
                Section("Bilgiler") {
                    TextField("Başlık", text: $title)
                    
                    Picker("Kategori", selection: $category) {
                        ForEach(MilestonePhoto.MilestoneCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    
                    DatePicker("Tarih", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    TextField("Açıklama (opsiyonel)", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Yeni Anı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        if let image = selectedImage,
                           let imageData = image.jpegData(compressionQuality: 0.8) {
                            let photo = MilestonePhoto(
                                title: title.isEmpty ? category.rawValue : title,
                                description: description.isEmpty ? nil : description,
                                date: date,
                                photoData: imageData,
                                category: category
                            )
                            onSave(photo)
                            dismiss()
                        }
                    }
                    .disabled(selectedImage == nil || title.isEmpty)
                }
            }
        }
    }
}

struct PhotoDetailView: View {
    let photo: MilestonePhoto
    @ObservedObject var albumService: MilestoneAlbumService
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    @State private var showVideoPlayer = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlayingAudio = false
    let baby: Baby
    
    var body: some View {
        let theme = ColorTheme.theme(for: baby.gender)
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Medya gösterimi
                    mediaDisplayView(theme: theme)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(photo.title)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(theme.text)
                        
                        HStack {
                            Text(photo.category.rawValue)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(theme.primary)
                            
                            Spacer()
                            
                            Text(photo.mediaType.rawValue)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(theme.primary)
                                .cornerRadius(8)
                        }
                        
                        Text(photo.date, style: .date)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(theme.text.opacity(0.7))
                        
                        if let description = photo.description, !description.isEmpty {
                            Text(description)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(theme.text)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Anı Detayı")
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
            .alert("Anıyı Sil", isPresented: $showDeleteAlert) {
                Button("İptal", role: .cancel) { }
                Button("Sil", role: .destructive) {
                    albumService.deletePhoto(photo)
                    dismiss()
                }
            } message: {
                Text("Bu anıyı silmek istediğinizden emin misiniz?")
            }
            .fullScreenCover(isPresented: $showVideoPlayer) {
                if let videoURL = getVideoURL() {
                    VideoPlayerView(videoURL: videoURL)
                }
            }
        }
    }
    
    @ViewBuilder
    private func mediaDisplayView(theme: ColorTheme) -> some View {
        switch photo.mediaType {
        case .photo:
            if let image = photo.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        case .video:
            if let videoURL = getVideoURL() {
                VideoThumbnailView(videoURL: videoURL) {
                    showVideoPlayer = true
                }
            }
        case .audio:
            audioPlayerView(theme: theme)
        case .photoWithAudio:
            VStack(spacing: 16) {
                if let image = photo.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                audioPlayerView(theme: theme)
            }
        }
    }
    
    @ViewBuilder
    private func audioPlayerView(theme: ColorTheme) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(theme.primary.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "waveform")
                    .font(.system(size: 40))
                    .foregroundColor(theme.primary)
            }
            
            if let audioURL = getAudioURL() {
                Button(action: {
                    playAudio(url: audioURL)
                }) {
                    HStack {
                        Image(systemName: isPlayingAudio ? "pause.fill" : "play.fill")
                        Text(isPlayingAudio ? "Duraklat" : "Oynat")
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [theme.primary, theme.primaryDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
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
    
    private func getVideoURL() -> URL? {
        guard let videoURLString = photo.videoURL else { return nil }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(videoURLString)
    }
    
    private func getAudioURL() -> URL? {
        guard let audioURLString = photo.audioURL else { return nil }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(audioURLString)
    }
    
    private func playAudio(url: URL) {
        if let player = audioPlayer, player.isPlaying {
            player.stop()
            audioPlayer = nil
            isPlayingAudio = false
        } else {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = AudioPlayerDelegate(isPlaying: $isPlayingAudio)
                audioPlayer?.play()
                isPlayingAudio = true
            } catch {
                print("Ses oynatma hatası: \(error)")
            }
        }
    }
}

// MARK: - Audio Player Delegate
class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    @Binding var isPlaying: Bool
    
    init(isPlaying: Binding<Bool>) {
        _isPlaying = isPlaying
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}

