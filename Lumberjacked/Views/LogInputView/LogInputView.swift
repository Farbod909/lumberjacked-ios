//
//  LogInputView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/5/24.
//

import SwiftUI

struct LogInputView: View {
    @State var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
        
    var body: some View {
        Form {
            Section {
                TextField("Working Sets", value: $viewModel.movementLog.sets, format: .number)
                TextField("Reps", value: $viewModel.movementLog.reps, format: .number)
                TextField("Load", text: $viewModel.movementLog.load.bound)
            }
        }
        .toolbar {
            if viewModel.toolbarActionLoading {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        if viewModel.movementLog.id == nil {
                            guard await viewModel.attemptSaveNewLog() else {
                                return
                            }
                        } else {
                            guard await viewModel.attemptUpdateLog() else {
                                return
                            }
                        }
                        dismiss()
                    }
                }
                .disabled(!viewModel.movementLog.isFullyPopulated)
            }
            if viewModel.movementLog.id != nil {
                ToolbarItem(placement: .secondaryAction) {
                    Button("Delete log", systemImage: "trash") {
                        Task {
                            guard await viewModel.attemptDeleteLog() else {
                                return
                            }
                            dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.movementLog.timestamp?.formatted(date: .abbreviated, time:.omitted) ?? "New Log")
        .alert(viewModel.errorAlertItem, isPresented: $viewModel.showErrorAlert)
    }
}
