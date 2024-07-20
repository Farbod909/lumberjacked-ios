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
        var firstName = ""
        var lastName = ""
        var email = ""
        var password = ""
        var passwordConfirmation = ""
        
        func login() async throws {
            let loginRequest = LoginRequest(email: email, password: password)
            let loginResponse: LoginResponse? = try await Networking()
                .request(
                    options: Networking.RequestOptions(url: "/auth/login/password",
                                                       body: loginRequest,
                                                       method: .POST,
                                                       headers: [
                                                        ("application/json", "Content-Type")
                                                       ]))
            if let accessToken = loginResponse?.accessToken {
                Keychain.standard.save(accessToken, service: "accessToken", account: "lumberjacked")
            } else {
                print("No access token found.")
            }
        }
        
        func signup() async throws {
            let signupRequest = SignupRequest(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password,
                passwordConfirmation: passwordConfirmation)
            try await Networking()
                .request(
                    options: Networking.RequestOptions(url: "/users",
                                                       body: signupRequest,
                                                       method: .POST,
                                                       headers: [
                                                        ("application/json", "Content-Type")
                                                       ]))
        }
    }
}
