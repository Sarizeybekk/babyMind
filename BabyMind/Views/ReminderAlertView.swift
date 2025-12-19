//
//  ReminderAlertView.swift
//  BabyMind
//
//  Hatırlatıcı alarm görünümü
//

import SwiftUI
import Combine

struct ReminderAlertView: View {
    let reminder: Reminder
    let onDismiss: () -> Void
    let onComplete: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        let theme = ColorTheme.theme(for: .female) // Default theme, baby bilgisi yok
        
        ZStack {
            // Arka plan blur
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Alert kartı
            VStack(spacing: 24) {
                // İkon ve animasyon
                ZStack {
                    Circle()
                        .fill(theme.primary.opacity(0.15))
                        .frame(width: 80, height: 80)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.0)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    Image(systemName: reminder.type.icon)
                        .font(.system(size: 40))
                        .foregroundColor(theme.primary)
                }
                .padding(.top, 20)
                
                // Başlık
                VStack(spacing: 8) {
                    Text("🔔 Hatırlatıcı")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(theme.text.opacity(0.7))
                    
                    Text(reminder.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(theme.text)
                        .multilineTextAlignment(.center)
                    
                    if !reminder.description.isEmpty {
                        Text(reminder.description)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(theme.text.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
                
                // Tarih
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(theme.primary)
                    Text(reminder.date, style: .time)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(theme.text)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primary.opacity(0.1))
                )
                
                // Butonlar
                HStack(spacing: 12) {
                    // Kapat
                    Button(action: onDismiss) {
                        Text("Daha Sonra")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(theme.text)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(theme.primary.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    
                    // Tamamla
                    Button(action: {
                        HapticManager.shared.notification(type: .success)
                        onComplete()
                        onDismiss()
                    }) {
                        Text("Tamamlandı")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [theme.primary, theme.primaryDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(isAnimating ? 1.0 : 0.9)
            .opacity(isAnimating ? 1.0 : 0.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
            // Titreşim efekti
            HapticManager.shared.notification(type: .warning)
        }
    }
}

// Global alert manager
class ReminderAlertManager: ObservableObject {
    @Published var currentReminder: Reminder?
    @Published var showAlert = false
    
    static let shared = ReminderAlertManager()
    
    private init() {
        // Notification dinle
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleReminderAlert),
            name: NSNotification.Name("ReminderAlert"),
            object: nil
        )
    }
    
    @objc private func handleReminderAlert(_ notification: Notification) {
        if let reminderIdString = notification.userInfo?["reminderId"] as? String,
           let reminderId = UUID(uuidString: reminderIdString),
           let reminder = ReminderService.shared.getReminder(by: reminderId) {
            DispatchQueue.main.async {
                // Eğer zaten bir alert gösteriliyorsa, yeni olanı bekle
                if !self.showAlert {
                    self.currentReminder = reminder
                    self.showAlert = true
                }
            }
        }
    }
    
    func dismiss() {
        if let reminder = currentReminder {
            ReminderService.shared.markReminderAsShown(reminder)
        }
        showAlert = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentReminder = nil
        }
    }
}

