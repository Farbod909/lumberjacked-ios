//
//  MovementDetailView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/5/24.
//

import SwiftUI

struct MovementDetailView: View {
    @State var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("category")
                            .textCase(.uppercase)
                            .font(.headline)
                        Text(viewModel.movement.category)
                            .foregroundColor(.alternate)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 10 , trailing: 0))
                    .overlay(Divider().background(.alternate), alignment: .bottom)
                    
                    if let notes = viewModel.movement.notes {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Notes")
                                    .textCase(.uppercase)
                                    .font(.headline)
                                Text(notes)
                                    .foregroundColor(.alternate)
                            }
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 4, leading: 0, bottom: 10 , trailing: 0))
                        .overlay(Divider().background(.alternate), alignment: .bottom)
                    }
                    
                    if viewModel.movement.hasAnyRecommendations {
                        HStack {
                            RecommendationsView(movement: viewModel.movement)
                            Spacer()
                        }
                            .padding(EdgeInsets(top: 4, leading: 0, bottom: 10 , trailing: 0))
                            .overlay(Divider().background(.alternate), alignment: .bottom)
                    }
                }
                
                if !viewModel.movement.movementLogs.isEmpty {
                    LogListView(movement: viewModel.movement)
                } else {
                    Spacer()
                    NewMovementLogLink(movement: viewModel.movement)
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationTitle(viewModel.movement.name)
        .task {
            await viewModel.attemptLoadMovementDetail(id: viewModel.movement.id)
        }
        .toolbar {
            if viewModel.deleteActionLoading {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                NewMovementLogLink(movement: viewModel.movement)
            }
            ToolbarItemGroup(placement: .secondaryAction) {
                NavigationLink() {
                    MovementInputView(
                        viewModel: MovementInputView.ViewModel(
                            container: viewModel.container, movement: viewModel.movement))
                } label: {
                    Label("Edit movement", systemImage: "pencil.circle")
                }
                Button {
                    viewModel.showDeleteConfirmationAlert = true
                } label: {
                    Label("Delete movement", systemImage: "trash")
                }
            }
        }
        .navigationDestination(for: MovementAndLog.self) { selection in
            LogInputView(
                viewModel: LogInputView.ViewModel(
                    container: viewModel.container,
                    movementLog: selection.log,
                    movement: selection.movement))
        }
        .alert("Delete", isPresented: $viewModel.showDeleteConfirmationAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    guard await viewModel.attemptDeleteMovement(id: viewModel.movement.id) else {
                        return
                    }
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .padding(.horizontal, 16)
    }
}

struct RecommendationsView: View {
    let movement: Movement
    
    struct Recommendation: Hashable, Equatable {
        let name: String
        let value: String
    }
    
    var recommendations: [Recommendation] {
        var result = [Recommendation]()
        if let warmupSets = movement.warmupSets {
            result.append(Recommendation(name: "Warmup Sets", value: warmupSets))
        }
        if let workingSets = movement.workingSets {
            result.append(Recommendation(name: "Working Sets", value: workingSets))
        }
        if let repRange = movement.repRange {
            result.append(Recommendation(name: "Rep Range", value: repRange))
        }
        if let rpe = movement.rpe {
            result.append(Recommendation(name: "RPE", value: rpe))
        }
        if let restTime = movement.restTime {
            let minutes: Int = restTime / 60
            let seconds: Int = restTime % 60
            var value = ""
            if minutes > 0 {
                value.append("\(minutes)m")
            }
            if seconds > 0 {
                value.append("\(seconds)s")
            }
            result.append(Recommendation(name: "Rest", value: value))
        }
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recommendations")
                .textCase(.uppercase)
                .font(.headline)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(recommendations, id: \.self) { recommendation in
                    HStack {
                        Text(recommendation.name)
                            .textCase(.uppercase)
                            .font(.subheadline)
                            .fontWidth(.condensed)
                            .fontWeight(.semibold)
                        Text(recommendation.value)
                    }
                    .padding(0)
                }
            }
            .foregroundColor(.alternate)
        }
    }
}

struct LogListView: View {
    var movement: Movement
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Logs")
                    .textCase(.uppercase)
                    .font(.headline)
                Spacer()
                Text("Sets")
                    .textCase(.uppercase)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(width: 40)
                Text("Reps")
                    .textCase(.uppercase)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(width: 40)
                Text("Load")
                    .textCase(.uppercase)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(width: 60)
                    .padding(.trailing, 8)
            }
            LazyVStack {
                ForEach(
                    movement.movementLogs.sorted(
                        by: { $0.timestamp! > $1.timestamp! }
                    ),
                    id: \.self
                ) { log in
                    LogItem(movement: movement, log: log)
                }
            }
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
    }
}

struct LogItem: View {
    let movement: Movement
    let log: MovementLog
    
    var body: some View {
        NavigationLink(value: MovementAndLog(movement: movement, log: log)) {
            HStack {
                if let timestamp = log.timestamp {
                    Text(timestamp.formatted(date: .abbreviated, time: .omitted))
                        .fontWeight(.semibold)
                }
                Spacer()
                if let sets = log.sets {
                    Text(sets.formatted())
                        .frame(width: 40)
                }
                if let reps = log.reps {
                    Text(reps.formatted())
                        .frame(width: 40)
                }
                if let load = log.load {
                    Text(load)
                        .frame(width: 60)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .background(Color.init(uiColor: .systemGray6))
            .foregroundColor(.primary)
            .cornerRadius(5)
            .padding(.bottom, 2)
        }
    }
}

struct NewMovementLogLink: View {
    var movement: Movement
    
    var body: some View {
        NavigationLink(
            value: MovementAndLog(
                movement: movement,
                log: movement.movementLogs.sorted(by: {
                    $0.timestamp ?? .distantPast < $1.timestamp ?? .distantPast
                }).last?.withJustInputFields ?? MovementLog(sets: 0, reps: 0, load: "0")))
        {
            Label("New log", systemImage: "plus.square.fill")
        }

    }
}

#Preview {
    NavigationStack {
        MovementDetailView(
            viewModel: MovementDetailView.ViewModel(
                container: ContainerView.ViewModel(),
                movement: Movement(
                    id: 1,
                    name: "Name",
                    category: "Category",
                    notes: "Example notes.",
                    createdAt: Date.now,
                    warmupSets: "1-2",
                    workingSets: "2",
                    repRange: "12-15",
                    rpe: "9-10",
                    restTime: 140,
                    movementLogs: [
                        MovementLog(sets: 3, reps: 12, load: "73.5", timestamp: Date.now),
                        MovementLog(sets: 3, reps: 12, load: "73.5", timestamp: Date.now),
                        MovementLog(sets: 3, reps: 12, load: "73.5", timestamp: Date.now),
                        MovementLog(sets: 3, reps: 12, load: "73.5", timestamp: Date.now),
                    ])))
    }
}
