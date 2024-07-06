//
//  LogInputView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/5/24.
//

import SwiftUI

struct LogInputView: View {
    @Binding var path: NavigationPath
    
    var movement: Movement
    @State var movementLog: Movement.MovementLog
    @State var saveImage = ""
    
    var body: some View {
        Form {
            Section {
                TextField("Working Sets", value: $movementLog.sets, format: .number)
                TextField("Reps", value: $movementLog.reps, format: .number)
                TextField("Load", text: $movementLog.load.bound)
            }
            Button {
                Task {
                    saveImage = "ellipsis"
                    if movementLog.id == nil {
                        await saveNewLog()
                    } else {
                        await updateLog()
                    }
                    saveImage = ""
                    path.removeLast()
                }
            } label: {
                HStack {
                    Text("Save")
                    Image(systemName: saveImage)
                }
            }
        }
        .toolbar {
            if movementLog.id != nil {
                Button("Delete", systemImage: "trash") {
                    Task {
                        await deleteLog()
                        path.removeLast()
                    }
                }
            }
        }
        .navigationTitle(movementLog.timestamp?.formatted(date: .abbreviated, time:.omitted) ?? "New Log")
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

//#Preview {
//    LogInputView(movementName: "Example movement", workingSets: 3, reps: 12, load: 97.5)
//}
