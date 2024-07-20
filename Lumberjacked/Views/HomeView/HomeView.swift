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
    @State var isLoggedIn = Keychain.standard.read(service: "accessToken", account: "lumberjacked") != nil
    
    @State var showErrorAlert = false
    @State var errorAlertItem = ErrorAlertItem()
    
    @State var isLoading = true
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
            } else {
                if viewModel.movements.isEmpty {
                    VStack {
                        NavigationLink() {
                            MovementInputView(
                                viewModel: MovementInputView.ViewModel(
                                    container: viewModel.container,
                                    movement: Movement.empty()))
                        } label: {
                            Label("New movement", systemImage: "plus")
                        }
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
                    .navigationDestination(for: Movement.self) { selection in
                        MovementDetailView(
                            viewModel: MovementDetailView.ViewModel(
                                container: viewModel.container,
                                movement: selection))
                    }
                }
            }
        }
        .task(id: isLoggedIn) {
            if isLoggedIn {
                isLoading = true
                try? await viewModel.loadAllMovements()
                isLoading = false
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink() {
                    MovementInputView(
                        viewModel: MovementInputView.ViewModel(
                            container: viewModel.container,
                            movement: Movement.empty()))
                } label: {
                    Label("New movement", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    Task {
                        do {
                            try await viewModel.logout()
                            isLoggedIn = false
                            isShowingLoginSheet = true
                        } catch let error as HttpError {
                            errorAlertItem = ErrorAlertItem(
                                title: error.error, messages: error.messages)
                            showErrorAlert = true
                        }
                    }
                } label: {
                    Text("Logout")
                }
            }
        }
        .sheet(
            isPresented: $isShowingLoginSheet,
            onDismiss: {
                Task {
                    isLoggedIn = true
                }
            }, content: {
                LoginSignupView(viewModel: LoginSignupView.ViewModel())
            })
        .onAppear() {
            if Keychain.standard.read(service: "accessToken", account: "lumberjacked") == nil {
                isLoggedIn = false
                isShowingLoginSheet = true
            }
        }
        .alert(errorAlertItem, isPresented: $showErrorAlert)
    }
}
