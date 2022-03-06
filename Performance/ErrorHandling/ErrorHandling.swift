//
//  ErrorHandling.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//

import Foundation

class ErrorHandling: ObservableObject {
    @Published var currentAlert: ErrorAlert?

    func handle(error: Error) {
        currentAlert = ErrorAlert(message: error.localizedDescription)
    }
}
