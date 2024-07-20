//
//  LoginSheetView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/19/24.
//

import SwiftUI

struct LoginView: View {
    @State var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            TextField("Email", text: $viewModel.loginEmail)
                .autocorrectionDisabled()
                .autocapitalization(.none)
            SecureField("Password", text: $viewModel.loginPassword)
            Button("Login") {
                Task {
                    await viewModel.login()
                    dismiss()
                }
            }
        }
        .interactiveDismissDisabled()
    }
}
