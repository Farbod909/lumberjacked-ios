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
        NavigationStack {
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
                if let loadedMovements = await loadMovements() {
                    movements = loadedMovements
                }
            }
            .toolbar {
                Button("New Movement", systemImage: "plus") {
                    //
                }
            }
            .navigationDestination(for: Movement.self) { selection in
                Text(selection.name)
            }
        }
    }
}

#Preview {
    ContentView()
}
