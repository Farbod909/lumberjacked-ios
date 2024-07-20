//
//  LoginSheetView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/18/24.
//

import SwiftUI

extension LoginSheetView {
    @Observable
    class ViewModel {
        var loginEmail = ""
        var loginPassword = ""
        
        func login() async {
            let loginRequest = LoginRequest(email: loginEmail, password: loginPassword)
            let loginResponse: LoginResponse? = await Networking()
                .request(
                    options: Networking.RequestOptions(url: "/auth/login/password",
                                                body: loginRequest,
                                                method: .POST,
                                                headers: [
                                                    ("application/json", "Content-Type")
                                                ]))
            if let loginResponse {
                Keychain.standard.save(loginResponse.accessToken, service: "accessToken", account: "lumberjacked")
            }

        }
    }
}
