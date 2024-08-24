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
        var notes: String?
        var warmupSets: String?
        var workingSets: String?
        var repRange: String?
        var rpe: String?
        var restTime: Int?
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

