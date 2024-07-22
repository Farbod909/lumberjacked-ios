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
                
        var deleteActionLoading = false
        var showDeleteConfirmationAlert = false
                
        init(container: ContainerView.ViewModel, movement: Movement) {
            self.container = container
            self.movement = movement
        }
        
        func attemptLoadMovementDetail(id: Int) async {
            if let response = await container.attemptRequest(
                options: Networking.RequestOptions(url: "/movements/\(id)"), outputType: Movement.self) {
                movement = response
            }
        }
        
        func attemptDeleteMovement(id: Int) async -> Bool {
            deleteActionLoading = true
            let didSucceed = await container.attemptRequest(
                options: Networking.RequestOptions(
                    url: "/movements/\(id)", method: .DELETE))
            deleteActionLoading = false
            return didSucceed
        }
    }
}
