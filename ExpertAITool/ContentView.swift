//
//  ContentView.swift
//  AskAnAIExpertTool
//
//  Created by Bhavik Baraiya on 26/03/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NCLEXExpertView(questionInput: "The nurse caring for a client with heart failure who has been receiving intravenous (IV) diuretics suspects that the client is experiencing a fluid volume deficit. Which assessment finding would the nurse note in a client with this condition?")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: QuestionBank.self, inMemory: true)
}
