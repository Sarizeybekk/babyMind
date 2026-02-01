# BabyMind

Bebek bakımı ve takibi için kapsamlı iOS uygulaması.

## Özellikler

- **Ana Dashboard**: Bebek bilgileri, metrikler ve hızlı erişim
- **Beslenme Takibi**: Beslenme kayıtları, haftalık menü planlayıcı, tarifler
- **Uyku Analizi**: Uyku kalitesi skoru, desenler, optimal saatler, gece uyanma takibi
- **Sağlık Takibi**: Ateş, ilaç, doktor randevuları, notlar
- **Aktivite Günlüğü**: Tüm aktivitelerin merkezi takibi
- **AI Asistan**: Gemini AI ile akıllı öneriler ve sohbet
- **Görüntü Analizi**: AI ile bebek fotoğraflarını analiz etme
- **Ağlama Analizi**: Ses kaydı ve AI ile ağlama türü tespiti
- **Hatırlatıcılar**: Önemli görevler için bildirimler
- **Çoklu Bebek Desteği**: Birden fazla bebek profili yönetimi

## Kurulum

1. Projeyi klonlayın:
```bash
git clone https://github.com/kullaniciadi/BabyMind.git
cd BabyMind
```

2. API Key'i yapılandırın:
```bash
cp BabyMind/Config/Config.swift.example BabyMind/Config/Config.swift
```

3. `Config.swift` dosyasını açın ve Google Gemini API key'inizi ekleyin:
```swift
static let geminiAPIKey = "YOUR_API_KEY_HERE"
```

API key almak için: [Google AI Studio](https://makersuite.google.com/app/apikey)

4. Xcode'da projeyi açın ve çalıştırın.

## Gereksinimler

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Teknolojiler

- SwiftUI
- Google Gemini AI
- AVFoundation (Ses kaydı)
- UserDefaults (Yerel veri saklama)


