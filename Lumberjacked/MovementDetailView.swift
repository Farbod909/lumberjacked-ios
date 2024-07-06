//
//  MovementDetailView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/5/24.
//

import SwiftUI


struct MovementDetailView: View {
    @State var movement: Movement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("split")
                    .textCase(.uppercase)
                    .font(.headline)
                Text(movement.split)
                Spacer()
            }
            
            if let description = movement.description {
                Text(description)
            }
            
            if movement.hasAnyRecommendations {
                RecommendationsView(movement: movement)
            }
            
            if (!movement.movementLogs.isEmpty) {
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
                    ScrollView {
                        LazyVStack {
                            ForEach(
                                movement.movementLogs.sorted(
                                    by: { $0.timestamp! > $1.timestamp! }),
                                id: \.self) { log in
                                LogItem(log: log)
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .task {
            if let loadedMovement = await loadMovementDetail(id: movement.id) {
                movement = loadedMovement
            }
        }
        .toolbar {
            Button("Edit movement", systemImage: "pencil.circle") {
                //
            }
            Button("New log", systemImage: "plus.square.fill") {
                //
            }
        }
        .navigationTitle(movement.name)
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
            HStack(spacing: 0) {
                ForEach(recommendations, id: \.self) { recommendation in
                    VStack {
                        Text(recommendation.name)
                            .textCase(.uppercase)
                            .font(.subheadline)
                            .fontWidth(.condensed)
                            .fontWeight(.semibold)
                        Text(recommendation.value)
                    }
                    .padding(8)
                    .background(Color.init(uiColor: .systemGray6))
                    .cornerRadius(5)
                    if (recommendation != recommendations.last) {
                        Spacer(minLength: 1)
                    }
                }
            }
        }
    }
}

struct LogItem: View {
    let log: Movement.MovementLog
    
    var body: some View {
        HStack {
            if let timestamp = log.timestamp {
                Text(timestamp.formatted(date: .abbreviated, time: .omitted))
                    .fontWeight(.semibold)
            }
            Spacer()
            if let sets = log.sets {
                Text("\(sets.formatted())")
                    .frame(width: 40)
            }
            Text(log.reps.formatted())
                .frame(width: 40)
            Text(log.load)
                .frame(width: 60)

        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(Color.init(uiColor: .systemGray6))
        .cornerRadius(5)
        .padding(.bottom, 2)
    }
}


#Preview {
    MovementDetailView(movement: Movement(id: 1, name: "Name", split: "Split", movementLogs: []))
}
