//
//  HomeView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/4/24.
//

import SwiftUI

struct HomeView: View {
    @State var viewModel: ViewModel
    
    @AppStorage("homeSelectedViewMode") var selectedViewMode = "Minimal"
    @AppStorage("homeSelectedGroupBy") var selectedGroupBy = "Date"
    let possibleViewModes = ["Minimal", "Compact", "Full"]
    let possibeGroupings = ["Date", "Category"]

    var body: some View {
        ZStack {
            if viewModel.movements.isEmpty {
                if viewModel.hasNotYetAttemptedToLoadMovements {
                    // display nothing
                } else if viewModel.isLoadingMovements {
                    ProgressView()
                } else {
                    NewMovementLink(viewModel: viewModel)
                }
            } else {
                MovementsListView(
                    viewModel: viewModel,
                    selectedViewMode: selectedViewMode,
                    selectedGroupBy: selectedGroupBy)
            }
        }
        .task(id: viewModel.isLoggedIn) {
            viewModel.hasNotYetAttemptedToLoadMovements = true
            await viewModel.attemptLoadAllMovements()
        }
        .toolbar {
            ToolbarItemGroup(placement: .secondaryAction) {
                Picker("View Mode",
                       systemImage: "list.bullet",
                       selection: $selectedViewMode) {
                    ForEach(possibleViewModes, id: \.self) {
                        Text($0)
                    }
                }
                Picker("Group By",
                       systemImage: "rectangle.3.group",
                       selection: $selectedGroupBy) {
                    ForEach(possibeGroupings, id: \.self) {
                        Text($0)
                    }
                }
                if !viewModel.isLoadingLogout {
                    Button {
                        Task {
                            await viewModel.attemptLogout()
                        }
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } else {
                    ProgressView()
                }

            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                if viewModel.isLoadingLogout {
                    ProgressView()
                }
                NewMovementLink(viewModel: viewModel)
            }
        }
        .sheet(
            isPresented: $viewModel.isShowingLoginSheet,
            onDismiss: {
                viewModel.isLoggedIn = true
                viewModel.isLoadingMovements = true
            }, content: {
                LoginSignupView(
                    viewModel: LoginSignupView.ViewModel(
                        container: viewModel.container))
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
    var selectedViewMode: String
    var selectedGroupBy: String
    
    var body: some View {
        if selectedGroupBy == "Date" {
            List {
                ForEach(viewModel.getUniqueLastLoggedDayBeforeBufferPeriodValues(), id: \.self)
                { lastLoggedDayBeforeBufferPeriod in
                    Section {
                        ForEach(viewModel.getMovements(
                            lastLoggedDayBeforeBufferPeriod: lastLoggedDayBeforeBufferPeriod))
                        { movement in
                            MovementsRowView(
                                movement: movement,
                                selectedViewMode: selectedViewMode)
                        }
                    } header: {
                        MovementsListHeaderView(
                            headerTitle: viewModel.getSectionName(lastLoggedDayBeforeBufferPeriod))
                    }
                }
                
            }
        }
        else if selectedGroupBy == "Category" {
            List {
                ForEach(viewModel.getAllCategories(), id: \.self) { category in
                    Section() {
                        ForEach(viewModel.getMovements(category: category)) { movement in
                            MovementsRowView(movement: movement, selectedViewMode: selectedViewMode)
                        }
                    } header: {
                        MovementsListHeaderView(headerTitle: category)
                    }
                }
            }
        }
        else {
            Text("Cannot group by \(selectedGroupBy).")
        }
    }
}

struct MovementsRowView: View {
    var movement: Movement
    var selectedViewMode: String
    
    var body: some View {
        HStack {
            if selectedViewMode == "Full" {
                MovementsRowFull(movement: movement)
            }
            else if selectedViewMode == "Compact" {
                MovementsRowCompact(movement: movement)
            } else if selectedViewMode == "Minimal" {
                MovementsRowMinimal(movement: movement)
            } else {
                MovementsRowMinimal(movement: movement)
            }
            Spacer()
            NavigationLink(value: movement) { }
                .frame(maxWidth: 6)
        }
    }
}

struct MovementsRowFull: View {
    var movement: Movement

    var body: some View {
        VStack {
            HStack {
                Text(movement.name)
                Spacer()
                Text(movement.category)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .textCase(.uppercase)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
            
            HStack {
                Text("Latest Load")
                    .font(.caption)
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .fontWidth(.condensed)
                Text(movement.latestLoad)
                    .font(.caption)
                    .fontWeight(.thin)

                Spacer()
                
                Text("Latest Reps")
                    .font(.caption)
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .fontWidth(.condensed)
                Text(movement.latestReps)
                    .font(.caption)
                    .fontWeight(.thin)

                Spacer()
                
                Text("Rep Range")
                    .font(.caption)
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .fontWidth(.condensed)
                Text(movement.repRange ?? "N/A")
                    .font(.caption)
                    .fontWeight(.thin)
            }
        }
    }
}

struct MovementsRowCompact: View {
    var movement: Movement

    var body: some View {
        HStack {
            Text(movement.name)
            Spacer()
            Text("\(movement.latestLoad) × \(movement.latestReps)")
                .font(.caption)
                .fontWeight(.bold)
            Text("(\(movement.repRange ?? "N/A"))")
                .font(.caption)
        }
    }
}

struct MovementsRowMinimal: View {
    var movement: Movement

    var body: some View {
        Text(movement.name)
    }
}


struct MovementsListHeaderView: View {
    var headerTitle: String
    
    var body: some View {
        Text(headerTitle)
            .font(.title)
            .textCase(nil)
            .bold()
            .padding(.bottom, 2)
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
