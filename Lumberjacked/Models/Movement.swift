//
//  Movement.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/4/24.
//

import Foundation

struct Movement: Codable, Hashable, Identifiable  {
    var id: Int
    var name: String
    var category: String
    var notes: String?
    var createdAt: Date
    
    // recommendations
    var warmupSets: String?
    var workingSets: String?
    var repRange: String?
    var rpe: String?
    var restTime: Int? // in seconds
    
    var lastLoggedDay: String {
        if movementLogs.isEmpty {
            return ""
        } else {
            let dateComponents = Calendar.current.dateComponents(
                [.day, .year, .month],
                from: movementLogs[0].timestamp!)
            return "\(dateComponents.year!)-\(dateComponents.month!)-\(dateComponents.day!)"
        }
    }
    
    var latestLoad: String {
        if movementLogs.isEmpty {
            return "N/A"
        }
        
        return movementLogs[0].load ?? "N/A"
    }
    
    var latestReps: String {
        if movementLogs.isEmpty {
            return "N/A"
        }
        
        if let reps = movementLogs[0].reps {
            return String(reps)
        }
        
        return "N/A"
    }
    
    func isInProgress(_ bufferPeriod: Int) -> Bool {
        return mostRecentLogTimestamp.distance(to: Date.now).magnitude <= TimeInterval(bufferPeriod)
    }
    
    func lastLoggedDayBeforeBufferPeriod(_ bufferPeriod: Int) -> String {
        var lastLoggedDayBeforeBufferPeriodIndex = 0
        while true {
            if !movementLogs.indices.contains(lastLoggedDayBeforeBufferPeriodIndex) {
                return ""
            }
            if (movementLogs[lastLoggedDayBeforeBufferPeriodIndex].timestamp?.distance(to: Date.now))! <= TimeInterval(bufferPeriod) {
                lastLoggedDayBeforeBufferPeriodIndex += 1
                continue
            }
            break
        }
        let dateComponents = Calendar.current.dateComponents(
            [.day, .year, .month],
            from: movementLogs[lastLoggedDayBeforeBufferPeriodIndex].timestamp!)
        return "\(dateComponents.year!)-\(dateComponents.month!)-\(dateComponents.day!)"
    }
    
    func mostRecentLogTimestampBeforeBufferPeriod(_ bufferPeriod: Int) -> Date? {
        var mostRecentLogTimestampBufferPeriodIndex = 0
        while true {
            if !movementLogs.indices.contains(mostRecentLogTimestampBufferPeriodIndex) {
                return nil
            }
            if (movementLogs[mostRecentLogTimestampBufferPeriodIndex].timestamp?.distance(to: Date.now))! <= TimeInterval(bufferPeriod) {
                mostRecentLogTimestampBufferPeriodIndex += 1
                continue
            }
            break
        }
        return movementLogs[mostRecentLogTimestampBufferPeriodIndex].timestamp!
    }


    
    var movementLogs: [MovementLog]
    
    var hasAnyRecommendations: Bool {
        return warmupSets != nil || workingSets != nil || rpe != nil || restTime != nil
    }
    
    var mostRecentLogTimestamp: Date {
        return movementLogs.first?.timestamp ?? Date.distantFuture
    }
    
    static func empty() -> Movement {
        return Movement(id: 0, name: "", category: "", createdAt: Date.now, movementLogs: [])
    }
    
    struct MovementDTO: Codable {
        var name: String?
        var category: String?
        @NullCodable var notes: String?
        @NullCodable var warmupSets: String?
        @NullCodable var workingSets: String?
        @NullCodable var repRange: String?
        @NullCodable var rpe: String?
        @NullCodable var restTime: Int?
    }
    
    var dto: MovementDTO {
        return MovementDTO(
            name: name,
            category: category,
            notes: notes,
            warmupSets: warmupSets,
            workingSets: workingSets,
            repRange: repRange,
            rpe: rpe,
            restTime: restTime)
    }
}

struct MovementAndLog: Hashable {
    var movement: Movement
    var log: MovementLog
}

