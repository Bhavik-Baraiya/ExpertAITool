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
        NCLEXExpertView(questionInput: """
        A 45-year-old client has undergone a below-the-knee amputation and expresses concern about returning to work as a construction worker. What should the case manager prioritize when coordinating prosthetic services? \n A. Aesthetic appearance of prosthesis \n B. Cost-effectiveness \n C. Work-related functional needs and rehabilitation \n D. Emotional support with peers with similar experiences
        """
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: QuestionBank.self, inMemory: true)
}
