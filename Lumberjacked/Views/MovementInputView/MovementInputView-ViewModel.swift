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
        
        func saveNewMovement() async {
            let _: Movement? = await Networking
                .withDefaultAccessToken()
                .request(
                    options: Networking.RequestOptions(url: "http://localhost:3000/api/v1/movements",
                                                body: movement.dto,
                                                method: .POST,
                                                headers: [
                                                    ("application/json", "Content-Type")
                                                ]))
        }
        
        func updateMovement() async {
            let _: Movement? = await Networking
                .withDefaultAccessToken()
                .request(
                    options: Networking.RequestOptions(url: "http://localhost:3000/api/v1/movements/\(movement.id)",
                                                body: movement.dto,
                                                method: .PATCH,
                                                headers: [
                                                    ("application/json", "Content-Type")
                                                ]))
        }
    }
}
