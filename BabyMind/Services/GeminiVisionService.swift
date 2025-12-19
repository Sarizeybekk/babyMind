//
//  GeminiVisionService.swift
//  BabyMind
//
//  Gemini Vision API servisi
//

import Foundation
import UIKit
import Combine

class GeminiVisionService: ObservableObject {
    private let apiKey: String
    // Kullanılabilir modeller (sırayla denenir)
    private let availableModels = [
        "gemini-1.5-pro-vision",
        "gemini-1.5-flash",
        "gemini-pro-vision"
    ]
    
    private func getBaseURL(for model: String) -> String {
        return "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent"
    }
    
    init() {
        self.apiKey = Config.geminiAPIKey
        print("🔑 Gemini Vision Service initialized with API key: \(apiKey.prefix(10))...")
        
        // API key kontrolü
        if apiKey.isEmpty || apiKey == "YOUR_API_KEY_HERE" {
            print("⚠️ WARNING: API key is not configured properly!")
        }
    }
    
    // Beslenme analizi
    func analyzeFeedingAmount(image: UIImage) async throws -> String {
        let prompt = """
        Bu bebek görüntüsünü analiz et ve beslenme durumu hakkında detaylı bilgi ver:
        - Bebeğin beslenme pozisyonu
        - Beslenme sırasında dikkat edilmesi gerekenler
        - Öneriler
        Türkçe yanıt ver.
        """
        return try await analyzeImage(image: image, prompt: prompt)
    }
    
    // Cilt durumu analizi
    func analyzeSkinCondition(image: UIImage) async throws -> String {
        let prompt = """
        Bu bebek görüntüsünü analiz et ve cilt durumu hakkında detaylı bilgi ver:
        - Cilt sağlığı
        - Olası sorunlar
        - Öneriler
        Türkçe yanıt ver.
        """
        return try await analyzeImage(image: image, prompt: prompt)
    }
    
    // Gelişim aşaması analizi
    func analyzeMilestone(image: UIImage, babyAgeInWeeks: Int) async throws -> String {
        let prompt = """
        Bu bebek görüntüsünü analiz et. Bebek \(babyAgeInWeeks) haftalık.
        Gelişim aşaması hakkında detaylı bilgi ver:
        - Fiziksel gelişim
        - Motor beceriler
        - Öneriler
        Türkçe yanıt ver.
        """
        return try await analyzeImage(image: image, prompt: prompt)
    }
    
    // Yaş tahmini
    func estimateBabyAge(image: UIImage) async throws -> String {
        let prompt = """
        Bu bebek görüntüsünü analiz et ve yaş tahmini yap:
        - Tahmini yaş (hafta/ay)
        - Gelişim özellikleri
        - Açıklama
        Türkçe yanıt ver.
        """
        return try await analyzeImage(image: image, prompt: prompt)
    }
    
    // Ana analiz fonksiyonu - birden fazla model dener
    private func analyzeImage(image: UIImage, prompt: String) async throws -> String {
        print("📸 Starting image analysis...")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to JPEG data")
            throw VisionError.imageProcessingFailed
        }
        
        let base64Image = imageData.base64EncodedString()
        print("✅ Image converted to base64, size: \(base64Image.count) characters")
        
        // Her modeli sırayla dene
        var lastError: Error?
        for model in availableModels {
            do {
                return try await analyzeImageWithModel(imageData: base64Image, prompt: prompt, model: model)
            } catch {
                print("⚠️ Model \(model) failed: \(error.localizedDescription)")
                lastError = error
                // Eğer API key hatası varsa diğer modelleri deneme
                if let visionError = error as? VisionError,
                   case .apiError(let statusCode, _) = visionError,
                   statusCode == 400 || statusCode == 401 {
                    throw error
                }
                continue
            }
        }
        
