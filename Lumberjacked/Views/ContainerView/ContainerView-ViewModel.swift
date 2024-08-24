//
//  ContainerView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/8/24.
//

import SwiftUI

extension ContainerView {
    @Observable
    class ViewModel {
        var path = NavigationPath()
        
        var errorAlertItem = ErrorAlertItem()
        var errorAlertItemIsPresented = false

        @ObservationIgnored
        lazy var homeViewModel = {
            HomeView.ViewModel(container: self)
        }()
    }
}
