//
//  CloudKitService.swift
//  BabyMind
//
//  iCloud Sync servisi
//

import Foundation
import CloudKit
import Combine

class CloudKitService: ObservableObject {
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    
    init() {
        // CloudKit container - simülatörde CloudKit capability'si olmayabilir
        // Bu yüzden default container kullan (daha güvenli)
        self.container = CKContainer.default()
        self.privateDatabase = container.privateCloudDatabase
    }
    
    func syncBabies(_ babies: [Baby]) async throws {
        await MainActor.run {
            isSyncing = true
            syncError = nil
        }
        
        defer {
            Task { @MainActor in
                isSyncing = false
                lastSyncDate = Date()
            }
        }
        
        // Mevcut kayıtları al
        let existingRecords = try await fetchExistingRecords(recordType: "Baby")
        
        // Yeni kayıtları ekle veya güncelle
        for baby in babies {
            let recordID = CKRecord.ID(recordName: baby.id.uuidString)
            let record = existingRecords[recordID] ?? CKRecord(recordType: "Baby", recordID: recordID)
            
            record["name"] = baby.name
            record["birthDate"] = baby.birthDate
            record["gender"] = baby.gender.rawValue
            record["birthWeight"] = baby.birthWeight
            record["birthHeight"] = baby.birthHeight
            
            if let currentWeight = baby.currentWeight {
                record["currentWeight"] = currentWeight
            }
            if let currentHeight = baby.currentHeight {
                record["currentHeight"] = currentHeight
            }
            
            try await privateDatabase.save(record)
        }
    }
    
    func fetchBabies() async throws -> [Baby] {
        let query = CKQuery(recordType: "Baby", predicate: NSPredicate(value: true))
        let (matchResults, _) = try await privateDatabase.records(matching: query)
        
        var babies: [Baby] = []
        
        for (_, result) in matchResults {
            switch result {
            case .success(let record):
                if let baby = babyFromRecord(record) {
                    babies.append(baby)
                }
            case .failure(let error):
                print("Kayıt alınırken hata: \(error)")
            }
        }
        
        return babies
    }
    
    private func fetchExistingRecords(recordType: String) async throws -> [CKRecord.ID: CKRecord] {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        let (matchResults, _) = try await privateDatabase.records(matching: query)
        
        var records: [CKRecord.ID: CKRecord] = [:]
        
        for (recordID, result) in matchResults {
            switch result {
            case .success(let record):
                records[recordID] = record
            case .failure:
                break
            }
        }
        
        return records
    }
    
    private func babyFromRecord(_ record: CKRecord) -> Baby? {
        guard let name = record["name"] as? String,
              let birthDate = record["birthDate"] as? Date,
              let genderString = record["gender"] as? String,
              let gender = Baby.Gender(rawValue: genderString),
              let birthWeight = record["birthWeight"] as? Double,
              let birthHeight = record["birthHeight"] as? Double else {
            return nil
        }
        
        let currentWeight = record["currentWeight"] as? Double
        let currentHeight = record["currentHeight"] as? Double
        
        return Baby(
            id: UUID(uuidString: record.recordID.recordName) ?? UUID(),
            name: name,
            birthDate: birthDate,
            gender: gender,
            birthWeight: birthWeight,
            currentWeight: currentWeight,
            birthHeight: birthHeight,
            currentHeight: currentHeight
        )
    }
    
    func checkAccountStatus() async -> CKAccountStatus {
        do {
            return try await container.accountStatus()
        } catch {
            return .couldNotDetermine
        }
    }
}

