//
//  MovementInputView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/14/24.
//

import SwiftUI

extension MovementInputView {
    @Observable
    class ViewModel {
        var container: ContainerView.ViewModel
        var movement: Movement
        
        init(container: ContainerView.ViewModel, movement: Movement) {
            self.container = container
            self.movement = movement
        }
        
        func saveNewMovement() async throws {
            try await Networking()
                .request(
                    options: Networking.RequestOptions(url: "/movements",
                                                       body: movement.dto,
                                                       method: .POST,
                                                       headers: [
                                                        ("application/json", "Content-Type")
                                                       ]))
        }
        
        func updateMovement() async throws {
            try await Networking()
                .request(
                    options: Networking.RequestOptions(url: "/movements/\(movement.id)",
                                                       body: movement.dto,
                                                       method: .PATCH,
                                                       headers: [
                                                        ("application/json", "Content-Type")
                                                       ]))
        }
    }
}
