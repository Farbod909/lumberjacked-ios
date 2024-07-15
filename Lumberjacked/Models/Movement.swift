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
    var split: String
    var description: String?
    
    // recommendations
    var warmupSets: String?
    var workingSets: String?
    var rpe: String?
    var restTime: Int? // in seconds
    
    var movementLogs: [MovementLog]
    
    var hasAnyRecommendations: Bool {
        return warmupSets != nil || workingSets != nil || rpe != nil || restTime != nil
    }
    
    var mostRecentLogTimestamp: Date {
        return movementLogs.first?.timestamp ?? Date.distantPast
    }
    
    static func empty() -> Movement {
        return Movement(id: 0, name: "", split: "", movementLogs: [])
    }
}

struct MovementAndLog: Hashable {
    var movement: Movement
    var log: MovementLog
}

