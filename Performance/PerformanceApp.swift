//
//  PerformanceApp.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//

import SwiftUI
import Firebase

@main
struct PerformanceApp: App {
    
    init() {
        FirebaseApp.configure()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        let db = Firestore.firestore()
        db.settings = settings
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .withErrorHandling()
        }
    }
}
