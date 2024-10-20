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
        static let bufferPeriod = 60 * 60 * 2 // 2 hours
                
        var movements = [Movement]()
        
        var searchText = ""
        var searchIsPresented = false
        
        var searchResults: [Movement] {
            if searchText.isEmpty {
                return movements
            } else {
                return movements.filter { $0.name.contains(searchText) }
            }
        }
        
        var dateSections: [Date: [Movement]] {
            var sections: [Date: [Movement]] = [:]
            for movement in movements {
                if movement.movementLogs.isEmpty {
                    sections[Date.distantFuture, default: []].append(movement)
                }
                if let mostRecentLogDateBeforeBufferPeriod = movement.mostRecentLogTimestampBeforeBufferPeriod(Self.bufferPeriod)?.removeTimestamp {
                    sections[mostRecentLogDateBeforeBufferPeriod, default: []].append(movement)
                }
            }

            for (date, movements) in sections {
                if date == .distantFuture {
                    sections[date] = movements.sorted(by: {
                        $0.createdAt <= $1.createdAt // old to new
                    })
                }
                else {
                    sections[date] = movements.sorted(by: {
                        $0.mostRecentLogTimestampBeforeBufferPeriod(Self.bufferPeriod) ?? Date.distantFuture <=
                        $1.mostRecentLogTimestampBeforeBufferPeriod(Self.bufferPeriod) ?? Date.distantFuture // old to new
                    })
                }
            }
            return sections
        }
        
        var categorySections: [String: [Movement]] {
            var sections: [String: [Movement]] = [:]
            for movement in movements {
                sections[movement.category, default: []].append(movement)
            }
            return sections
        }
        
        var inProgressMovements: [Movement] {
            var output: [Movement] = []
            for movement in movements {
                if movement.isInProgress(Self.bufferPeriod) {
                    output.append(movement)
                }
            }
            return output.sorted(by: {
                $0.mostRecentLogTimestamp < $1.mostRecentLogTimestamp
            })
        }
       
        var suggestedMovements: [Movement] {
            var output: [Movement] = []
            let inProgressList = inProgressMovements
            var lastLoggedDayBeforeBufferPeriodSet = Set<String>()
            for movement in inProgressList {
                lastLoggedDayBeforeBufferPeriodSet.insert(
                    movement.lastLoggedDayBeforeBufferPeriod(Self.bufferPeriod))
            }
            for lastLoggedDayBeforeBuffer in lastLoggedDayBeforeBufferPeriodSet {
                for movement in movements {
                    if movement.lastLoggedDayBeforeBufferPeriod(Self.bufferPeriod) == lastLoggedDayBeforeBuffer && !inProgressList.contains(movement) {
                        output.append(movement)
                    }
                }
            }
            return output.sorted(by: {
                $0.mostRecentLogTimestampBeforeBufferPeriod(Self.bufferPeriod) ?? Date.distantFuture < $1.mostRecentLogTimestampBeforeBufferPeriod(Self.bufferPeriod) ?? Date.distantFuture
            })
        }

        var isShowingLoginSheet = false
        var isLoggedIn = Keychain.standard.read(
            service: "accessToken", account: "lumberjacked") != nil
        var isLoadingMovements = false
        var hasNotYetAttemptedToLoadMovements = true
        var isLoadingLogout = false
        
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
