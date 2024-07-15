//
//  MovementInputView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/14/24.
//

import SwiftUI

extension MovementInputView {
    @Observable
    class ViewModel {
        var container: ContainerView.ViewModel
        var movement: Movement
        
        init(container: ContainerView.ViewModel, movement: Movement) {
            self.container = container
            self.movement = movement
        }
    }
}
