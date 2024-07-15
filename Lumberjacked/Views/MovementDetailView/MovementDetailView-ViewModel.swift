//
//  MovementDetailView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/6/24.
//

import SwiftUI

extension MovementDetailView {
    @Observable
    class ViewModel {
        var container: ContainerView.ViewModel
        var movement: Movement
        
        init(container: ContainerView.ViewModel, movement: Movement) {
            self.container = container
            self.movement = movement
        }
        
        func loadMovementDetail(id: Int) async {
            movement = await Networking
                .withDefaultAccessToken()
                .request(
                    options: Networking.RequestOptions(url: "http://localhost:3000/api/v1/movements/\(id)"))
            ?? Movement.empty()
        }

    }
}
