//
//  GeminiService.swift
//  BabyMind
//
//  Google Gemini API servisi
//

import Foundation

class GeminiService {
    private let apiKey = Config.geminiAPIKey
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    init() {
        if apiKey.isEmpty || apiKey == "YOUR_API_KEY_HERE" {
            print("⚠️ UYARI: Gemini API key ayarlanmamış!")
        } else {
            print("✅ Gemini API key yüklendi: \(apiKey.prefix(10))...")
        }
    }
    
    func generateResponse(prompt: String, baby: Baby) async throws -> String {
        // API key kontrolü
        guard !apiKey.isEmpty && apiKey != "YOUR_API_KEY_HERE" else {
            throw NSError(domain: "GeminiService", code: -1, userInfo: [NSLocalizedDescriptionKey: "API key ayarlanmamış"])
        }
        
        let urlString = "\(baseURL)?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "GeminiService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        print("🌐 Gemini API URL: \(baseURL)")
        print("📝 Prompt: \(prompt.prefix(100))...")
        
        // Bebeğin bilgilerini içeren context oluştur
        let context = """
        Sen BabyMind uygulamasının AI asistanısın. Annelere bebek bakımı konusunda yardımcı oluyorsun.
        
        Bebek Bilgileri:
        - İsim: \(baby.name.isEmpty ? "Henüz isim verilmemiş" : baby.name)
        - Yaş: \(baby.ageInWeeks) hafta (\(baby.ageInMonths) ay)
        - Cinsiyet: \(baby.gender.rawValue)
        - Doğum Ağırlığı: \(String(format: "%.2f", baby.birthWeight)) kg
        - Doğum Boyu: \(String(format: "%.0f", baby.birthHeight)) cm
        
        Kullanıcı sorusu: \(prompt)
        
        Lütfen kısa, anlaşılır ve Türkçe yanıt ver. Bebeğin yaşına göre özel öneriler sun. Profesyonel ama samimi bir dil kullan.
        """
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [
                            "text": context
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 1024
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "GeminiService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])
        }
        
        print("📡 HTTP Status Code: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            let errorData = String(data: data, encoding: .utf8) ?? "No error data"
            print("❌ API Error Response: \(errorData)")
            throw NSError(domain: "GeminiService", code: -2, userInfo: [NSLocalizedDescriptionKey: "API request failed with status \(httpResponse.statusCode): \(errorData)"])
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let candidates = json?["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            print("❌ JSON Parse Error. Response: \(String(data: data, encoding: .utf8) ?? "No data")")
            throw NSError(domain: "GeminiService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
        
        print("✅ Gemini API yanıtı başarıyla alındı (\(text.count) karakter)")
        return text
    }
}



