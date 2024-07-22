//
//  LogInputView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/8/24.
//

import SwiftUI

extension LogInputView {
    @Observable
    class ViewModel {
        var container: ContainerView.ViewModel
        
        var movementLog: MovementLog
        var movement: Movement
        
        var toolbarActionLoading = false

        
        init(container: ContainerView.ViewModel, movementLog: MovementLog, movement: Movement) {
            self.container = container
            self.movementLog = movementLog
            self.movement = movement
        }
        
        func attemptUpdateLog() async -> Bool {
            guard let movementLogId = movementLog.id else {
                print("Cannot update movement log with no id.")
                toolbarActionLoading = false
                return false
            }
            
            toolbarActionLoading = true
            let didSucceed = await container.attemptRequest(
                options: Networking.RequestOptions(
                    url: "/movement-logs/\(movementLogId)",
                    body: movementLog.dto,
                    method: .PATCH,
                    headers: [
                        ("application/json", "Content-Type")
                    ]))
            toolbarActionLoading = false
            return didSucceed
        }
        
        func attemptSaveNewLog() async -> Bool {
            toolbarActionLoading = true
            let didSucceed = await container.attemptRequest(
                options: Networking.RequestOptions(url: "/movements/\(movement.id)/logs",
                                                   body: movementLog.dto,
                                                   method: .POST,
                                                   headers: [
                                                    ("application/json", "Content-Type")
                                                   ]))
            toolbarActionLoading = false
            return didSucceed
        }
        
        func attemptDeleteLog() async -> Bool {
            guard let movementLogId = movementLog.id else {
                print("Cannot delete movement log with no id.")
                toolbarActionLoading = false
                return false
            }
            
            toolbarActionLoading = true
            let didSucceed = await container.attemptRequest(
                options: Networking.RequestOptions(url: "/movement-logs/\(movementLogId)",
                                                   method: .DELETE))
            toolbarActionLoading = false
            return didSucceed
        }
    }
}
