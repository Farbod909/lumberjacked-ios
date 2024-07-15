//
//  HomeView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/6/24.
//

import SwiftUI

extension HomeView {
    @Observable
    class ViewModel {
        var container: ContainerView.ViewModel
        var movements = [Movement]()
        
        init(container: ContainerView.ViewModel) {
            self.container = container
        }
        
        /*
         Get all unique splits, ordered by most recent log timestamp.
         */
        func getAllSplits() -> [String] {
            var uniqueSplits = Set<String>()
            var orderedSplits = Array<String>()
            for movement in movements.sorted(by: {
                $0.mostRecentLogTimestamp >= $1.mostRecentLogTimestamp
            }) {
                if (!uniqueSplits.contains(movement.split)) {
                    orderedSplits.append(movement.split)
                    uniqueSplits.insert(movement.split)
                }
            }
            return orderedSplits
        }

        /*
         Get all movements for a given split, ordered by most recent log
         timestamp.
         */
        func getMovements(for split: String) -> [Movement] {
            var splitMovements = [Movement]()
            for movement in movements.sorted(by: {
                $0.mostRecentLogTimestamp >= $1.mostRecentLogTimestamp
            }) {
                if movement.split == split {
                    splitMovements.append(movement)
                }
            }
            return splitMovements
        }

        func loadAllMovements() async {
            movements = await Networking
                .withDefaultAccessToken()
                .request(options: Networking.RequestOptions(url: "http://localhost:3000/api/v1/movements")) ?? [Movement]()
        }
    }
}
