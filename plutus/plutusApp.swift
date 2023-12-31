//
//  plutusApp.swift
//  plutus
//
//  Created by Akhil Sukhthankar on 11/17/23.
//

import SwiftUI
import SwiftData

@main
struct plutusApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Holding.self,
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
