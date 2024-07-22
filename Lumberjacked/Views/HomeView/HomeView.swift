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
                if viewModel.movements.isEmpty {
                    ProgressView()
                }
            } else {
                if viewModel.movements.isEmpty {
                    NewMovementLink(viewModel: viewModel)
                } else {
                    MovementsListView(viewModel: viewModel)
                }
            }
        }
        .task(id: viewModel.isLoggedIn) {
            await viewModel.attemptLoadAllMovements()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NewMovementLink(viewModel: viewModel)
            }
            ToolbarItem(placement: .topBarLeading) {
                if (!viewModel.isLoadingLogout) {
                    Button {
                        Task {
                            await viewModel.attemptLogout()
                        }
                    } label: {
                        Text("Log out")
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .sheet(
            isPresented: $viewModel.isShowingLoginSheet,
            onDismiss: {
                viewModel.isLoggedIn = true
                viewModel.isLoadingMovements = true
            }, content: {
                LoginSignupView(viewModel: LoginSignupView.ViewModel(container: viewModel.container))
            })
        .onAppear() {
            viewModel.showLoginPageIfNotLoggedIn()
        }
        .navigationDestination(for: Movement.self) { selection in
            MovementDetailView(
                viewModel: MovementDetailView.ViewModel(
                    container: viewModel.container,
                    movement: selection))
        }
    }
}

struct MovementsListView: View {
    var viewModel: HomeView.ViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.getAllSplits(), id: \.self) { split in
                Section() {
                    ForEach(viewModel.getMovements(for: split)) { movement in
                        MovementsRowView(movement: movement)
                    }
                } header: {
                    MovementsSplitHeaderView(split: split)
                }
            }
        }
    }
}

struct MovementsRowView: View {
    var movement: Movement
    
    var body: some View {
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
}

struct MovementsSplitHeaderView: View {
    var split: String
    
    var body: some View {
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

struct NewMovementLink: View {
    var viewModel: HomeView.ViewModel

    var body: some View {
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
