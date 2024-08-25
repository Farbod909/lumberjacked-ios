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
    var notes: String?
    var timestamp: Date?
    
    var requiredFieldsFullyPopulated: Bool {
        return sets != nil && reps != nil && load != nil && load != ""
    }
    
    struct MovementLogDTO: Codable {
        var sets: Int?
        var reps: Int?
        var load: Decimal?
        @NullCodable var notes: String?
    }
    
    var dto: MovementLogDTO {
        return MovementLogDTO(
            sets: sets, reps: reps, load: Decimal(string: load!) ?? nil, notes: notes)
    }
    
    // Returns a MovementLog instance that just pre-populates input fields, except notes.
    var withJustInputFields: MovementLog {
        return MovementLog(sets: sets, reps: reps, load: load)
    }
}
