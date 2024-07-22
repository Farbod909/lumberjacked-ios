//
//  HomeView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/6/24.
//

import SwiftUI

extension HomeView {
    @Observable
    class ViewModel {
        var container: ContainerView.ViewModel
        var movements = [Movement]()
        
        var isShowingLoginSheet = false
        var isLoggedIn = Keychain.standard.read(service: "accessToken", account: "lumberjacked") != nil
        
        var showErrorAlert = false
        var errorAlertItem = ErrorAlertItem()
        
        var isLoadingMovements = true
        
        init(container: ContainerView.ViewModel) {
            self.container = container
        }
        
        /*
         Get all unique splits, ordered by most recent log timestamp.
         */
        func getAllSplits() -> [String] {
            var uniqueSplits = Set<String>()
            var orderedSplits = Array<String>()
            for movement in movements.sorted(by: {
                $0.mostRecentLogTimestamp >= $1.mostRecentLogTimestamp
            }) {
                if (!uniqueSplits.contains(movement.split)) {
                    orderedSplits.append(movement.split)
                    uniqueSplits.insert(movement.split)
                }
            }
            return orderedSplits
        }

        /*
         Get all movements for a given split, ordered by most recent log
         timestamp.
         */
        func getMovements(for split: String) -> [Movement] {
            var splitMovements = [Movement]()
            for movement in movements.sorted(by: {
                $0.mostRecentLogTimestamp >= $1.mostRecentLogTimestamp
            }) {
                if movement.split == split {
                    splitMovements.append(movement)
                }
            }
            return splitMovements
        }

        func attemptLoadAllMovements() async {
            if isLoggedIn {
                isLoadingMovements = true
                do {
                    movements = try await Networking()
                        .request(options: Networking.RequestOptions(url: "/movements"))
                    isLoadingMovements = false
                } catch let error as RemoteNetworkingError {
                    errorAlertItem = ErrorAlertItem(
                        title: error.error, messages: error.messages)
                    showErrorAlert = true
                } catch {
                    errorAlertItem = ErrorAlertItem(
                        title: "Unknown Error", messages: [error.localizedDescription])
                    showErrorAlert = true
                }
                isLoadingMovements = false
            }
        }
                
        func attemptLogout() async {
            do {
                try await Networking().request(
                    options: Networking.RequestOptions(url: "/auth/logout"))
                Keychain.standard.delete(service: "accessToken", account: "lumberjacked")
                isShowingLoginSheet = true
                isLoggedIn = false
                movements = []
            } catch let error as RemoteNetworkingError {
                errorAlertItem = ErrorAlertItem(
                    title: error.error, messages: error.messages)
                showErrorAlert = true
            } catch {
                errorAlertItem = ErrorAlertItem(
                    title: "Unknown Error", messages: [error.localizedDescription])
                showErrorAlert = true
            }
        }
        
        func showLoginPageIfNotLoggedIn() {
            if Keychain.standard.read(service: "accessToken", account: "lumberjacked") == nil {
                isLoggedIn = false
                isShowingLoginSheet = true
            } else {
                print(Keychain.standard.read(service: "accessToken", account: "lumberjacked", type: String.self)!)
            }
        }
    }
}
