//
//  AskAnAIExpertToolApp.swift
//  AskAnAIExpertTool
//
//  Created by Bhavik Baraiya on 26/03/26.
//

import SwiftUI
import SwiftData

@main
struct AskAnAIExpertToolApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            QuestionBank.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
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
