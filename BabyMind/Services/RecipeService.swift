//
//  RecipeService.swift
//  BabyMind
//
//  Tarif servisi
//

import Foundation

class RecipeService {
    
    func getRecipes(for baby: Baby) -> [Recipe] {
        let ageInMonths = baby.ageInMonths
        
        if ageInMonths < 4 {
            // 0-4 ay: Sadece anne sütü/formül
            return []
        } else if ageInMonths < 6 {
            // 4-6 ay: İlk ek gıdalar
            return get4To6MonthRecipes()
        } else if ageInMonths < 8 {
            // 6-8 ay: Püreler ve yumuşak gıdalar
            return get6To8MonthRecipes()
        } else if ageInMonths < 12 {
            // 8-12 ay: Parmak gıdalar
            return get8To12MonthRecipes()
        } else {
            // 12+ ay: Aile yemekleri
            return get12PlusMonthRecipes()
        }
    }
    
    private func get4To6MonthRecipes() -> [Recipe] {
        return [
            Recipe(
                title: "Elma Püresi",
                description: "Bebeğinizin ilk ek gıdası için ideal, yumuşak ve lezzetli elma püresi.",
                ageRange: "4-6 ay",
                ingredients: [
                    "1 adet tatlı elma",
                    "1 çay kaşığı su (isteğe bağlı)"
                ],
                instructions: [
                    "Elmayı yıkayın ve kabuğunu soyun",
                    "Çekirdeklerini çıkarın ve küp küp doğrayın",
                    "Buharda veya az suda yumuşayana kadar pişirin (5-7 dakika)",
                    "Ilıdıktan sonra püre haline getirin",
                    "Gerekirse biraz su ekleyerek kıvamını ayarlayın"
                ],
                prepTime: 10,
                category: .puree
            ),
            Recipe(
                title: "Havuç Püresi",
                description: "Beta karoten açısından zengin, bebeğiniz için besleyici havuç püresi.",
                ageRange: "4-6 ay",
                ingredients: [
                    "1 orta boy havuç",
                    "1 çay kaşığı zeytinyağı (isteğe bağlı)"
                ],
                instructions: [
                    "Havucu yıkayın, soyun ve küp küp doğrayın",
                    "Buharda 10-12 dakika pişirin",
                    "Yumuşadıktan sonra püre haline getirin",
                    "İsteğe bağlı olarak 1 çay kaşığı zeytinyağı ekleyin"
                ],
                prepTime: 15,
                category: .puree
            ),
            Recipe(
                title: "Muz Püresi",
                description: "Doğal şeker içeren, hazırlaması kolay muz püresi.",
                ageRange: "4-6 ay",
                ingredients: [
                    "1/2 olgun muz"
                ],
                instructions: [
                    "Muzu soyun",
                    "Çatalla ezerek püre haline getirin",
                    "Gerekirse biraz anne sütü veya formül süt ekleyin"
                ],
                prepTime: 2,
                category: .puree
            )
        ]
    }
    
    private func get6To8MonthRecipes() -> [Recipe] {
        return [
            Recipe(
                title: "Sebze Çorbası",
                description: "Çeşitli sebzelerle hazırlanmış, besleyici ve lezzetli çorba.",
                ageRange: "6-8 ay",
                ingredients: [
                    "1 küçük patates",
                    "1 küçük havuç",
                    "1/4 kabak",
                    "1 çay kaşığı zeytinyağı",
                    "1 su bardağı su"
                ],
                instructions: [
                    "Tüm sebzeleri yıkayın, soyun ve küp küp doğrayın",
                    "Tencereye alın ve üzerine su ekleyin",
                    "Yumuşayana kadar pişirin (15-20 dakika)",
                    "Ilıdıktan sonra püre haline getirin",
                    "Zeytinyağı ekleyip karıştırın"
                ],
                prepTime: 25,
                category: .soup
            ),
            Recipe(
                title: "Yoğurtlu Meyve Püresi",
                description: "Probiyotik yoğurt ve meyve karışımı, bebeğiniz için sağlıklı bir öğün.",
                ageRange: "6-8 ay",
                ingredients: [
                    "2 yemek kaşığı tam yağlı yoğurt",
                    "1/4 elma",
                    "1/4 armut"
                ],
                instructions: [
                    "Elma ve armutu buharda pişirin",
                    "Püre haline getirin",
                    "Yoğurtla karıştırın",
                    "Oda sıcaklığında servis edin"
                ],
                prepTime: 12,
                category: .snack
            )
        ]
    }
    
    private func get8To12MonthRecipes() -> [Recipe] {
        return [
            Recipe(
                title: "Yumurta Sarısı Omlet",
                description: "Protein açısından zengin, parmak gıda olarak verilebilen yumurta sarısı omlet.",
                ageRange: "8-12 ay",
                ingredients: [
                    "1 yumurta sarısı",
                    "1 çay kaşığı tereyağı",
                    "1 yemek kaşığı rendelenmiş peynir (isteğe bağlı)"
                ],
                instructions: [
                    "Yumurta sarısını çırpın",
                    "Tavada tereyağını eritin",
                    "Yumurta sarısını dökün ve pişirin",
                    "İsteğe bağlı peynir ekleyin",
                    "Küçük parçalara bölerek servis edin"
                ],
                prepTime: 8,
                category: .fingerFood
            ),
            Recipe(
                title: "Mini Köfte",
                description: "Kıyma ile hazırlanmış, bebeğinizin kendi kendine yiyebileceği mini köfteler.",
                ageRange: "8-12 ay",
                ingredients: [
                    "100 gr kıyma",
                    "1 yemek kaşığı rendelenmiş ekmek içi",
                    "1 çay kaşığı zeytinyağı"
                ],
                instructions: [
                    "Tüm malzemeleri karıştırın",
                    "Küçük köfteler şeklinde şekillendirin",
                    "Tavada veya fırında pişirin",
                    "Soğuduktan sonra küçük parçalara bölün"
                ],
                prepTime: 20,
                category: .fingerFood
            )
        ]
    }
    
    private func get12PlusMonthRecipes() -> [Recipe] {
        return [
            Recipe(
                title: "Mercimek Çorbası",
                description: "Protein ve demir açısından zengin, aile sofrasına uygun mercimek çorbası.",
                ageRange: "12+ ay",
                ingredients: [
                    "1 su bardağı kırmızı mercimek",
                    "1 küçük soğan",
                    "1 küçük havuç",
                    "1 yemek kaşığı zeytinyağı",
                    "1 litre su"
                ],
                instructions: [
                    "Mercimeği yıkayın",
                    "Soğan ve havucu küp küp doğrayın",
                    "Zeytinyağında kavurun",
                    "Mercimek ve suyu ekleyin",
                    "Yumuşayana kadar pişirin (20-25 dakika)",
                    "Püre haline getirin"
                ],
                prepTime: 30,
                category: .soup
            )
        ]
    }
}

