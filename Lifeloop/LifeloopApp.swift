//
//  LifeloopApp.swift
//  Lifeloop
//
//  Created by Anuj S on 17/01/2026.
//

import SwiftUI
import CoreData

@main
struct LifeloopApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
