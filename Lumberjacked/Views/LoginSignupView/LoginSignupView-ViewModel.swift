//
//  LoginSheetView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/18/24.
//

import SwiftUI

extension LoginSignupView {
    @Observable
    class ViewModel {        
        var container: ContainerView.ViewModel

        var firstName = ""
        var lastName = ""
        var email = ""
        var password = ""
        var passwordConfirmation = ""
        
        var isShowingSignup = false
        var isLoadingToolbarAction = false
                
        init(container: ContainerView.ViewModel) {
            self.container = container
        }
        
        func attemptLogin() async -> Bool {
            let loginRequest = LoginRequest(email: email, password: password)
            
            isLoadingToolbarAction = true
            if let response = await container.attemptRequest(
                options: Networking.RequestOptions(
                    url: "/auth/login/password",
                    body: loginRequest,
                    method: .POST,
                    headers: [
                        ("application/json", "Content-Type")
                    ]),
                outputType: LoginResponse.self) {
                Keychain.standard.save(response.accessToken, service: "accessToken", account: "lumberjacked")
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
            let didSucceed = await container.attemptRequest(
                options: Networking.RequestOptions(
                    url: "/users",
                    body: signupRequest,
                    method: .POST,
                    headers: [
                        ("application/json", "Content-Type")
                    ]))
            isLoadingToolbarAction = false
            return didSucceed
        }
    }
}
