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
        var saveImage = ""
        
        init(container: ContainerView.ViewModel, movementLog: MovementLog, movement: Movement) {
            self.container = container
            self.movementLog = movementLog
            self.movement = movement
        }
        
        func updateLog() async throws {
            guard let movementLogId = movementLog.id else {
                print("Cannot update movement log with no id.")
                return
            }
            
            try await Networking()
                .request(
                    options: Networking.RequestOptions(url: "/movement-logs/\(movementLogId)",
                                                       body: movementLog.dto,
                                                       method: .PATCH,
                                                       headers: [
                                                        ("application/json", "Content-Type")
                                                       ]))
        }
        
        func saveNewLog() async throws {
            try await Networking()
                .request(
                    options: Networking.RequestOptions(url: "/movements/\(movement.id)/logs",
                                                       body: movementLog.dto,
                                                       method: .POST,
                                                       headers: [
                                                        ("application/json", "Content-Type")
                                                       ]))
        }
        
        func deleteLog() async throws {
            guard let movementLogId = movementLog.id else {
                print("Cannot delete movement log with no id.")
                return
            }
            
            try await Networking()
                .request(
                    options: Networking.RequestOptions(url: "/movement-logs/\(movementLogId)",
                                                       method: .DELETE))
        }

    }
}
