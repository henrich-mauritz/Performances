//
//  AlertModifier.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//

import SwiftUI

struct AlertModifier: ViewModifier {
    @StateObject var errorHandling = ErrorHandling()
    
    func body(content: Content) -> some View {
        content
            .environmentObject(errorHandling)
            .background(
                EmptyView()
                    .alert(item: $errorHandling.currentAlert) { currentAlert in
                        Alert(
                            title: Text("Error"),
                            message: Text(currentAlert.message),
                            dismissButton: .default(Text("Ok")) {
                                currentAlert.dismissAction?()
                            }
                        )
                    }
            )
    }
}

