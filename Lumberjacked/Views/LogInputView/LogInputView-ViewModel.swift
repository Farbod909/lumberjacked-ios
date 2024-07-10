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
        var saveImage = ""
        
        init(container: ContainerView.ViewModel, movementLog: MovementLog, movement: Movement) {
            self.container = container
            self.movementLog = movementLog
            self.movement = movement
        }
        
        func updateLog() async {
            guard let movementLogId = movementLog.id else {
                print("Cannot update movement log with no id.")
                return
            }
            
            let accessToken = "44b0b258a667b0e93aff0f4f3dcc9d37ab04c94f104cbb5a6f4ad8c043ed53a331b5fd7f7b7795ec37a9a285071ef18c"

            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(accessToken)"
            ]
            let session = URLSession(configuration: sessionConfiguration)

            guard let url = URL(string: "http://localhost:3000/api/v1/movement-logs/\(movementLogId)") else {
                print("Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "PATCH"
                    
            guard let encoded = try? JSONEncoder().encode(movementLog.dto) else {
                print("Failed to encode log")
                return
            }
            
            do {
                let (data, _) = try await session.upload(for: request, from: encoded)
            } catch {
                print("Invalid data")
            }
        }
        
        func saveNewLog() async {
            let accessToken = "44b0b258a667b0e93aff0f4f3dcc9d37ab04c94f104cbb5a6f4ad8c043ed53a331b5fd7f7b7795ec37a9a285071ef18c"

            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(accessToken)"
            ]
            let session = URLSession(configuration: sessionConfiguration)

            guard let url = URL(string: "http://localhost:3000/api/v1/movements/\(movement.id)/logs") else {
                print("Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            guard let encoded = try? JSONEncoder().encode(movementLog.dto) else {
                print("Failed to encode log")
                return
            }
            
            do {
                let (data, _) = try await session.upload(for: request, from: encoded)
            } catch {
                print("Invalid data")
            }
        }
        
        func deleteLog() async {
            guard let movementLogId = movementLog.id else {
                print("Cannot delete movement log with no id.")
                return
            }
            
            let accessToken = "44b0b258a667b0e93aff0f4f3dcc9d37ab04c94f104cbb5a6f4ad8c043ed53a331b5fd7f7b7795ec37a9a285071ef18c"

            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(accessToken)"
            ]
            let session = URLSession(configuration: sessionConfiguration)

            guard let url = URL(string: "http://localhost:3000/api/v1/movement-logs/\(movementLogId)") else {
                print("Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
                            
            do {
                let (data, _) = try await session.data(for: request)
            } catch {
                print("Invalid data")
            }
        }

    }
}
