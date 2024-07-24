//
//  MovementDetailView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/6/24.
//

import SwiftUI

extension MovementDetailView {
    @Observable
    class ViewModel: BaseViewModel {
        var movement: Movement
                
        var deleteActionLoading = false
        var showDeleteConfirmationAlert = false
                
        init(container: ContainerView.ViewModel, movement: Movement) {
            self.movement = movement
            super.init(container: container)
        }
        
        func attemptLoadMovementDetail(id: Int) async {
            if let response = await NetworkingRequest(
                options: Networking.RequestOptions(url: "/movements/\(id)"),
                errorAlertItem: containerErrorAlertItem,
                errorAlertItemIsPresented: containerErrorAlertItemIsPresented
            ).attempt(outputType: Movement.self) {
                movement = response
            }
        }
        
        func attemptDeleteMovement(id: Int) async -> Bool {
            deleteActionLoading = true
            let didSucceed = await NetworkingRequest(
                options: Networking.RequestOptions(url: "/movements/\(id)", method: .DELETE),
                errorAlertItem: containerErrorAlertItem,
                errorAlertItemIsPresented: containerErrorAlertItemIsPresented)
            .attempt()
            deleteActionLoading = false
            return didSucceed
        }
    }
}
