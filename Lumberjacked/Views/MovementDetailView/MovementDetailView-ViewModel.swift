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
        
        var showErrorAlert = false
        var errorAlertItem = ErrorAlertItem()
        
        var deleteActionLoading = false
        var showDeleteConfirmationAlert = false
                
        init(container: ContainerView.ViewModel, movement: Movement) {
            self.container = container
            self.movement = movement
        }
        
        func attemptLoadMovementDetail(id: Int) async {
            do {
                movement = try await Networking()
                    .request(
                        options: Networking.RequestOptions(url: "/movements/\(id)"))
                deleteActionLoading = false
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
        }
        
        func attemptDeleteMovement(id: Int) async -> Bool {
            deleteActionLoading = true
            do {
                try await Networking()
                    .request(
                        options: Networking.RequestOptions(
                            url: "/movements/\(id)", method: .DELETE))
                deleteActionLoading = false
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
            deleteActionLoading = false
            return false
        }
    }
}
