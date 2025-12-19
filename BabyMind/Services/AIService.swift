//
//  AIService.swift
//  BabyMind
//
//  Yapay zekâ servis katmanı
//

import Foundation
import Combine

class AIService: ObservableObject {
    // API anahtarı buraya eklenecek
    private let apiKey: String? = nil
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    // Geçici olarak yerel öneriler döndürüyoruz
    // Gerçek AI entegrasyonu için OpenAI, Anthropic veya başka bir servis kullanılabilir
    
    func getRecommendation(for baby: Baby, category: Recommendation.Category) async throws -> Recommendation {
        // Simüle edilmiş AI yanıtı
        // Gerçek implementasyonda API çağrısı yapılacak
        
        let recommendations = generateLocalRecommendations(for: baby, category: category)
        return recommendations.randomElement() ?? Recommendation(
            category: category,
            title: "Öneri",
            description: "Bebeğiniz için özel öneriler hazırlanıyor..."
        )
    }
    
    private func generateLocalRecommendations(for baby: Baby, category: Recommendation.Category) -> [Recommendation] {
        let ageInWeeks = baby.ageInWeeks
        
        switch category {
        case .feeding:
            if ageInWeeks < 4 {
                return [
                    Recommendation(
                        category: .feeding,
                        title: "Sık Beslenme",
                        description: "Yenidoğan bebekler genellikle 2-3 saatte bir beslenmeye ihtiyaç duyar. Bebeğinizin açlık belirtilerini takip edin.",
                        priority: .high
                    )
                ]
            } else if ageInWeeks < 12 {
                return [
                    Recommendation(
                        category: .feeding,
                        title: "Beslenme Düzeni",
                        description: "Bebeğiniz artık daha düzenli beslenme saatleri geliştirebilir. Günde yaklaşık 6-8 kez beslenme normaldir.",
                        priority: .medium
                    )
                ]
            }
            
        case .sleep:
            if ageInWeeks < 4 {
                return [
                    Recommendation(
                        category: .sleep,
                        title: "Uyku Düzeni",
                        description: "Yenidoğan bebekler günde 14-17 saat uyur. Uyku saatleri düzensiz olabilir, bu normaldir.",
                        priority: .high
                    )
                ]
            } else if ageInWeeks < 12 {
                return [
                    Recommendation(
                        category: .sleep,
                        title: "Gece Uykusu",
                        description: "Bebeğiniz gece daha uzun süre uyuyabilir. Uyku rutini oluşturmaya başlayabilirsiniz.",
                        priority: .medium
                    )
                ]
            }
            
        case .development:
            return [
                Recommendation(
                    category: .development,
                    title: "Gelişim Takibi",
                    description: "Bebeğinizin \(ageInWeeks) haftalık gelişim aşamasında olduğunu unutmayın. Düzenli kontroller önemlidir.",
                    priority: .medium
                )
            ]
            
        case .health:
            return [
                Recommendation(
                    category: .health,
                    title: "Sağlık Kontrolü",
                    description: "Bebeğinizin düzenli sağlık kontrollerini yaptırmayı unutmayın.",
                    priority: .high
                )
            ]
            
        case .general:
            return [
                Recommendation(
                    category: .general,
                    title: "Genel Bakım",
                    description: "Bebeğinizin temel ihtiyaçlarını karşıladığınızdan emin olun: beslenme, uyku, temizlik ve sevgi.",
                    priority: .medium
                )
            ]
        }
        
        return []
    }
    
    // Gerçek AI API çağrısı için hazır fonksiyon (şimdilik kullanılmıyor)
    private func callAIAPI(prompt: String) async throws -> String {
        // OpenAI API entegrasyonu buraya eklenecek
        // Örnek yapı:
        /*
        guard let apiKey = apiKey else {
            throw AIError.missingAPIKey
        }
        
        // API çağrısı yapılacak
        */
        
        return ""
    }
}

enum AIError: Error {
    case missingAPIKey
    case networkError
    case invalidResponse
}





