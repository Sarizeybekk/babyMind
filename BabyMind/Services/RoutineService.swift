//
//  RoutineService.swift
//
//  Rutin servisi
//

import Foundation
import Combine

class RoutineService: ObservableObject {
    @Published var routines: [Routine] = []
    @Published var routineSchedules: [RoutineSchedule] = []
    private let babyId: UUID
    
    init(babyId: UUID) {
        self.babyId = babyId
        loadRoutines()
        initializeRoutineSchedules()
    }
    
    func initializeRoutineSchedules() {
        // Yaşa göre rutin önerileri
        routineSchedules = [
            RoutineSchedule(
                type: .sleep,
                times: [],
                ageRange: "0-3 ay",
                description: "14-17 saat uyku. Gece uykusu 8-9 saat (kesintili), gündüz 6-8 saat."
            ),
            RoutineSchedule(
                type: .feeding,
                times: [],
                ageRange: "0-3 ay",
                description: "2-3 saatte bir beslenme. Günlük 8-12 kez."
            ),
            RoutineSchedule(
                type: .sleep,
                times: [],
                ageRange: "4-6 ay",
                description: "12-16 saat uyku. Gece uykusu 9-10 saat, gündüz 3-5 saat."
            ),
            RoutineSchedule(
                type: .feeding,
                times: [],
                ageRange: "4-6 ay",
                description: "3-4 saatte bir beslenme. Günlük 6-8 kez."
            )
        ]
    }
    
    func addRoutine(_ routine: Routine) {
        routines.append(routine)
        routines.sort { $0.time < $1.time }
        saveRoutines()
    }
    
    func completeRoutine(_ routine: Routine, date: Date = Date()) {
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            var updated = routine
            updated.isCompleted = true
            updated.completionDate = date
            routines[index] = updated
            saveRoutines()
        }
    }
    
    func deleteRoutine(_ routine: Routine) {
        routines.removeAll { $0.id == routine.id }
        saveRoutines()
    }
    
    func getRoutineSuccessScore(days: Int = 7) -> Double {
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) else {
            return 0
        }
        
        let recentRoutines = routines.filter { $0.time >= cutoffDate }
        guard !recentRoutines.isEmpty else { return 0 }
        
        let completed = recentRoutines.filter { $0.isCompleted }.count
        return Double(completed) / Double(recentRoutines.count) * 100.0
    }
    
    func getRecommendedRoutines(ageInMonths: Int) -> [RoutineSchedule] {
        return routineSchedules.filter { schedule in
            let ageRange = schedule.ageRange
            if ageRange.contains("0-3") {
                return ageInMonths < 4
            } else if ageRange.contains("4-6") {
                return ageInMonths >= 4 && ageInMonths < 7
            } else if ageRange.contains("6-12") {
                return ageInMonths >= 6 && ageInMonths < 12
            }
            return false
        }
    }
    
    private func saveRoutines() {
        if let encoded = try? JSONEncoder().encode(routines) {
            UserDefaults.standard.set(encoded, forKey: "routines_\(babyId.uuidString)")
        }
    }
    
    private func loadRoutines() {
        if let data = UserDefaults.standard.data(forKey: "routines_\(babyId.uuidString)"),
           let decoded = try? JSONDecoder().decode([Routine].self, from: data) {
            routines = decoded.sorted { $0.time < $1.time }
        }
    }
}


