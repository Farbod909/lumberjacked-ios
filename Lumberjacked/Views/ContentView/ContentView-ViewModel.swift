//
//  ContentView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/6/24.
//

import Foundation
import SwiftUI

extension ContentView {
    @Observable
    class ViewModel {
        var container: ContainerView.ViewModel
        var movements = [Movement]()
        
        init(container: ContainerView.ViewModel) {
            self.container = container
        }
        
        func groupMovementsBySplit() -> [String] {
            var splits = Set<String>()
            for movement in movements {
                splits.insert(movement.split)
            }
            return Array(splits)
        }

        func getMovementsForSplit(split: String) -> [Movement] {
            var splitMovements = [Movement]()
            for movement in movements {
                if movement.split == split {
                    splitMovements.append(movement)
                }
            }
            return splitMovements
        }

        func loadAllMovements() async {
            let accessToken = "44b0b258a667b0e93aff0f4f3dcc9d37ab04c94f104cbb5a6f4ad8c043ed53a331b5fd7f7b7795ec37a9a285071ef18c"

            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(accessToken)"
            ]
            let session = URLSession(configuration: sessionConfiguration)

            guard let url = URL(string: "http://localhost:3000/api/v1/movements") else {
                print("Invalid URL")
                return
            }
            let request = URLRequest(url: url)
            
            do {
                let (data, _) = try await session.data(for: request)
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                if let decodedResponse = try? decoder.decode([Movement].self, from: data) {
                    movements = decodedResponse
                }
            } catch {
                print("Invalid data")
            }
        }
    }
}
