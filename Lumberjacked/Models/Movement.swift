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
    
    struct MovementLog: Codable, Equatable, Hashable {
        var reps: Int
        var load: String
    }
    
    var movementLogs: [MovementLog]
}

func groupMovementsBySplit(_ movements: [Movement]) -> [String] {
    var splits = Set<String>()
    for movement in movements {
        splits.insert(movement.split)
    }
    return Array(splits)
}

func getMovementsForSplit(_ movements: [Movement], split: String) -> [Movement] {
    var splitMovements = [Movement]()
    for movement in movements {
        if movement.split == split {
            splitMovements.append(movement)
        }
    }
    return splitMovements
}

func loadMovements() async -> [Movement]?  {
    let accessToken = "44b0b258a667b0e93aff0f4f3dcc9d37ab04c94f104cbb5a6f4ad8c043ed53a331b5fd7f7b7795ec37a9a285071ef18c"

    let sessionConfiguration = URLSessionConfiguration.default
    sessionConfiguration.httpAdditionalHeaders = [
        "Authorization": "Bearer \(accessToken)"
    ]
    let session = URLSession(configuration: sessionConfiguration)

    guard let url = URL(string: "http://localhost:3000/api/v1/movements") else {
        print("Invalid URL")
        return nil
    }
    let request = URLRequest(url: url)
    
    do {
        let (data, _) = try await session.data(for: request)
        if let decodedResponse = try? JSONDecoder().decode([Movement].self, from: data) {
            return decodedResponse
        }
    } catch {
        print("Invalid data")
    }
    return nil
}
