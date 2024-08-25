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
            TextField("", text: $viewModel.movementLog.notes.bound, prompt: Text("Notes").foregroundStyle(Color.gray))
                .padding()
                .background(Color.init(uiColor: UIColor(red: 73/255, green: 73/255, blue: 73/255, alpha: 1.0)))
                .foregroundColor(Color.white)
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
            }
            .padding(EdgeInsets(top: 27, leading: 20, bottom: 27, trailing: 16))
            .background(Color.init(uiColor: UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1.0)))
            .foregroundStyle(Color.white)
            .disabled(value == minValue)
            
            VStack {
                TextField("", value: $value, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                Text(label)
                    .font(.caption)
                    .textCase(.uppercase)
            }
            .foregroundStyle(Color.white)

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
            }
            .padding(EdgeInsets(top: 22, leading: 16, bottom: 22, trailing: 20))
            .background(Color.init(uiColor: UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1.0)))
            .foregroundStyle(Color.white)
            .disabled(value == maxValue)
        }
        .background(Color.init(uiColor: UIColor(red: 73/255, green: 73/255, blue: 73/255, alpha: 1.0)))
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
            }
            .padding(EdgeInsets(top: 27, leading: 20, bottom: 27, trailing: 16))
            .background(Color.init(uiColor: UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1.0)))
            .foregroundStyle(Color.white)
            .disabled(Double(value) == minValue)
            
            VStack {
                TextField("", text: $value) // no placeholder
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                Text(label)
                    .font(.caption)
                    .textCase(.uppercase)
            }
            .foregroundStyle(Color.white)

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
            }
            .padding(EdgeInsets(top: 22, leading: 16, bottom: 22, trailing: 20))
            .background(Color.init(uiColor: UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1.0)))
            .foregroundStyle(Color.white)
            .disabled(Double(value) == maxValue)
        }
        .background(Color.init(uiColor: UIColor(red: 73/255, green: 73/255, blue: 73/255, alpha: 1.0)))
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
