//
//  ContainerView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/8/24.
//

import SwiftUI

struct ContainerView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ContentView(viewModel: viewModel.contentViewModel)
        }
    }
}
