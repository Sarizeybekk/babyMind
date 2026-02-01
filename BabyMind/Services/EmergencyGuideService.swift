//
//  EmergencyGuideService.swift
//
//  Acil durum rehberi servisi
//

import Foundation

class EmergencyGuideService {
    static let shared = EmergencyGuideService()
    
    private init() {}
    
    func getEmergencyGuides() -> [EmergencyGuide] {
        return [
            EmergencyGuide(
                category: .fever,
                title: "Ateş Yönetimi",
                description: "Bebeğinizde ateş varsa yapılması gerekenler",
                steps: [
                    "Bebeğinizin ateşini ölçün (rektal veya koltuk altı)",
                    "38°C üzeri ise doktorunuzu arayın (3 ay altı bebekler için)",
                    "Bebeği hafif giydirin, fazla örtmeyin",
                    "Ilık su ile banyo yaptırın (soğuk su kullanmayın)",
                    "Bol sıvı verin",
                    "Parasetamol veya ibuprofen kullanmadan önce doktora danışın"
                ],
                whenToCallDoctor: "3 ay altı bebeklerde 38°C üzeri, 3-6 ay arası 38.3°C üzeri, 6 ay üzeri 39.4°C üzeri ateşte derhal doktora başvurun."
            ),
            EmergencyGuide(
                category: .choking,
                title: "Boğulma/Boğazına Bir Şey Kaçması",
                description: "Bebeğinizin boğazına bir şey kaçtığında yapılması gerekenler",
                steps: [
                    "Bebeğinizi yüzü aşağıya bakacak şekilde kolunuzun üzerine yatırın",
                    "Başını ve boynunu destekleyin",
                    "Omuz bıçakları arasına 5 kez sertçe vurun",
                    "Bebeği çevirin ve göğsün ortasına 5 kez basınç uygulayın",
                    "Nefes alıp vermiyorsa suni solunum yapın",
                    "112'yi arayın ve acil servise gidin"
                ],
                whenToCallDoctor: "Hemen 112'yi arayın ve acil servise gidin."
            ),
            EmergencyGuide(
                category: .poisoning,
                title: "Zehirlenme Durumları",
                description: "Bebeğiniz zehirli bir madde yuttuysa",
                steps: [
                    "Sakin kalın",
                    "112'yi veya Zehir Danışma Hattı'nı (114) arayın",
                    "Yutulan maddenin adını ve miktarını belirtin",
                    "Kusturmayın (doktor önermedikçe)",
                    "Bebeği yan yatırın",
                    "Kusmuk veya madde örneğini saklayın"
                ],
                whenToCallDoctor: "Derhal 112 veya Zehir Danışma Hattı (114) arayın."
            ),
            EmergencyGuide(
                category: .breathing,
                title: "Nefes Alma Sorunları",
                description: "Bebeğiniz nefes almakta zorlanıyorsa",
                steps: [
                    "Bebeğinizin nefes alıp almadığını kontrol edin",
                    "Ağzında veya burnunda tıkanıklık var mı bakın",
                    "Nefes alıyorsa ama zorlanıyorsa sakin tutun",
                    "Nefes almıyorsa suni solunum yapın",
                    "112'yi arayın"
                ],
                whenToCallDoctor: "Nefes alma sorunlarında derhal 112'yi arayın."
            ),
            EmergencyGuide(
                category: .firstAid,
                title: "İlk Yardım Temel Bilgileri",
                description: "Genel ilk yardım kuralları",
                steps: [
                    "Sakin kalın ve durumu değerlendirin",
                    "Bebeğin güvenliğini sağlayın",
                    "112'yi arayın (gerekirse)",
                    "Temel yaşam desteği bilgilerini uygulayın",
                    "Bebeği sıcak tutun",
                    "Yaralı bölgeyi temizleyin ve bandajlayın"
                ],
                whenToCallDoctor: "Ciddi yaralanmalarda derhal 112'yi arayın."
            ),
            EmergencyGuide(
                category: .whenToCall,
                title: "Ne Zaman Doktora Gidilmeli?",
                description: "Acil durum belirtileri",
                steps: [
                    "Yüksek ateş (yaşa göre değişir)",
                    "Nefes alma zorluğu",
                    "Şiddetli kusma veya ishal",
                    "Bilinç kaybı veya uyku hali",
                    "Nöbet geçirme",
                    "Ciddi yaralanma",
                    "Zehirlenme şüphesi",
                    "Kanama (durdurulamayan)"
                ],
                whenToCallDoctor: "Bu belirtilerden herhangi biri varsa derhal doktora başvurun veya 112'yi arayın."
            )
        ]
    }
    
    func getGuide(for category: EmergencyGuide.Category) -> EmergencyGuide? {
        return getEmergencyGuides().first { $0.category == category }
    }
}


