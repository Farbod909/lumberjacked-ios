//
//  Alert.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/20/24.
//

import SwiftUI


struct ErrorAlertItem {
    var title: String = ""
    var messages: [String]?
}

extension View {
    func alert(_ alertItem: ErrorAlertItem, isPresented: Binding<Bool>) -> some View {
        return alert(alertItem.title, isPresented: isPresented) {
            Button("OK") { }
        } message: {
            if let messages = alertItem.messages {
                VStack {
                    ForEach(messages, id: \.self) { message in
                        Text(message)
                    }
                }
            }
        }
    }
}
