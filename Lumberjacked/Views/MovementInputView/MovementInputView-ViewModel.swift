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
        
        var showErrorAlert = false
        var errorAlertItem = ErrorAlertItem()
        
        var saveActionLoading = false
        
        init(container: ContainerView.ViewModel, movement: Movement) {
            self.container = container
            self.movement = movement
        }
        
        func attemptSaveNewMovement() async -> Bool {
            saveActionLoading = true
            do {
                try await Networking()
                    .request(
                        options: Networking.RequestOptions(url: "/movements",
                                                           body: movement.dto,
                                                           method: .POST,
                                                           headers: [
                                                            ("application/json", "Content-Type")
                                                           ]))
                saveActionLoading = false
                return true
            } catch let error as RemoteNetworkingError {
                errorAlertItem = ErrorAlertItem(
                    title: error.error,
                    messages: error.messages)
                showErrorAlert = true
            } catch {
                errorAlertItem = ErrorAlertItem(
                    title: "Unknown Error",
                    messages: [error.localizedDescription])
                showErrorAlert = true
            }
            saveActionLoading = false
            return false
        }
        
        func attemptUpdateMovement() async -> Bool {
            saveActionLoading = true
            do {
                try await Networking()
                    .request(
                        options: Networking.RequestOptions(url: "/movements/\(movement.id)",
                                                           body: movement.dto,
                                                           method: .PATCH,
                                                           headers: [
                                                            ("application/json", "Content-Type")
                                                           ]))
                saveActionLoading = false
                return true
            } catch let error as RemoteNetworkingError {
                errorAlertItem = ErrorAlertItem(
                    title: error.error,
                    messages: error.messages)
                showErrorAlert = true
            } catch {
                errorAlertItem = ErrorAlertItem(
                    title: "Unknown Error",
                    messages: [error.localizedDescription])
                showErrorAlert = true
            }
            saveActionLoading = false
            return false
        }
    }
}
