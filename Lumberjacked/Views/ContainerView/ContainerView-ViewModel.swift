//
//  ContainerView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/8/24.
//

import SwiftUI

extension ContainerView {
    @Observable
    class ViewModel {
        var path = NavigationPath()
        
        var showErrorAlert = false
        var errorAlertItem = ErrorAlertItem()
        
        @ObservationIgnored
        lazy var homeViewModel = {
            HomeView.ViewModel(container: self)
        }()
        
        func attemptRequest<ResponseType: Decodable>(
            options: Networking.RequestOptions,
            outputType: ResponseType.Type
        ) async -> ResponseType? {
            do {
                return try await Networking.shared.request(options: options)
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
            return nil
        }
        
        func attemptRequest(options: Networking.RequestOptions) async -> Bool {
            do {
                try await Networking.shared.request(options: options)
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
            return false
        }
    }
}
