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
}

struct MovementLog: Codable, Equatable, Hashable {
    var id: Int?
    var sets: Int?
    var reps: Int?
    var load: String?
    var timestamp: Date?
    
    struct MovementLogDto: Codable {
        var sets: Int?
        var reps: Int?
        var load: Decimal?
    }
    
    var dto: MovementLogDto {
        if let unwrappedLoad = load {
            return MovementLogDto(sets: sets, reps: reps, load: Decimal(string: unwrappedLoad))
        } else {
            return MovementLogDto(sets: sets, reps: reps, load: nil)
        }
    }
}

struct MovementAndLog: Hashable {
    var movement: Movement
    var log: MovementLog
}

