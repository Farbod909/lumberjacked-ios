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
        
        func updateLog() async {
            guard let movementLogId = movementLog.id else {
                print("Cannot update movement log with no id.")
                return
            }
            
            let _: MovementLog? = await Networking
                .withDefaultAccessToken()
                .request(
                    options: Networking.RequestOptions(url: "http://localhost:3000/api/v1/movement-logs/\(movementLogId)",
                                                body: movementLog.dto,
                                                method: .PATCH,
                                                headers: [
                                                    ("application/json", "Content-Type")
                                                ]))
        }
        
        func saveNewLog() async {
            let _: MovementLog? = await Networking
                .withDefaultAccessToken()
                .request(
                    options: Networking.RequestOptions(url: "http://localhost:3000/api/v1/movements/\(movement.id)/logs",
                                                body: movementLog.dto,
                                                method: .POST,
                                                headers: [
                                                    ("application/json", "Content-Type")
                                                ])) ?? MovementLog()
        }
        
        func deleteLog() async {
            guard let movementLogId = movementLog.id else {
                print("Cannot delete movement log with no id.")
                return
            }
            
            let _: MovementLog? = await Networking
                .withDefaultAccessToken()
                .request(
                    options: Networking.RequestOptions(url: "http://localhost:3000/api/v1/movement-logs/\(movementLogId)",
                                                method: .DELETE)) ?? MovementLog()
        }

    }
}
