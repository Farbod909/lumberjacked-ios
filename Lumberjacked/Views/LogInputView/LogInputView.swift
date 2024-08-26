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
        VStack {
            CustomIntStepper(label: "Sets", value: $viewModel.movementLog.sets, minValue: 0, maxValue: 100)
            CustomIntStepper(label: "Reps", value: $viewModel.movementLog.reps, minValue: 0, maxValue: 100)
            CustomDoubleStepper(label: "Load", value: $viewModel.movementLog.load.bound, minValue: -1000, maxValue: 1000, increment: 2.5)
            TextField("",
                      text: $viewModel.movementLog.notes.bound,
                      prompt: Text("Notes").foregroundStyle(Color.secondary))
                .padding()
                .background(Color.init(.systemGray6))
                .foregroundColor(Color.primary)
                .clipShape(
                    RoundedRectangle(cornerRadius: 100)
                )
            Spacer()
        }
        .padding()
        .toolbar {
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
    }
}

struct CustomIntStepper : View {
    var label: String
    @Binding var value: Int?
    var minValue: Int
    var maxValue: Int
    
    var body: some View {
        HStack {
            Button {
                if value != nil {
                    if value! > minValue {
                        value = value! - 1
                    } else {
                        value = 0
                    }
                }
            } label: {
                Image(systemName: "minus")
                    .padding()
            }
            .disabled(value == minValue)
            
            VStack {
                TextField("", value: $value, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                Text(label)
                    .font(.caption)
                    .textCase(.uppercase)
            }

            Button {
                if value != nil {
                    if value! < maxValue {
                        value = value! + 1
                    }
                } else {
                    value = 0
                }
            } label: {
                Image(systemName: "plus")
                    .padding()
            }
            .disabled(value == maxValue)
        }
        .padding(2)
        .background(Color.init(.systemGray6))
        .foregroundStyle(Color.primary)
        .font(.title2)
        .clipShape(
            RoundedRectangle(cornerRadius: 100)
        )
    }
}

struct CustomDoubleStepper : View {
    var label: String
    @Binding var value: String
    var minValue: Double
    var maxValue: Double
    var increment: Double
    
    var body: some View {
        HStack {
            Button {
                if let valueAsDouble = Double(value) {
                    if valueAsDouble > minValue {
                        value = String(valueAsDouble - increment)
                    } else {
                        value = "0"
                    }
                }
            } label: {
                Image(systemName: "minus")
                    .padding()
            }
            .disabled(Double(value) == minValue)
            
            VStack {
                TextField("", text: $value) // no placeholder
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                Text(label)
                    .font(.caption)
                    .textCase(.uppercase)
            }

            Button {
                if let valueAsDouble = Double(value) {
                    if valueAsDouble < maxValue {
                        value = String(valueAsDouble + increment)
                    } else {
                        value = "0"
                    }
                }
            } label: {
                Image(systemName: "plus")
                    .padding()
            }
            .disabled(Double(value) == maxValue)
        }
        .padding(2)
        .background(Color.init(.systemGray6))
        .foregroundStyle(Color.primary)
        .font(.title2)
        .clipShape(
            RoundedRectangle(cornerRadius: 100)
        )
    }
}


#Preview {
    NavigationStack {
        LogInputView(
            viewModel: LogInputView.ViewModel(
                container: ContainerView.ViewModel(),
                movementLog: MovementLog(sets: 3, reps: 12, load: "73.5"),
                movement: Movement(id: 1, name: "Name", category: "Category", createdAt: Date.now, movementLogs: [])))
    }
}
