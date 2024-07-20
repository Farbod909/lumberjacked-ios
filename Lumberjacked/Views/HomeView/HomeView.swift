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
        .task(id: isLoggedIn) {
            await viewModel.loadAllMovements()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink() {
                    MovementInputView(
                        viewModel: MovementInputView.ViewModel(
                            container: viewModel.container,
                            movement: Movement.empty()))
                } label: {
                    Label("New movement", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await viewModel.logout()
                        isLoggedIn = false
                        isShowingLoginSheet = true
                    }
                } label: {
                    Text("Logout")
                }
            }
        }
        .navigationDestination(for: Movement.self) { selection in
            MovementDetailView(
                viewModel: MovementDetailView.ViewModel(
                    container: viewModel.container,
                    movement: selection))
        }
        .sheet(
            isPresented: $isShowingLoginSheet,
            onDismiss: {
                Task {
                    isLoggedIn = true
                }
            }, content: {
                LoginView(viewModel: LoginView.ViewModel())
            })
        .onAppear() {
            if Keychain.standard.read(service: "accessToken", account: "lumberjacked") == nil {
                isShowingLoginSheet = true
            }
        }
    }
}
