//
//  TasksView.swift
//
//  Görevler görünümü
//

import SwiftUI

struct TasksView: View {
    let baby: Baby
    @StateObject private var taskService: TaskService
    @State private var selectedCategory: Task.TaskCategory? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var theme: ColorTheme {
        ColorTheme.theme(for: baby.gender)
    }
    
    init(baby: Baby) {
        self.baby = baby
        _taskService = StateObject(wrappedValue: TaskService(babyId: baby.id))
    }
    
    var filteredTasks: [Task] {
        var tasks = taskService.getPendingTasks()
        
        if let category = selectedCategory {
            tasks = tasks.filter { $0.category == category }
        }
        
        return tasks
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: getBackgroundGradient(),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // İlerleme Kartı
                    ProgressCard(progress: taskService.userProgress, theme: theme)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    // Kategori Filtreleri
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            TaskFilterButton(
                                title: "Tümü",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil },
                                theme: theme
                            )
                            
                            ForEach(Task.TaskCategory.allCases, id: \.self) { category in
                                TaskFilterButton(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = selectedCategory == category ? nil : category },
                                    theme: theme,
                                    color: category.color
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Bekleyen Görevler
                    if !filteredTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Bekleyen Görevler")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                                
                                Spacer()
                                
                                Text("\(filteredTasks.count) görev")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            
                            ForEach(filteredTasks) { task in
                                TaskCard(task: task, taskService: taskService, theme: theme)
                                    .padding(.horizontal, 20)
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                            
                            Text("Tüm Görevler Tamamlandı!")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                            
                            Text("Harika iş çıkardın! Sen gerçekten müthiş bir annesin! 🌟")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                    }
                    
                    // Tamamlanan Görevler (Son 5)
                    let completedTasks = taskService.getCompletedTasks().prefix(5)
                    if !completedTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Son Tamamlananlar")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                                .padding(.horizontal, 20)
                            
                            ForEach(Array(completedTasks)) { task in
                                CompletedTaskCard(task: task, theme: theme)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Görevler")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            taskService.generateDailyTasks(for: baby)
        }
    }
    
    private func getBackgroundGradient() -> [Color] {
        if colorScheme == .dark {
            return theme.backgroundGradient
        } else {
            switch baby.gender {
            case .female:
                return [
                    Color(red: 1.0, green: 0.98, blue: 0.99),
                    Color(red: 0.99, green: 0.96, blue: 0.98),
                    Color.white
                ]
            case .male:
                return [
                    Color(red: 0.98, green: 0.99, blue: 1.0),
                    Color(red: 0.97, green: 0.98, blue: 0.99),
                    Color.white
                ]
            }
        }
    }
}

// MARK: - Task Filter Button
struct TaskFilterButton: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    let theme: ColorTheme
    var color: (red: Double, green: Double, blue: Double)? = nil
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? 
                          (color != nil ? Color(red: color!.red, green: color!.green, blue: color!.blue) : theme.primary) :
                          Color(red: 0.95, green: 0.95, blue: 0.97))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Progress Card
struct ProgressCard: View {
    let progress: UserProgress
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.2))
                
                Text("İlerleme")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Toplam Puan")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("\(progress.totalPoints)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(theme.primary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Seviye")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("\(progress.level)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(theme.primary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Streak")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 16))
                        Text("\(progress.streakDays) gün")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.2))
                }
                
                Spacer()
            }
            
            if !progress.achievements.isEmpty {
                Divider()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(progress.achievements, id: \.self) { achievement in
                            Text("🏆 \(achievement)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(theme.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(theme.primary.opacity(0.1))
                                )
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
        )
    }
}

// MARK: - Task Card
struct TaskCard: View {
    let task: Task
    @ObservedObject var taskService: TaskService
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    @State private var showCompletion = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(
                        red: task.category.color.red,
                        green: task.category.color.green,
                        blue: task.category.color.blue
                    ).opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: task.category.icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color(
                        red: task.category.color.red,
                        green: task.category.color.green,
                        blue: task.category.color.blue
                    ))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(task.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    Spacer()
                    
                    // Öncelik rozeti
                    Text(task.priority.rawValue)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color(
                                    red: task.priority.color.red,
                                    green: task.priority.color.green,
                                    blue: task.priority.color.blue
                                ))
                        )
                }
                
                Text(task.description)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("+\(task.points) puan")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.2))
                    
                    Spacer()
                    
                    Text(task.category.rawValue)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: {
                taskService.completeTask(task)
                showCompletion = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showCompletion = false
                }
            }) {
                ZStack {
                    Circle()
                        .fill(theme.primary.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    if showCompletion {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                    } else {
                        Image(systemName: "circle")
                            .font(.system(size: 20))
                            .foregroundColor(theme.primary)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
        )
    }
}

// MARK: - Completed Task Card
struct CompletedTaskCard: View {
    let task: Task
    let theme: ColorTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.8) : Color(red: 0.2, green: 0.2, blue: 0.25))
                    .strikethrough()
                
                if let completedAt = task.completedAt {
                    Text(completedAt, style: .relative)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("+\(task.points)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.2))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(red: 0.25, green: 0.25, blue: 0.3) : Color(red: 0.98, green: 0.98, blue: 0.99))
        )
    }
}


