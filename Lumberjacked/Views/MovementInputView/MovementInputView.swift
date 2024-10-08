//
//  MovementInputView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/14/24.
//

import SwiftUI

struct MovementInputView: View {
    @State var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section {
                MovementInputTextFieldView(
                    placeholderText: "Movement name",
                    stickyText: "Name",
                    text: $viewModel.movement.name)
                MovementInputTextFieldView(
                    placeholderText: "Category",
                    stickyText: "Category",
                    text: $viewModel.movement.category)
                MovementInputTextFieldView(
                    placeholderText: "Notes",
                    stickyText: "Notes",
                    text: $viewModel.movement.notes.bound)
            }
            Section("Recommendations (Optional)") {
                MovementInputTextFieldView(
                    placeholderText: "Warmup sets",
                    stickyText: "Warmup sets",
                    text: $viewModel.movement.warmupSets.bound)
                MovementInputTextFieldView(
                    placeholderText: "Working sets",
                    stickyText: "Working sets",
                    text: $viewModel.movement.workingSets.bound)
                MovementInputTextFieldView(
                    placeholderText: "Rep range",
                    stickyText: "Rep range",
                    text: $viewModel.movement.repRange.bound)
                MovementInputTextFieldView(
                    placeholderText: "RPE",
                    stickyText: "RPE",
                    text: $viewModel.movement.rpe.bound)
                MovementInputIntFieldView(
                    placeholderText: "Rest time (in seconds)",
                    stickyText: "Rest seconds",
                    value: $viewModel.movement.restTime)
            }
        }
        .listRowSpacing(10)
        .navigationTitle(viewModel.movement.id == 0 ? 
                         "New Movement" : viewModel.movement.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        if viewModel.movement.id == 0 {
                            guard await viewModel.attemptSaveNewMovement() else {
                                return
                            }
                        } else {
                            guard await viewModel.attemptUpdateMovement() else {
                                return
                            }
                        }
                        dismiss()
                    }
                } label: {
                    if viewModel.saveActionLoading {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
            }
        }
        .onDisappear() {
            viewModel.movement = Movement.empty()
        }
    }
}

struct MovementInputTextFieldView: View {
    var placeholderText: String
    var stickyText: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField(placeholderText, text: $text, axis: .vertical)
                .textFieldStyle(.plain)
            if !text.isEmpty {
                Text(stickyText)
                    .textCase(.uppercase)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .animation(.default, value: text)
    }
}

struct MovementInputIntFieldView: View {
    var placeholderText: String
    var stickyText: String
    @Binding var value: Int?
    
    var body: some View {
        HStack {
            TextField(placeholderText, value: $value, format: .number)
                .textFieldStyle(.plain)
            if value != nil {
                Text(stickyText)
                    .textCase(.uppercase)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .animation(.default, value: value)
    }
}


#Preview {
    MovementInputView(
        viewModel: MovementInputView.ViewModel(
            container: ContainerView.ViewModel(),
            movement: Movement.empty()))
}
