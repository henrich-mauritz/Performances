//
//  GameSaverApp.swift
//  GameSaver
//
//  Created by Henrich Mauritz on 24/02/2022.
//

import SwiftUI

@main
struct GameSaverApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
