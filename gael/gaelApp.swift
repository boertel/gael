//
//  gaelApp.swift
//  gael
//
//  Created by Benjamin Oertel on 10/16/23.
//

import SwiftUI
import SwiftData

@main
struct gaelApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Feeding.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
