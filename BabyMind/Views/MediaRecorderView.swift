//
//  MediaRecorderView.swift
//  BabyMind
//
//  Ses ve video kayıt görünümü
//

import SwiftUI
import AVFoundation
import AVKit
import Combine

struct MediaRecorderView: View {
    let baby: Baby
    let onSave: (MilestonePhoto) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedMediaType: MilestonePhoto.MediaType = .photo
    @State private var isRecording = false
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var selectedImage: UIImage?
    @State private var videoURL: URL?
    @State private var audioURL: URL?
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: MilestonePhoto.MilestoneCategory = .other
    @State private var showImagePicker = false
    @State private var showVideoPicker = false
    @State private var showCamera = false
    @State private var showVideoCamera = false
    @State private var showPlayer = false
    
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var videoRecorder = VideoRecorder()
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: theme.backgroundGradient,
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Medya Tipi Seçici
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Medya Tipi")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(theme.text)
                            
                            Picker("Medya Tipi", selection: $selectedMediaType) {
                                Text("📷 Fotoğraf").tag(MilestonePhoto.MediaType.photo)
                                Text("🎥 Video").tag(MilestonePhoto.MediaType.video)
                                Text("🎤 Ses").tag(MilestonePhoto.MediaType.audio)
                                Text("📷🎤 Fotoğraf + Ses").tag(MilestonePhoto.MediaType.photoWithAudio)
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: theme.cardShadow, radius: 10, x: 0, y: 3)
                        )
                        
                        // Kayıt/Görüntüleme Alanı
                        mediaCaptureArea
                        
                        // Bilgi Formu
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Bilgiler")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(theme.text)
                            
                            TextField("Başlık", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Açıklama (opsiyonel)", text: $description, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                            
                            Picker("Kategori", selection: $category) {
                                ForEach(MilestonePhoto.MilestoneCategory.allCases, id: \.self) { cat in
                                    Text(cat.rawValue).tag(cat)
                                }
                            }
                            .pickerStyle(.menu)
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
            }
            .navigationTitle("Yeni Anı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        stopRecording()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveMedia()
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
            }
            .sheet(isPresented: $showVideoPicker) {
                VideoPicker(videoURL: $videoURL)
            }
            .sheet(isPresented: $showVideoCamera) {
                VideoCameraPicker(videoURL: $videoURL)
            }
            .fullScreenCover(isPresented: $showPlayer) {
                if let videoURL = videoURL {
                    VideoPlayerView(videoURL: videoURL)
                }
            }
        }
    }
    
    @ViewBuilder
    private var mediaCaptureArea: some View {
        VStack(spacing: 20) {
            switch selectedMediaType {
            case .photo:
                photoCaptureArea
            case .video:
                videoCaptureArea
            case .audio:
                audioCaptureArea
            case .photoWithAudio:
                photoWithAudioArea
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
    private var photoCaptureArea: some View {
        VStack(spacing: 16) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    showImagePicker = true
                }) {
                    Label("Galeriden Seç", systemImage: "photo.on.rectangle")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(theme.primary)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    showCamera = true
                }) {
                    Label("Kamera", systemImage: "camera.fill")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(theme.primaryDark)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    @ViewBuilder
    private var videoCaptureArea: some View {
        VStack(spacing: 16) {
            if let videoURL = videoURL {
                VideoThumbnailView(videoURL: videoURL) {
                    showPlayer = true
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "video.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("Video kaydı başlatın")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.gray)
                        }
                    )
            }
            
            if isRecording {
                recordingIndicator
            }
            
            HStack(spacing: 12) {
                HStack(spacing: 12) {
                Button(action: {
                    showVideoCamera = true
                }) {
                    Label("Video Kaydet", systemImage: "video.fill")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(theme.primary)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    showVideoPicker = true
                }) {
                    Label("Galeriden Seç", systemImage: "photo.on.rectangle")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(theme.primaryDark)
                        .cornerRadius(12)
                }
            }
            }
        }
    }
    
    @ViewBuilder
    private var audioCaptureArea: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(theme.primary.opacity(0.15))
                    .frame(width: 150, height: 150)
                
                if isRecording {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 80, height: 80)
                        .scaleEffect(isRecording ? 1.2 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.0)
                                .repeatForever(autoreverses: true),
                            value: isRecording
                        )
                } else {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 50))
                        .foregroundColor(theme.primary)
                }
            }
            
            if isRecording {
                Text(formatTime(recordingTime))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(theme.text)
            }
            
            HStack(spacing: 12) {
                if !isRecording {
                    Button(action: {
                        startAudioRecording()
                    }) {
                        Label("Ses Kaydet", systemImage: "mic.fill")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(theme.primary)
                            .cornerRadius(12)
                    }
                } else {
                    Button(action: {
                        stopAudioRecording()
                    }) {
                        Label("Kaydı Durdur", systemImage: "stop.fill")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                }
                
                if audioURL != nil {
                    Button(action: {
                        playAudio()
                    }) {
                        Label("Oynat", systemImage: "play.fill")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(theme.primaryDark)
                            .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var photoWithAudioArea: some View {
        VStack(spacing: 16) {
            // Fotoğraf
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 150)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                    )
            }
            
            Button(action: {
                showImagePicker = true
            }) {
                Label("Fotoğraf Seç", systemImage: "photo.on.rectangle")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.primary)
                    .cornerRadius(12)
            }
            
            Divider()
            
            // Ses
            HStack(spacing: 12) {
                if !isRecording {
                    Button(action: {
                        startAudioRecording()
                    }) {
                        Label("Ses Kaydet", systemImage: "mic.fill")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(theme.primary)
                            .cornerRadius(12)
                    }
                } else {
                    Button(action: {
                        stopAudioRecording()
                    }) {
                        Label("Durdur", systemImage: "stop.fill")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                }
                
                if audioURL != nil {
                    Button(action: {
                        playAudio()
                    }) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding()
                            .background(theme.primaryDark)
                            .cornerRadius(12)
                    }
                }
            }
            
            if isRecording {
                Text(formatTime(recordingTime))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(theme.text)
            }
        }
    }
    
    @ViewBuilder
    private var recordingIndicator: some View {
        HStack {
            Circle()
                .fill(Color.red)
                .frame(width: 12, height: 12)
                .opacity(isRecording ? 1.0 : 0.3)
                .animation(
                    Animation.easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true),
                    value: isRecording
                )
            
            Text("Kaydediliyor... \(formatTime(recordingTime))")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(theme.text)
        }
    }
    
    private var canSave: Bool {
        switch selectedMediaType {
        case .photo:
            return selectedImage != nil && !title.isEmpty
        case .video:
            return videoURL != nil && !title.isEmpty
        case .audio:
            return audioURL != nil && !title.isEmpty
        case .photoWithAudio:
            return selectedImage != nil && audioURL != nil && !title.isEmpty
        }
    }
    
    private func startAudioRecording() {
        audioRecorder.startRecording { url in
            audioURL = url
        }
        isRecording = true
        recordingTime = 0
        startTimer()
    }
    
    private func stopAudioRecording() {
        audioRecorder.stopRecording()
        isRecording = false
        stopTimer()
    }
    
    
    private func stopRecording() {
        if isRecording {
            audioRecorder.stopRecording()
            isRecording = false
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingTime += 0.1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func playAudio() {
        if let audioURL = audioURL {
            audioRecorder.playAudio(url: audioURL)
        }
    }
    
    private func saveMedia() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var savedVideoURL: String? = nil
        var savedAudioURL: String? = nil
        var photoData: Data? = nil
        
        // Fotoğraf kaydet
        if let image = selectedImage {
            photoData = image.jpegData(compressionQuality: 0.8)
        }
        
        // Video kaydet
        if let videoURL = videoURL {
            let videoFileName = "\(UUID().uuidString).mov"
            let videoDestination = documentsPath.appendingPathComponent(videoFileName)
            
            do {
                if FileManager.default.fileExists(atPath: videoURL.path) {
                    try FileManager.default.copyItem(at: videoURL, to: videoDestination)
                    savedVideoURL = videoFileName
                }
            } catch {
                print("Video kaydetme hatası: \(error)")
            }
        }
        
        // Ses kaydet
        if let audioURL = audioURL {
            let audioFileName = "\(UUID().uuidString).m4a"
            let audioDestination = documentsPath.appendingPathComponent(audioFileName)
            
            do {
                if FileManager.default.fileExists(atPath: audioURL.path) {
                    try FileManager.default.copyItem(at: audioURL, to: audioDestination)
                    savedAudioURL = audioFileName
                }
            } catch {
                print("Ses kaydetme hatası: \(error)")
            }
        }
        
        let milestone = MilestonePhoto(
            title: title,
            description: description.isEmpty ? nil : description,
            date: Date(),
            photoData: photoData,
            videoURL: savedVideoURL,
            audioURL: savedAudioURL,
            mediaType: selectedMediaType,
            category: category
        )
        
        onSave(milestone)
        dismiss()
    }
}

