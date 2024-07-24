//
//  HomeView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/6/24.
//

import SwiftUI

extension HomeView {
    @Observable
    class ViewModel: BaseViewModel {
        var movements = [Movement]()
        
        var isShowingLoginSheet = false
        var isLoggedIn = Keychain.standard.read(
            service: "accessToken", account: "lumberjacked") != nil
        var isLoadingMovements = false
        var hasNotYetAttemptedToLoadMovements = true
        var isLoadingLogout = false
                
        /*
         Get all unique splits, ordered by most recent log timestamp.
         */
        func getAllSplits() -> [String] {
            var uniqueSplits = Set<String>()
            var orderedSplits = Array<String>()
            for movement in movements.sorted(by: {
                $0.mostRecentLogTimestamp >= $1.mostRecentLogTimestamp
            }) {
                if !uniqueSplits.contains(movement.split) {
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
                hasNotYetAttemptedToLoadMovements = false
                isLoadingMovements = true
                if let response = await NetworkingRequest(
                    options: Networking.RequestOptions(url: "/movements"),
                    errorAlertItem: containerErrorAlertItem,
                    errorAlertItemIsPresented: containerErrorAlertItemIsPresented
                ).attempt(outputType: [Movement].self) {
                    movements = response
                }
                isLoadingMovements = false
            }
        }
                
        func attemptLogout() async {
            isLoadingLogout = true
            if await NetworkingRequest(
                options: Networking.RequestOptions(url: "/auth/logout"),
                errorAlertItem: containerErrorAlertItem,
                errorAlertItemIsPresented: containerErrorAlertItemIsPresented
            ).attempt() {
                Keychain.standard.delete(service: "accessToken", account: "lumberjacked")
                isShowingLoginSheet = true
                isLoggedIn = false
                movements = []
            }
            isLoadingLogout = false
        }
        
        func showLoginPageIfNotLoggedIn() {
            if Keychain.standard.read(service: "accessToken", account: "lumberjacked") == nil {
                isLoggedIn = false
                isShowingLoginSheet = true
            } else {
                // DEBUG
                print(Keychain.standard.read(
                    service: "accessToken", account: "lumberjacked", type: String.self)!)
            }
        }
    }
}
