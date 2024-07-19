//
//  MovementInputView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/14/24.
//

import SwiftUI

struct MovementInputView: View {
    @State var viewModel: ViewModel
    @State var saveImage = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section {
                MovementInputTextFieldView(
                    placeholderText: "Movement name",
                    stickyText: "Name",
                    text: $viewModel.movement.name)
                MovementInputTextFieldView(
                    placeholderText: "Split",
                    stickyText: "Split",
                    text: $viewModel.movement.split)
                MovementInputTextFieldView(
                    placeholderText: "Description",
                    stickyText: "Description",
                    text: $viewModel.movement.description.bound)
            }
            Section("Recommendations") {
                MovementInputTextFieldView(
                    placeholderText: "Warmup sets",
                    stickyText: "Warmup sets",
                    text: $viewModel.movement.warmupSets.bound)
                MovementInputTextFieldView(
                    placeholderText: "Working sets",
                    stickyText: "Working sets",
                    text: $viewModel.movement.workingSets.bound)
                MovementInputTextFieldView(
                    placeholderText: "RPE",
                    stickyText: "RPE",
                    text: $viewModel.movement.rpe.bound)
                MovementInputIntFieldView(
                    placeholderText: "Rest time (in seconds)",
                    stickyText: "Rest seconds",
                    value: $viewModel.movement.restTime)
            }
            Button {
                Task {
                    saveImage = "ellipsis"
                    if viewModel.movement.id == 0 {
                        await viewModel.saveNewMovement()
                    } else {
                        await viewModel.updateMovement()
                    }
                    saveImage = ""
                    dismiss()
                }
            } label: {
                HStack {
                    Text("Save")
                    Image(systemName: saveImage)
                }
            }
        }
        .listRowSpacing(10)
        .navigationTitle(viewModel.movement.id == 0 ? 
                         "New Movement" : viewModel.movement.name)
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
    MovementInputView(viewModel: MovementInputView.ViewModel(container: ContainerView.ViewModel(), movement: Movement.empty()))
}