        // Tüm modeller başarısız oldu
        throw lastError ?? VisionError.unknownError(NSError(domain: "VisionService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Tüm modeller başarısız oldu"]))
    }
    
    // Belirli bir model ile analiz yap
    private func analyzeImageWithModel(imageData: String, prompt: String, model: String) async throws -> String {
        let baseURL = getBaseURL(for: model)
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            print("❌ Invalid URL for model \(model)")
            throw VisionError.invalidURL
        }
        
        print("🌐 Making request to model: \(model)")
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [
                            "text": prompt
                        ],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": imageData
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.4,
                "topK": 32,
                "topP": 1.0,
                "maxOutputTokens": 2048
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60.0
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            print("✅ Request body created, size: \(request.httpBody?.count ?? 0) bytes")
        } catch {
            print("❌ Failed to create request body: \(error)")
            throw VisionError.requestCreationError(error)
        }
        
        do {
            print("📡 Sending API request...")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                throw VisionError.networkError(NSError(domain: "VisionService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçersiz yanıt"]))
            }
            
            print("📥 Response status code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Bilinmeyen hata"
                print("❌ API Error (\(httpResponse.statusCode)): \(errorMessage)")
                
                // Daha detaylı hata mesajı için JSON parse etmeyi dene
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorInfo = errorJson["error"] as? [String: Any],
                   let message = errorInfo["message"] as? String {
                    print("❌ Detailed error: \(message)")
                    throw VisionError.apiError(statusCode: httpResponse.statusCode, message: message)
                }
                
                throw VisionError.apiError(statusCode: httpResponse.statusCode, message: errorMessage)
            }
            
            print("✅ Response received, parsing JSON...")
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("❌ Failed to parse JSON response")
                throw VisionError.parsingError
            }
            
            // Debug için JSON'u yazdır
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Response JSON (first 500 chars): \(String(jsonString.prefix(500)))")
            }
            
            guard let candidates = json["candidates"] as? [[String: Any]],
                  let firstCandidate = candidates.first else {
                print("❌ No candidates in response")
                throw VisionError.parsingError
            }
            
            // Safety rating kontrolü
            if let safetyRatings = firstCandidate["safetyRatings"] as? [[String: Any]] {
                for rating in safetyRatings {
                    if let category = rating["category"] as? String,
                       let probability = rating["probability"] as? String,
                       probability == "HIGH" {
                        print("⚠️ Safety warning: \(category) - \(probability)")
                    }
                }
            }
            
            guard let content = firstCandidate["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let firstPart = parts.first,
                  let text = firstPart["text"] as? String else {
                print("❌ Failed to extract text from response")
                throw VisionError.parsingError
            }
            
            print("✅ Analysis completed successfully, text length: \(text.count) characters")
            return text
        } catch let error as VisionError {
            print("❌ VisionError: \(error.localizedDescription)")
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw VisionError.networkError(error)
        }
    }
}

enum VisionError: LocalizedError {
    case imageProcessingFailed
    case invalidURL
    case apiError(statusCode: Int, message: String?)
    case networkError(Error)
    case requestCreationError(Error)
    case parsingError
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Görüntü işleme başarısız oldu. Lütfen geçerli bir görüntü seçtiğinizden emin olun."
        case .invalidURL:
            return "Geçersiz API URL'si. Lütfen uygulama yapılandırmasını kontrol edin."
        case .apiError(let statusCode, let message):
            return "API hatası (\(statusCode)): \(message ?? "Bilinmeyen hata")"
        case .networkError(let error):
            return "Ağ hatası: \(error.localizedDescription). Lütfen internet bağlantınızı kontrol edin."
        case .requestCreationError(let error):
            return "İstek oluşturulurken hata: \(error.localizedDescription)"
        case .parsingError:
            return "API yanıtı ayrıştırılırken hata oluştu. Yanıt formatı beklenenden farklı olabilir."
        case .unknownError(let error):
            return "Bilinmeyen bir hata oluştu: \(error.localizedDescription)"
        }
    }
}
