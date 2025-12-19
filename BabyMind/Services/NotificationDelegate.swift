//
//  NotificationDelegate.swift
//  BabyMind
//
//  Bildirim delegate'i - uygulama açıkken de bildirim göstermek için
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationDelegate()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Uygulama açıkken bildirim geldiğinde
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // iOS 14+ için banner, ses ve badge göster
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // Kullanıcı bildirime tıkladığında
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Bildirim tıklanınca yapılacak işlemler
        let userInfo = response.notification.request.content.userInfo
        
        // Hatırlatıcı ID'si varsa ilgili sayfaya yönlendir
        if let reminderId = userInfo["reminderId"] as? String {
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowReminder"),
                object: nil,
                userInfo: ["reminderId": reminderId]
            )
        }
        
        completionHandler()
    }
}