// MARK: - Audio Recorder
class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingCompletion: ((URL) -> Void)?
    
    func startRecording(completion: @escaping (URL) -> Void) {
        recordingCompletion = completion
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Audio session hatası: \(error)")
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
        } catch {
            print("Kayıt başlatma hatası: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    func playAudio(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Ses oynatma hatası: \(error)")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            recordingCompletion?(recorder.url)
        }
    }
}

// MARK: - Video Recorder
class VideoRecorder: NSObject, ObservableObject {
    private var recordingCompletion: ((URL) -> Void)?
    
    func startRecording(completion: @escaping (URL) -> Void) {
        // Video kaydı için UIImagePickerController kullanılacak
        // Bu fonksiyon MediaRecorderView'da showCamera ile tetiklenecek
        recordingCompletion = completion
    }
    
    func stopRecording() {
        // Video kaydı UIImagePickerController tarafından yönetiliyor
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Video Picker
struct VideoPicker: UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: VideoPicker
        
        init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let url = info[.mediaURL] as? URL {
                parent.videoURL = url
            }
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Video Camera Picker
struct VideoCameraPicker: UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.cameraCaptureMode = .video
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: VideoCameraPicker
        
        init(_ parent: VideoCameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let url = info[.mediaURL] as? URL {
                parent.videoURL = url
            }
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Video Thumbnail View
struct VideoThumbnailView: View {
    let videoURL: URL
    let onTap: () -> Void
    @State private var thumbnail: UIImage?
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                }
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
            }
        }
        .onAppear {
            generateThumbnail()
        }
    }
    
    private func generateThumbnail() {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 0, preferredTimescale: 600)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            thumbnail = UIImage(cgImage: cgImage)
        } catch {
            print("Thumbnail oluşturma hatası: \(error)")
        }
    }
}

// MARK: - Video Player View
struct VideoPlayerView: View {
    let videoURL: URL
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VideoPlayer(player: AVPlayer(url: videoURL))
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

