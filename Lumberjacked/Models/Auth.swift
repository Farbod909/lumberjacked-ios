//
//  Auth.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/18/24.
//

struct LoginRequest: Codable {
    var email: String
    var password: String
}

struct LoginResponse: Codable {
    var accessToken: String
}

struct SignupRequest: Codable {
    var firstName: String
    var lastName: String
    var email: String
    var password: String
    var passwordConfirmation: String
}
