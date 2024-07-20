//
//  LoginSheetView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/19/24.
//

import SwiftUI

struct LoginSignupView: View {
    @State var viewModel: ViewModel
    
    @State var isShowingSignup = false
    
    @State var showErrorAlert = false
    @State var errorAlertItem = ErrorAlertItem()
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Text("Lumberjacked")
                    .font(.custom("Marker Felt", size: 34))
                Form {
                    if isShowingSignup {
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
                    if isShowingSignup {
                        SecureField("Confirm password", text: $viewModel.passwordConfirmation)
                            .listRowBackground(Color.init(uiColor: .systemGray6))
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .interactiveDismissDisabled()
                .animation(.default, value: isShowingSignup)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        if !isShowingSignup {
                            Button("Login") {
                                Task {
                                    do {
                                        try await viewModel.login()
                                        dismiss()
                                    } catch let error as HttpError {
                                        errorAlertItem = ErrorAlertItem(
                                            title: error.error,
                                            messages: error.messages)
                                        showErrorAlert = true
                                    }
                                }
                            }
                        } else {
                            Button("Signup") {
                                Task {
                                    do {
                                        try await viewModel.signup()
                                        try await viewModel.login()
                                        dismiss()
                                    } catch let error as HttpError {
                                        errorAlertItem = ErrorAlertItem(
                                            title: error.error,
                                            messages: error.messages)
                                        showErrorAlert = true
                                    }
                                }
                            }
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        if !isShowingSignup {
                            Button("Signup") {
                                isShowingSignup = true
                            }
                        } else {
                            Button("Cancel") {
                                isShowingSignup = false
                            }
                        }
                    }
                }
            }
            .alert(errorAlertItem, isPresented: $showErrorAlert)
        }
    }
}

#Preview {
    LoginSignupView(viewModel: LoginSignupView.ViewModel())
}
