//
//  LogInputView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/5/24.
//

import SwiftUI

struct LogInputView: View {
    @State var viewModel: ViewModel
    
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
                    if viewModel.movementLog.id == nil {
                        await viewModel.saveNewLog()
                    } else {
                        await viewModel.updateLog()
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
                        await viewModel.deleteLog()
                        viewModel.container.path.removeLast()
                    }
                }
            }
        }
        .navigationTitle(viewModel.movementLog.timestamp?.formatted(date: .abbreviated, time:.omitted) ?? "New Log")
    }
}
