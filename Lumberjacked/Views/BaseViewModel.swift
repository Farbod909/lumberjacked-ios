//
//  BaseViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/23/24.
//

import SwiftUI

class BaseViewModel {
    var container: ContainerView.ViewModel
    
    var containerErrorAlertItem: Binding<ErrorAlertItem> {
        Binding(
            get: { self.container.errorAlertItem },
            set: { self.container.errorAlertItem = $0 }
        )
    }
    var containerErrorAlertItemIsPresented: Binding<Bool> {
        Binding(
            get: { self.container.errorAlertItemIsPresented },
            set: { self.container.errorAlertItemIsPresented = $0 }
        )
    }
    
    init(container: ContainerView.ViewModel) {
        self.container = container
    }
}
