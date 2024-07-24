//
//  LoginSheetView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/18/24.
//

import SwiftUI

extension LoginSignupView {
    @Observable
    class ViewModel: BaseViewModel {
        var firstName = ""
        var lastName = ""
        var email = ""
        var password = ""
        var passwordConfirmation = ""
        
        var isShowingSignup = false
        var isLoadingToolbarAction = false
        
        var errorAlertItem = ErrorAlertItem()
        var errorAlertItemIsPresented = false
        
        var errorAlertItemBinding: Binding<ErrorAlertItem> {
            Binding(
                get: { self.errorAlertItem },
                set: { self.errorAlertItem = $0 }
            )
        }
        var errorAlertItemIsPresentedBinding: Binding<Bool> {
            Binding(
                get: { self.errorAlertItemIsPresented },
                set: { self.errorAlertItemIsPresented = $0 }
            )
        }
        
        func attemptLogin() async -> Bool {
            let loginRequest = LoginRequest(email: email, password: password)
            
            isLoadingToolbarAction = true
            if let response = await NetworkingRequest(
                options: Networking.RequestOptions(
                    url: "/auth/login/password",
                    body: loginRequest,
                    method: .POST,
                    headers: [
                        ("application/json", "Content-Type")
                    ]),
                errorAlertItem: errorAlertItemBinding,
                errorAlertItemIsPresented: errorAlertItemIsPresentedBinding
            ).attempt(outputType: LoginResponse.self) {
                Keychain.standard.save(
                    response.accessToken, service: "accessToken", account: "lumberjacked")
                isLoadingToolbarAction = false
                return true
            }
            isLoadingToolbarAction = false
            return false
        }
        
        func attemptSignup() async -> Bool {
            let signupRequest = SignupRequest(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password,
                passwordConfirmation: passwordConfirmation)

            isLoadingToolbarAction = true
            let didSucceed = await NetworkingRequest(
                options: Networking.RequestOptions(
                    url: "/users",
                    body: signupRequest,
                    method: .POST,
                    headers: [
                        ("application/json", "Content-Type")
                    ]
                ),
                errorAlertItem: errorAlertItemBinding,
                errorAlertItemIsPresented: errorAlertItemIsPresentedBinding
            ).attempt()
            isLoadingToolbarAction = false
            return didSucceed
        }
    }
}
