//
//  MovementLog.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/9/24.
//

import Foundation

struct MovementLog: Codable, Equatable, Hashable, Identifiable {
    var id: Int?
    var sets: Int?
    var reps: Int?
    var load: String?
    var timestamp: Date?
    
    struct MovementLogDTO: Codable {
        var sets: Int?
        var reps: Int?
        var load: Decimal?
    }
    
    var dto: MovementLogDTO {
        if let unwrappedLoad = load {
            return MovementLogDTO(sets: sets, reps: reps, load: Decimal(string: unwrappedLoad))
        } else {
            return MovementLogDTO(sets: sets, reps: reps, load: nil)
        }
    }
}
