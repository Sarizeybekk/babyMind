//
//  ChatView.swift
//  BabyMind
//
//  AI Chatbot ekranı
//

import SwiftUI

struct ChatView: View {
    let baby: Baby
    @StateObject private var chatService = ChatService()
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        let theme = ColorTheme.theme(for: baby.gender)
        
        ZStack {
            // Gradient Arka Plan
            LinearGradient(
                colors: theme.backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Mesajlar
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            // Hoş geldin mesajı
                            if messages.isEmpty {
                                WelcomeMessageView(baby: baby, theme: theme)
                                    .padding(.top, 20)
                            }
                            
                            // Mesajlar
                            ForEach(messages) { message in
                                MessageBubble(message: message, theme: theme)
                                    .id(message.id)
                            }
                            
                            // Typing indicator
                            if isLoading {
                                TypingIndicator(theme: theme)
                                    .id("typing")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { oldValue, newValue in
                        if newValue > oldValue, let lastMessage = messages.last {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    .onChange(of: isLoading) { oldValue, newValue in
                        if newValue {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation {
                                    proxy.scrollTo("typing", anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                // Hızlı sorular
                if messages.isEmpty {
                    QuickQuestionsView(questions: chatService.getQuickQuestions(), theme: theme, onQuestionTap: { question in
                        sendMessage(question)
                    })
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                // Input alanı
                ChatInputView(
                    text: $inputText,
                    isLoading: isLoading,
                    theme: theme,
                    onSend: {
                        sendMessage(inputText)
                        inputText = ""
                    }
                )
                .padding()
            }
        }
        .navigationTitle("AI Asistan")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // İlk hoş geldin mesajı
            if messages.isEmpty {
                let welcomeMessage = ChatMessage(
                    content: "Merhaba! 👋 Bebeğiniz \(baby.name.isEmpty ? "bebeğiniz" : baby.name) hakkında size nasıl yardımcı olabilirim? Beslenme, uyku, gelişim veya sağlık konularında sorularınızı sorabilirsiniz.",
                    isUser: false
                )
                messages.append(welcomeMessage)
            }
        }
    }
    
    private func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // Kullanıcı mesajı ekle
        let userMessage = ChatMessage(content: text, isUser: true)
        messages.append(userMessage)
        
        // AI yanıtı al
        isLoading = true
        HapticManager.shared.impact(style: .light)
        
        Task {
            let response = await chatService.getResponse(for: text, baby: baby)
            
            await MainActor.run {
                let aiMessage = ChatMessage(content: response, isUser: false)
                messages.append(aiMessage)
                isLoading = false
                HapticManager.shared.notification(type: .success)
            }
        }
    }
}

struct WelcomeMessageView: View {
    let baby: Baby
    let theme: ColorTheme
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: theme.cardGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            Text("AI Asistanınız")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)
            
            Text("Bebeğiniz hakkında her şeyi sorabilirsiniz")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: theme.primary.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    let theme: ColorTheme
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(message.isUser ? .white : theme.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.isUser ?
                        LinearGradient(
                            colors: [
                                theme.primary,
                                theme.primaryDark
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.white, Color.white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            
            if !message.isUser {
                Spacer(minLength: 50)
            }
        }
    }
}

struct TypingIndicator: View {
    let theme: ColorTheme
    @State private var animationPhase = 0
    @State private var timer: Timer?
    
    var body: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(theme.primary.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                        .opacity(animationPhase == index ? 1.0 : 0.5)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            Spacer(minLength: 50)
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.4)) {
                    animationPhase = (animationPhase + 1) % 3
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

struct QuickQuestionsView: View {
    let questions: [String]
    let theme: ColorTheme
    let onQuestionTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hızlı Sorular")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(questions, id: \.self) { question in
                        Button(action: {
                            HapticManager.shared.impact(style: .light)
                            onQuestionTap(question)
                        }) {
                            Text(question)
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(theme.primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white)
                                        .shadow(color: theme.primary.opacity(0.2), radius: 5, x: 0, y: 2)
                                )
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct ChatInputView: View {
    @Binding var text: String
    let isLoading: Bool
    let theme: ColorTheme
    let onSend: () -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Mesajınızı yazın...", text: $text, axis: .vertical)
                .font(.system(size: 16, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(25)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .focused($isFocused)
                .lineLimit(1...4)
                .onSubmit {
                    if !text.isEmpty {
                        onSend()
                    }
                }
            
            Button(action: {
                if !text.isEmpty && !isLoading {
                    onSend()
                    isFocused = false
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: text.isEmpty || isLoading ?
                                [Color.gray.opacity(0.3), Color.gray.opacity(0.3)] :
                                [theme.primary, theme.primaryDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "arrow.up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(text.isEmpty || isLoading ? .gray : .white)
                }
            }
            .disabled(text.isEmpty || isLoading)
        }
    }
}

#Preview {
    NavigationView {
        ChatView(
            baby: Baby(
                name: "Bebek",
                birthDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
                gender: .male,
                birthWeight: 3.2,
                birthHeight: 50
            )
        )
    }
}
