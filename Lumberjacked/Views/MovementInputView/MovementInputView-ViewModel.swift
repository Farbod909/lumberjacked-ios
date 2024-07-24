//
//  MovementInputView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/14/24.
//

import SwiftUI

extension MovementInputView {
    @Observable
    class ViewModel: BaseViewModel {
        var movement: Movement
                
        var saveActionLoading = false
        
        init(container: ContainerView.ViewModel, movement: Movement) {
            self.movement = movement
            super.init(container: container)
        }
        
        func attemptSaveNewMovement() async -> Bool {
            saveActionLoading = true
            let didSucceed = await NetworkingRequest(
                options: Networking.RequestOptions(
                    url: "/movements",
                    body: movement.dto,
                    method: .POST,
                    headers: [
                        ("application/json", "Content-Type")
                    ]),
                errorAlertItem: containerErrorAlertItem,
                errorAlertItemIsPresented: containerErrorAlertItemIsPresented)
                .attempt()
            saveActionLoading = false
            return didSucceed
        }
        
        func attemptUpdateMovement() async -> Bool {
            saveActionLoading = true
            let didSucceed = await NetworkingRequest(
                options: Networking.RequestOptions(
                    url: "/movements/\(movement.id)",
                    body: movement.dto,
                    method: .PATCH,
                    headers: [
                        ("application/json", "Content-Type")
                    ]),
                errorAlertItem: containerErrorAlertItem,
                errorAlertItemIsPresented: containerErrorAlertItemIsPresented)
                .attempt()
            saveActionLoading = false
            return didSucceed
        }
    }
}
