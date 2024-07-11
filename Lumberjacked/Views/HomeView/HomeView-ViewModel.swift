//
//  HomeView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/6/24.
//

import Foundation
import SwiftUI

extension HomeView {
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
            movements = await Networking
                .withDefaultAccessToken()
                .request(options: Networking.RequestOptions(url: "http://localhost:3000/api/v1/movements")) ?? [Movement]()
        }
    }
}
