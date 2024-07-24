//
//  LoginSheetView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/19/24.
//

import SwiftUI

struct LoginSignupView: View {
    @State var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Text("Lumberjacked")
                    .font(.custom("Marker Felt", size: 34))
                Form {
                    if viewModel.isShowingSignup {
                        TextField("First name", text: $viewModel.firstName)
                            .autocorrectionDisabled()
                            .listRowBackground(Color.init(uiColor: .systemGray6))
                        TextField("Last name", text: $viewModel.lastName)
                            .autocorrectionDisabled()
                            .listRowBackground(Color.init(uiColor: .systemGray6))
                        
                    }
                    TextField("Email", text: $viewModel.email)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .listRowBackground(Color.init(uiColor: .systemGray6))
                    SecureField("Password", text: $viewModel.password)
                        .listRowBackground(Color.init(uiColor: .systemGray6))
                    if viewModel.isShowingSignup {
                        SecureField("Confirm password", text: $viewModel.passwordConfirmation)
                            .listRowBackground(Color.init(uiColor: .systemGray6))
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .interactiveDismissDisabled()
                .animation(.default, value: viewModel.isShowingSignup)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if !viewModel.isShowingSignup {
                        Button {
                            Task {
                                guard await viewModel.attemptLogin() else {
                                    return
                                }
                                dismiss()
                            }
                        } label: {
                            if viewModel.isLoadingToolbarAction {
                                ProgressView()
                            } else {
                                Text("Log in")
                            }
                        }
                    } else {
                        Button {
                            Task {
                                guard await viewModel.attemptSignup() else {
                                    return
                                }
                                guard await viewModel.attemptLogin() else {
                                    return
                                }
                                dismiss()
                            }
                        } label: {
                            if viewModel.isLoadingToolbarAction {
                                ProgressView()
                            } else {
                                Text("Sign up")
                            }
                        }
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    if !viewModel.isShowingSignup {
                        Button("Signup") {
                            viewModel.isShowingSignup = true
                        }
                    } else {
                        Button("Cancel") {
                            viewModel.isShowingSignup = false
                        }
                    }
                }
            }
            .alert(viewModel.errorAlertItem, isPresented: $viewModel.errorAlertItemIsPresented)
        }
    }
}
