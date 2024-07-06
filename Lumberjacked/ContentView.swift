//
//  ContentView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/4/24.
//

import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()
    @State private var movements = [Movement]()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(groupMovementsBySplit(movements), id: \.self) { split in
                    Section() {
                        ForEach(getMovementsForSplit(movements, split: split)) { movement in
                            HStack {
                                Text(movement.name)
                                Spacer()
                                if (!movement.movementLogs.isEmpty) {
                                    if let reps = movement.movementLogs[0].reps {
                                        Text(reps.formatted()).frame(minWidth: 28)
                                    }
                                    Divider()
                                    if let load = movement.movementLogs[0].load {
                                        Text(load).frame(minWidth: 28)
                                    }
                                }
                                NavigationLink(value: movement) { }
                                    .frame(maxWidth: 6)
                            }
                        }
                    } header: {
                        VStack(alignment: .leading) {
                            Text(split)
                                .font(.title)
                                .textCase(nil)
                                .bold()
                                .padding(.bottom, 2)
                            HStack {
                                Text("Name")
                                Spacer()
                                Text("Most recent")
                                Text("Reps")
                                Text("|")
                                Text("Load").padding(.trailing, 14)
                            }
                            .fontWidth(.condensed)
                        }
                    }
                }
            }
            .task {
                if let loadedMovements = await loadAllMovements() {
                    movements = loadedMovements
                }
            }
            .toolbar {
                Button("New Movement", systemImage: "plus") {
                    //
                }
            }
            .navigationDestination(for: Movement.self) { selection in
                MovementDetailView(path: $path, movement: selection)
            }
        }
    }
}

#Preview {
    ContentView()
}
