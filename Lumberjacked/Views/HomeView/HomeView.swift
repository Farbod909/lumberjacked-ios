//
//  HomeView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/4/24.
//

import SwiftUI

struct HomeView: View {
    @State var viewModel: ViewModel
    @State var isShowingLoginSheet = false
    
    var body: some View {
        List {
            ForEach(viewModel.getAllSplits(), id: \.self) { split in
                Section() {
                    ForEach(viewModel.getMovements(for: split)) { movement in
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
            await viewModel.loadAllMovements()
        }
        .toolbar {
            HStack {
                if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
                    Button {
                        Task {
                            await viewModel.logout()
                        }
                    } label: {
                        Text("Logout")
                    }
                } else{
                    Button {
                        UserDefaults.standard.removeObject(forKey: "accessToken")
                        isShowingLoginSheet = true
                    } label: {
                        Text("Login")
                    }
                }
                NavigationLink() {
                    MovementInputView(
                        viewModel: MovementInputView.ViewModel(
                            container: viewModel.container,
                            movement: Movement.empty()))
                } label: {
                    Label("New movement", systemImage: "plus")
                }
            }
        }
        .navigationDestination(for: Movement.self) { selection in
            MovementDetailView(
                viewModel: MovementDetailView.ViewModel(
                    container: viewModel.container,
                    movement: selection))
        }
        .sheet(isPresented: $isShowingLoginSheet) {
            LoginSheetView(viewModel: LoginSheetView.ViewModel())
        }
    }
}
