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
    
    @FocusState private var setsFieldFocused: Bool
    @FocusState private var repsFieldFocused: Bool
    @FocusState private var loadFieldFocused: Bool

    var body: some View {
        Form {
            Section {
                TextField("Working Sets", value: $viewModel.movementLog.sets, format: .number)
                    .keyboardType(.numberPad)
                    .focused($setsFieldFocused)
                TextField("Reps", value: $viewModel.movementLog.reps, format: .number)
                    .keyboardType(.numberPad)
                    .focused($repsFieldFocused)
                TextField("Load", text: $viewModel.movementLog.load.bound)
                    .keyboardType(.decimalPad)
                    .focused($loadFieldFocused)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                if loadFieldFocused {
                    Button("Done") {
                        loadFieldFocused = false
                    }
                } else {
                    Button("Next") {
                        if setsFieldFocused {
                            repsFieldFocused = true
                        }
                        if repsFieldFocused {
                            loadFieldFocused = true
                        }
                    }
                }
            }
            if viewModel.toolbarActionLoading {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        guard await viewModel.formSubmit() else {
                            return
                        }
                        dismiss()
                    }
                }
                .disabled(!viewModel.movementLog.requiredFieldsFullyPopulated)
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
        .navigationTitle(
            viewModel.movementLog.timestamp?.formatted(
                date: .abbreviated,
                time: .omitted) ??
            "New Log"
        )
        .onAppear() {
            setsFieldFocused = true
        }
    }
}
