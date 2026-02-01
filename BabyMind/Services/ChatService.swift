//
//  ChatService.swift
//  BabyMind
//
//  Chat servisi - AI yanıtları üretir
//

import Foundation
import Combine

class ChatService: ObservableObject {
    private let geminiService = GeminiService()
    private var useGemini = true // Gemini API kullanımını aç/kapat
    
    func getResponse(for message: String, baby: Baby) async -> String {
        // Gemini API kullan
        if useGemini {
            do {
                print("🤖 Gemini API çağrısı yapılıyor...")
                print("📝 Mesaj: \(message)")
                let response = try await geminiService.generateResponse(prompt: message, baby: baby)
                print("✅ Gemini API yanıtı alındı: \(response.prefix(100))...")
                print("📏 Yanıt uzunluğu: \(response.count) karakter")
                return response
            } catch {
                // Hata durumunda fallback yanıt
                print("❌ Gemini API Error: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("❌ Error Domain: \(nsError.domain)")
                    print("❌ Error Code: \(nsError.code)")
                    print("❌ Error Info: \(nsError.userInfo)")
                }
                print("⚠️ Fallback response kullanılıyor")
                return getFallbackResponse(for: message, baby: baby)
            }
        } else {
            // Eski yöntem (fallback)
            print("⚠️ Gemini API kapalı, fallback response kullanılıyor")
            return getFallbackResponse(for: message, baby: baby)
        }
    }
    
    private func getFallbackResponse(for message: String, baby: Baby) -> String {
        let lowercasedMessage = message.lowercased()
        
        // Beslenme soruları
        if lowercasedMessage.contains("beslenme") || lowercasedMessage.contains("mama") || lowercasedMessage.contains("emzirme") {
            return getFeedingResponse(baby: baby)
        }
        
        // Uyku soruları
        if lowercasedMessage.contains("uyku") || lowercasedMessage.contains("uyumuyor") || lowercasedMessage.contains("uyutmak") {
            return getSleepResponse(baby: baby)
        }
        
        // Gelişim soruları
        if lowercasedMessage.contains("gelişim") || lowercasedMessage.contains("büyüme") || lowercasedMessage.contains("oturma") || lowercasedMessage.contains("yürüme") {
            return getDevelopmentResponse(baby: baby)
        }
        
        // Sağlık soruları
        if lowercasedMessage.contains("sağlık") || lowercasedMessage.contains("aşı") || lowercasedMessage.contains("hastalık") || lowercasedMessage.contains("ateş") {
            return getHealthResponse(baby: baby)
        }
        
        // Ağlama soruları
        if lowercasedMessage.contains("ağlıyor") || lowercasedMessage.contains("ağlama") || lowercasedMessage.contains("sürekli ağlıyor") {
            return "Bebeğiniz ağladığında önce temel ihtiyaçlarını kontrol edin:\n\n• Aç olabilir - Beslenme zamanı gelmiş olabilir\n• Altı kirli olabilir - Bezini kontrol edin\n• Uykusu gelmiş olabilir - Uyku rutini oluşturun\n• Gaz sancısı olabilir - Karın masajı yapın\n• Sıcak/soğuk olabilir - Ortam sıcaklığını kontrol edin\n\nEğer ağlama devam ederse ve endişeleniyorsanız, bir sağlık uzmanına danışmanızı öneririm."
        }
        
        // Genel karşılama
        if lowercasedMessage.contains("merhaba") || lowercasedMessage.contains("selam") || lowercasedMessage.contains("hey") {
            return "Merhaba! 👋 Bebeğiniz \(baby.name.isEmpty ? "bebeğiniz" : baby.name) hakkında size nasıl yardımcı olabilirim? Beslenme, uyku, gelişim veya sağlık konularında sorularınızı sorabilirsiniz."
        }
        
        // Varsayılan yanıt
        return getDefaultResponse(baby: baby)
    }
    
    private func getFeedingResponse(baby: Baby) -> String {
        let ageInWeeks = baby.ageInWeeks
        
        if ageInWeeks < 4 {
            return "Yenidoğan bebeğiniz için:\n\n• 2-3 saatte bir beslenme önerilir\n• Günde 8-12 kez emzirme normaldir\n• Bebeğiniz doyduğunda kendiliğinden bırakır\n• İlk 6 ay sadece anne sütü veya formül süt yeterlidir\n\nHerhangi bir endişeniz varsa, bir sağlık uzmanına danışabilirsiniz."
        } else if ageInWeeks < 12 {
            return "\(ageInWeeks) haftalık bebeğiniz için:\n\n• 3-4 saatte bir beslenme yeterlidir\n• Günde 6-8 kez beslenme normaldir\n• Bebeğiniz daha düzenli bir rutin oluşturmaya başlar\n• Ek gıdaya geçiş için henüz erken\n\nBeslenme ile ilgili daha detaylı bilgi için 'Beslenme' sekmesine bakabilirsiniz."
        } else {
            return "\(ageInWeeks) haftalık bebeğiniz için:\n\n• 4-5 saatte bir beslenme yeterlidir\n• Günde 4-6 kez beslenme normaldir\n• Ek gıdaya geçiş için hazır olabilir\n• Katı gıdaları yavaş yavaş tanıtabilirsiniz\n\nTarifler ve beslenme önerileri için 'Beslenme' sekmesindeki tarifleri inceleyebilirsiniz."
        }
    }
    
