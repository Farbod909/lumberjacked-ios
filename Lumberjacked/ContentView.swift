//
//  ContentView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/4/24.
//

import SwiftUI

struct ContentView: View {
    @State private var movements = [Movement]()
    
    var body: some View {
        List {
            ForEach(groupMovementsBySplit(movements), id: \.self) { split in
                Section() {
                    ForEach(getMovementsForSplit(movements, split: split)) { movement in
                        HStack {
                            Text(movement.name)
                            Spacer()
                            if (!movement.movementLogs.isEmpty) {
                                Text(movement.movementLogs[0].reps.formatted()).frame(minWidth: 28)
                                Divider()
                                Text(movement.movementLogs[0].load).frame(minWidth: 28)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text(split)
                        Spacer()
                        Text("Most recent")
                        Text("Reps")
                        Text("Load")
                    }
                }
            }
        }
        .task {
            if let loadedMovements = await loadMovements() {
                movements = loadedMovements
            }
        }
    }
    }

#Preview {
    ContentView()
}
