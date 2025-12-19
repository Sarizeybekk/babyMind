//
//  CryAnalysisService.swift
//
//  Ağlama analizi servisi
//

import Foundation
import AVFoundation
import Combine

class CryAnalysisService: ObservableObject {
    @Published var analyses: [CryAnalysis] = []
    private let babyId: UUID
    private var audioRecorder: AVAudioRecorder?
    private var recordingTimer: Timer?
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadAnalyses()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    func startRecording() -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("cry_\(UUID().uuidString).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
            recordingDuration = 0
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.recordingDuration += 0.1
            }
            
            return audioFilename
        } catch {
            print("Recording failed: \(error)")
            return nil
        }
    }
    
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecording = false
        
        return audioRecorder?.url
    }
    
    func analyzeCry(audioURL: URL?, notes: String? = nil, completion: @escaping (CryAnalysis) -> Void) {
        // Simüle edilmiş AI analizi (gerçek implementasyonda ses analizi yapılacak)
        // Gerçek uygulamada CoreML veya API kullanılabilir
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Simüle edilmiş analiz süresi
            Thread.sleep(forTimeInterval: 2.0)
            
            // Rastgele ağlama türü (gerçekte AI modeli kullanılacak)
            let cryTypes: [CryAnalysis.CryType] = [.hunger, .tired, .pain, .discomfort, .attention]
            let randomType = cryTypes.randomElement() ?? .unknown
            let confidence = Double.random(in: 0.7...0.95)
            
            // AI önerisi oluştur
            let recommendation = self.generateRecommendation(for: randomType)
            
            let analysis = CryAnalysis(
                babyId: self.babyId,
                date: Date(),
                audioFileName: audioURL?.lastPathComponent,
                cryType: randomType,
                confidence: confidence,
                duration: self.recordingDuration,
                notes: notes,
                aiRecommendation: recommendation
            )
            
            DispatchQueue.main.async {
                self.addAnalysis(analysis)
                completion(analysis)
            }
        }
    }
    
    private func generateRecommendation(for type: CryAnalysis.CryType) -> String {
        switch type {
        case .hunger:
            return "Bebeğiniz aç olabilir. Son beslenme zamanını kontrol edin ve gerekirse besleyin."
        case .tired:
            return "Bebeğiniz yorgun görünüyor. Uyku rutinini kontrol edin ve sessiz bir ortam sağlayın."
        case .pain:
            return "Ağrı belirtisi olabilir. Bebeğinizi kontrol edin ve gerekirse doktora danışın."
        case .discomfort:
            return "Rahatsızlık hissediyor olabilir. Bez değişimi veya pozisyon değişikliği deneyin."
        case .attention:
            return "İlgi ve sevgi ihtiyacı olabilir. Bebeğinizle konuşun veya kucağınıza alın."
        case .unknown:
            return "Ağlama türü belirlenemedi. Bebeğinizin genel durumunu kontrol edin."
        }
    }
    
    func addAnalysis(_ analysis: CryAnalysis) {
        analyses.append(analysis)
        analyses.sort { $0.date > $1.date }
        saveAnalyses()
    }
    
    func deleteAnalysis(_ analysis: CryAnalysis) {
        analyses.removeAll { $0.id == analysis.id }
        saveAnalyses()
    }
    
    func getRecentAnalyses(limit: Int = 10) -> [CryAnalysis] {
        return Array(analyses.prefix(limit))
    }
    
    func getAnalysesByType(_ type: CryAnalysis.CryType) -> [CryAnalysis] {
        return analyses.filter { $0.cryType == type }
    }
    
    private func saveAnalyses() {
        if let encoded = try? JSONEncoder().encode(analyses) {
            UserDefaults.standard.set(encoded, forKey: "cryAnalyses_\(babyId.uuidString)")
        }
    }
    
    private func loadAnalyses() {
        if let data = UserDefaults.standard.data(forKey: "cryAnalyses_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([CryAnalysis].self, from: data) {
            analyses = decoded.sorted { $0.date > $1.date }
        }
    }
}
