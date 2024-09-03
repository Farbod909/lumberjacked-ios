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
        
        var isShowingLoginSheet = false
        var isLoggedIn = Keychain.standard.read(
            service: "accessToken", account: "lumberjacked") != nil
        var isLoadingMovements = false
        var hasNotYetAttemptedToLoadMovements = true
        var isLoadingLogout = false
        
        /**
         Get all unique values of lastLoggedDay, ordered by most recent.
         */
        func getUniqueLastLoggedDayValues() -> [String] {
            var uniqueLastLoggedDays = Set<String>()
            var orderedLastLoggedDays = Array<String>()
            for movement in movements.sorted(by: {
                $0.mostRecentLogTimestamp >= $1.mostRecentLogTimestamp
            }) {
                if !uniqueLastLoggedDays.contains(movement.lastLoggedDay) {
                    orderedLastLoggedDays.append(movement.lastLoggedDay)
                    uniqueLastLoggedDays.insert(movement.lastLoggedDay)
                }
            }
            return orderedLastLoggedDays
        }
        
        /**
         Get all unique values of lastLoggedDayBeforeBufferPeriod, ordered by most last logged timestamp.
         */
        func getUniqueLastLoggedDayBeforeBufferPeriodValues() -> [String] {
            var uniqueSet = Set<String>()
            var orderedSet = Array<String>()
            for movement in movements.sorted(by: {
                $0.mostRecentLogTimestamp >= $1.mostRecentLogTimestamp
            }) {
                if !uniqueSet.contains(movement.lastLoggedDayBeforeBufferPeriod(Self.bufferPeriod)) {
                    orderedSet.append(movement.lastLoggedDayBeforeBufferPeriod(Self.bufferPeriod))
                    uniqueSet.insert(movement.lastLoggedDayBeforeBufferPeriod(Self.bufferPeriod))
                }
            }
            return orderedSet
        }

        
        /**
         Get all unique categories, ordered by most recent log timestamp.
         */
        func getAllCategories() -> [String] {
            var uniqueCategories = Set<String>()
            var orderedCategories = Array<String>()
            for movement in movements.sorted(by: {
                $0.mostRecentLogTimestamp >= $1.mostRecentLogTimestamp
            }) {
                if !uniqueCategories.contains(movement.category) {
                    orderedCategories.append(movement.category)
                    uniqueCategories.insert(movement.category)
                }
            }
            return orderedCategories
        }

        /**
         Get all movements grouped by last day that they were logged, ordered by most recent log
         timestamp.
         */
        func getMovements(lastLoggedDay: String) -> [Movement] {
            var splitMovements = [Movement]()
            for movement in movements.sorted(by: {
                // order by most recent log timestamp, ascending. If both are equal (i.e. both are
                // not present), then order by creation timestamp, ascending.
                if $0.mostRecentLogTimestamp == $1.mostRecentLogTimestamp {
                    return $0.createdAt <= $1.createdAt
                } else {
                    return $0.mostRecentLogTimestamp < $1.mostRecentLogTimestamp
                }
            }) {
                if movement.lastLoggedDay == lastLoggedDay {
                    splitMovements.append(movement)
                }
            }
            return splitMovements
        }
        
        /**
         Get all movements grouped by last day before today that they were logged, ordered by most recent log
         timestamp.
         */
        func getMovements(lastLoggedDayBeforeBufferPeriod: String) -> [Movement] {
            var splitMovements = [Movement]()
            for movement in movements.sorted(by: {
                // order by most recent log timestamp, ascending. If both are equal (i.e. both are
                // not present), then order by creation timestamp, ascending.
                if $0.mostRecentLogTimestamp == $1.mostRecentLogTimestamp {
                    return $0.createdAt <= $1.createdAt
                } else {
                    return $0.mostRecentLogTimestamp < $1.mostRecentLogTimestamp
                }
            }) {
                if movement.lastLoggedDayBeforeBufferPeriod(Self.bufferPeriod) == lastLoggedDayBeforeBufferPeriod {
                    splitMovements.append(movement)
                }
            }
            return splitMovements
        }

                
        /**
         Get all movements for a given category, ordered by most recent log
         timestamp.
         */
        func getMovements(category: String) -> [Movement] {
            var splitMovements = [Movement]()
            for movement in movements.sorted(by: {
                // order by most recent log timestamp, ascending. If both are equal (i.e. both are
                // not present), then order by creation timestamp, ascending.
                if $0.mostRecentLogTimestamp == $1.mostRecentLogTimestamp {
                    return $0.createdAt <= $1.createdAt
                } else {
                    return $0.mostRecentLogTimestamp < $1.mostRecentLogTimestamp
                }
            }) {
                if movement.category == category {
                    splitMovements.append(movement)
                }
            }
            return splitMovements
        }
        
        func getSectionName(_ lastLoggedDayBeforeBufferPeriod: String) -> String {
            if lastLoggedDayBeforeBufferPeriod.isEmpty {
                return "New"
            }
            var name = lastLoggedDayBeforeBufferPeriod
            for movement in movements {
                if movement.lastLoggedDayBeforeBufferPeriod(Self.bufferPeriod) == lastLoggedDayBeforeBufferPeriod 
                    && movement.mostRecentLogTimestamp.distance(to: Date.now) < TimeInterval(Self.bufferPeriod) {
                    name = "In Progress"
                }
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = TimeZone.current
            if let date = dateFormatter.date(from: lastLoggedDayBeforeBufferPeriod) {
                if Calendar.current.isDateInToday(date) {
                    return "Today"
                }
                if Calendar.current.isDateInYesterday(date) {
                    return "Yesterday"
                }
            }
            return name
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
