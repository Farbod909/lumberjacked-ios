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
        
        @ObservationIgnored
        lazy var contentViewModel = {
            ContentView.ViewModel(container: self)
        }()
    }
}
