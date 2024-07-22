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
        
        var showErrorAlert = false
        var errorAlertItem = ErrorAlertItem()

        var toolbarActionLoading = false

        
        init(container: ContainerView.ViewModel, movementLog: MovementLog, movement: Movement) {
            self.container = container
            self.movementLog = movementLog
            self.movement = movement
        }
        
        func attemptUpdateLog() async -> Bool {
            toolbarActionLoading = true
            guard let movementLogId = movementLog.id else {
                print("Cannot update movement log with no id.")
                toolbarActionLoading = false
                return false
            }
            do {
                try await Networking.shared
                    .request(
                        options: Networking.RequestOptions(url: "/movement-logs/\(movementLogId)",
                                                           body: movementLog.dto,
                                                           method: .PATCH,
                                                           headers: [
                                                            ("application/json", "Content-Type")
                                                           ]))
                toolbarActionLoading = false
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
            toolbarActionLoading = false
            return false
        }
        
        func attemptSaveNewLog() async -> Bool {
            toolbarActionLoading = true
            do {
                try await Networking.shared
                    .request(
                        options: Networking.RequestOptions(url: "/movements/\(movement.id)/logs",
                                                           body: movementLog.dto,
                                                           method: .POST,
                                                           headers: [
                                                            ("application/json", "Content-Type")
                                                           ]))
                toolbarActionLoading = false
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
            toolbarActionLoading = false
            return false
        }
        
        func attemptDeleteLog() async -> Bool {
            toolbarActionLoading = true
            guard let movementLogId = movementLog.id else {
                print("Cannot delete movement log with no id.")
                toolbarActionLoading = false
                return false
            }
            
            do {
                try await Networking.shared
                    .request(
                        options: Networking.RequestOptions(url: "/movement-logs/\(movementLogId)",
                                                           method: .DELETE))
                toolbarActionLoading = false
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
            toolbarActionLoading = false
            return false
        }

    }
}
