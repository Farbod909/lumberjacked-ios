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
        
        var isShowingSignup = false
        var isLoadingToolbarAction = false
        
        var showErrorAlert = false
        var errorAlertItem = ErrorAlertItem()
        
        func attemptLogin() async -> Bool {
            isLoadingToolbarAction = true
            do {
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
                    isLoadingToolbarAction = false
                    return true
                } else {
                    errorAlertItem = ErrorAlertItem(
                        title: "Unknown Error",
                        messages: ["Unexpected response from server."])
                    showErrorAlert = true
                }
            } catch let error as RemoteNetworkingError {
                errorAlertItem = ErrorAlertItem(
                    title: error.error,
                    messages: error.messages)
                showErrorAlert = true
            } catch {
                errorAlertItem = ErrorAlertItem(
                    title: "Unknown Error",
                    messages: [error.localizedDescription])
                showErrorAlert = true
            }
            isLoadingToolbarAction = false
            return false
        }
        
        func attemptSignup() async -> Bool {
            isLoadingToolbarAction = true
            do {
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
                isLoadingToolbarAction = false
                return true
            } catch let error as RemoteNetworkingError {
                errorAlertItem = ErrorAlertItem(
                    title: error.error,
                    messages: error.messages)
                showErrorAlert = true
            } catch {
                errorAlertItem = ErrorAlertItem(
                    title: "Unknown Error",
                    messages: [error.localizedDescription])
                showErrorAlert = true
            }
            isLoadingToolbarAction = false
            return false
        }
    }
}