    private func getSleepResponse(baby: Baby) -> String {
        let ageInWeeks = baby.ageInWeeks
        
        if ageInWeeks < 4 {
            return "Yenidoğan bebeğiniz için:\n\n• Günde 14-17 saat uyku normaldir\n• Gece uykusu kesintili olabilir (8-9 saat)\n• Gündüz 6-8 saat kısa uykular uyur\n• Bebeğiniz henüz gece-gündüz ayrımı yapmaz\n\nUyku rutini oluşturmak için henüz erken. Bebeğinizin ihtiyacına göre uyumasına izin verin."
        } else if ageInWeeks < 12 {
            return "\(ageInWeeks) haftalık bebeğiniz için:\n\n• Günde 12-16 saat uyku normaldir\n• Gece uykusu daha uzun olmaya başlar (9-10 saat)\n• Gündüz 3-5 saat uyur\n• Uyku rutini oluşturmaya başlayabilirsiniz\n\nDüzenli uyku saatleri ve rahatlatıcı bir ortam oluşturmak faydalı olacaktır."
        } else {
            return "\(ageInWeeks) haftalık bebeğiniz için:\n\n• Günde 11-14 saat uyku normaldir\n• Gece uykusu 10-12 saat olabilir\n• Gündüz 2-3 saat uyur\n• Düzenli bir uyku rutini oluşturulmalıdır\n\nDaha detaylı bilgi için 'Uyku' sekmesine bakabilirsiniz."
        }
    }
    
    private func getDevelopmentResponse(baby: Baby) -> String {
        let ageInWeeks = baby.ageInWeeks
        
        if ageInWeeks < 4 {
            return "Yenidoğan bebeğiniz için beklenen gelişim:\n\n• Göz teması kurmaya başlar\n• Seslere tepki verir\n• Başını kısa süre kaldırabilir\n• Yüz ifadelerini taklit edebilir\n\nHer bebek farklı hızda gelişir. Endişeniz varsa bir uzmana danışın."
        } else if ageInWeeks < 12 {
            return "\(ageInWeeks) haftalık bebeğiniz için:\n\n• Gülümsemeye başlar\n• Başını daha iyi kontrol eder\n• Ellerini keşfetmeye başlar\n• Sesler çıkarmaya başlar\n\nGelişim ile ilgili daha fazla bilgi için 'Gelişim' sekmesine bakabilirsiniz."
        } else {
            return "\(ageInWeeks) haftalık bebeğiniz için:\n\n• Oturmaya çalışabilir\n• Nesneleri tutabilir\n• Seslere daha iyi tepki verir\n• Yabancıları ayırt edebilir\n\nHer bebek farklı hızda gelişir. Sabırlı olun ve bebeğinizi destekleyin."
        }
    }
    
    private func getHealthResponse(baby: Baby) -> String {
        return "Bebeğinizin sağlığı için:\n\n• Aşı takvimini düzenli takip edin\n• Düzenli sağlık kontrollerini yaptırın\n• Bebeğinizin vücut sıcaklığını kontrol edin\n• Cilt sağlığına dikkat edin\n• Acil durumlar için hazırlıklı olun\n\nAşı takvimi ve sağlık önerileri için 'Sağlık' sekmesine bakabilirsiniz. Acil durumlarda 112'yi arayın."
    }
    
    private func getDefaultResponse(baby: Baby) -> String {
        return "Anladım! Bebeğiniz \(baby.name.isEmpty ? "bebeğiniz" : baby.name) hakkında size yardımcı olmak için buradayım. 👶\n\nSize şu konularda yardımcı olabilirim:\n\n• Beslenme önerileri\n• Uyku düzeni\n• Gelişim aşamaları\n• Sağlık bilgileri\n• Genel bebek bakımı\n\nHangi konuda bilgi almak istersiniz?"
    }
    
    func getQuickQuestions() -> [String] {
        return [
            "Bebeğim ne kadar uyumalı?",
            "Beslenme sıklığı nasıl olmalı?",
            "Aşı takvimi nedir?",
            "Bebeğim sürekli ağlıyor, ne yapmalıyım?",
            "Gelişim aşamaları nelerdir?"
        ]
    }
}



