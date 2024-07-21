//
//  HomeView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/4/24.
//

import SwiftUI

struct HomeView: View {
    @State var viewModel: ViewModel
        
    var body: some View {
        ZStack {
            if viewModel.isLoadingMovements {
                ProgressView()
            } else {
                if viewModel.movements.isEmpty {
                    VStack {
                        NewMovementLink(container: viewModel.container)
                    }
                } else {
                    List {
                        ForEach(viewModel.getAllSplits(), id: \.self) { split in
                            Section() {
                                ForEach(viewModel.getMovements(for: split)) { movement in
                                    HStack {
                                        Text(movement.name)
                                        Spacer()
                                        if (!movement.movementLogs.isEmpty) {
                                            if let reps = movement.movementLogs[0].reps {
                                                Text(reps.formatted()).frame(minWidth: 36)
                                            }
                                            Divider()
                                            if let load = movement.movementLogs[0].load {
                                                Text(load).frame(minWidth: 36)
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
                                        Text("+")
                                        Text("Load").padding(.trailing, 22)
                                    }
                                    .fontWidth(.condensed)
                                }
                            }
                        }
                    }
                    .navigationDestination(for: Movement.self) { selection in
                        MovementDetailView(
                            viewModel: MovementDetailView.ViewModel(
                                container: viewModel.container,
                                movement: selection))
                    }
                }
            }
        }
        .task(id: viewModel.isLoggedIn) {
            if viewModel.isLoggedIn {
                try? await viewModel.loadAllMovements()
                viewModel.isLoadingMovements = false
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NewMovementLink(container: viewModel.container)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    Task {
                        await viewModel.attemptLogout()
                    }
                } label: {
                    Text("Log out")
                }
            }
        }
        .sheet(
            isPresented: $viewModel.isShowingLoginSheet,
            onDismiss: {
                viewModel.isLoggedIn = true
            }, content: {
                LoginSignupView(viewModel: LoginSignupView.ViewModel())
            })
        .onAppear() {
            viewModel.showLoginPageIfNotLoggedIn()
        }
        .alert(viewModel.errorAlertItem, isPresented: $viewModel.showErrorAlert)
    }
}

struct NewMovementLink: View {
    var container: ContainerView.ViewModel
    
    var body: some View {
        NavigationLink() {
            MovementInputView(
                viewModel: MovementInputView.ViewModel(
                    container: container,
                    movement: Movement.empty()))
        } label: {
            Label("New movement", systemImage: "plus")
        }
    }
}
