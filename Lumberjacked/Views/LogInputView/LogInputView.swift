//
//  LogInputView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/5/24.
//

import SwiftUI

struct LogInputView: View {
    @State var viewModel: ViewModel
    
    @State var showErrorAlert = false
    @State var errorAlertItem = ErrorAlertItem()
    
    var body: some View {
        Form {
            Section {
                TextField("Working Sets", value: $viewModel.movementLog.sets, format: .number)
                TextField("Reps", value: $viewModel.movementLog.reps, format: .number)
                TextField("Load", text: $viewModel.movementLog.load.bound)
            }
            Button {
                Task {
                    viewModel.saveImage = "ellipsis"
                    do {
                        if viewModel.movementLog.id == nil {
                            try await viewModel.saveNewLog()
                        } else {
                            try await viewModel.updateLog()
                        }
                    } catch let error as HttpError {
                        errorAlertItem = ErrorAlertItem(
                            title: error.error, messages: error.messages)
                        showErrorAlert = true
                    }
                    viewModel.saveImage = ""
                    viewModel.container.path.removeLast()
                }
            } label: {
                HStack {
                    Text("Save")
                    Image(systemName: viewModel.saveImage)
                }
            }
        }
        .toolbar {
            if viewModel.movementLog.id != nil {
                Button("Delete", systemImage: "trash") {
                    Task {
                        do {
                            try await viewModel.deleteLog()
                            viewModel.container.path.removeLast()
                        } catch let error as HttpError {
                            errorAlertItem = ErrorAlertItem(
                                title: error.error, messages: error.messages)
                            showErrorAlert = true
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.movementLog.timestamp?.formatted(date: .abbreviated, time:.omitted) ?? "New Log")
        .alert(errorAlertItem, isPresented: $showErrorAlert)
    }
}
