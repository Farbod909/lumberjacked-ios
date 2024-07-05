//
//  MovementDetailView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/5/24.
//

import SwiftUI

struct MovementDetailView: View {
    var movement: Movement
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("split")
                    .textCase(.uppercase)
                    .font(.headline)
                Text(movement.split)
                Spacer()
            }
            
            // Description
            
            // if has recommendations, display them
            
            // display logs
            
            Spacer()
        }
        .padding(20)
        .toolbar {
            Button("Edit movement", systemImage: "pencil.circle") {
                //
            }
            Button("New log", systemImage: "plus.square.fill") {
                //
            }
        }
        .navigationTitle(movement.name)
    }
}

#Preview {
    MovementDetailView(movement: Movement(id: 1, name: "Name", split: "Upper", movementLogs: []))
}
