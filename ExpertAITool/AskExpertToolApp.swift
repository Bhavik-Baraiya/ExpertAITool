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
            
            // Seed initial data
            seedInitialData(container: container)
            
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
    
    private static func seedInitialData(container: ModelContainer) {
        let modelContext = ModelContext(container)
        
        // Check if data already exists
        let descriptor = FetchDescriptor<QuestionBank>()
        let existingCount = try? modelContext.fetchCount(descriptor)
        
        if let count = existingCount, count > 0 {
            return // Data already seeded
        }
        
        // Seed sample questions
        let sampleQuestions = [
            QuestionBank(
                userId: "user_001",
                questionId: UUID(),
                question: "What is the primary nursing intervention for a patient in hypovolemic shock?",
                summaryAnswer: "The primary nursing intervention is rapid fluid resuscitation through IV access to restore circulating blood volume and tissue perfusion.",
                rationale: "Hypovolemic shock occurs when the body loses blood or fluid, reducing cardiac output. Restoring fluid volume is the cornerstone of treatment to prevent organ failure and death. This is supported by the principles of perfusion and oxygenation.",
                nclexTip: "Remember: Hypovolemic shock requires AGGRESSIVE fluid replacement. Think 'ABC' - Airway, Breathing, Circulation. Always check for ongoing bleeding sources.",
                createdAt: Date().addingTimeInterval(-86400 * 3) // 3 days ago
            ),
            QuestionBank(
                userId: "user_001",
                questionId: UUID(),
                question: "Which medication is contraindicated in a patient with acute kidney injury (AKI)?",
                summaryAnswer: "NSAIDs (non-steroidal anti-inflammatory drugs) are contraindicated in AKI as they reduce renal perfusion and can worsen kidney function.",
                rationale: "NSAIDs decrease prostaglandin-mediated renal vasodilation, reducing glomerular filtration rate (GFR). In patients with compromised renal function, this can lead to acute tubular necrosis and worsening renal failure. ACE inhibitors and ARBs should also be used cautiously.",
                nclexTip: "For NCLEX: AVOID NSAIDs in AKI patients! Also avoid ACE-I, ARBs, and aminoglycosides. Remember drugs to AVOID: NSAIDs, Contrast dye, Nephrotoxic agents.",
                createdAt: Date().addingTimeInterval(-86400 * 2) // 2 days ago
            ),
            QuestionBank(
                userId: "user_001",
                questionId: UUID(),
                question: "What are the key signs of diabetic ketoacidosis (DKA)?",
                summaryAnswer: "Key signs include Kussmaul respirations (rapid, deep breathing), fruity-smelling breath (acetone), altered mental status, and severe dehydration.",
                rationale: "DKA results from severe insulin deficiency causing uncontrolled lipolysis and ketone production. The body attempts to compensate for metabolic acidosis through rapid breathing. Blood glucose is typically >250 mg/dL, pH <7.35, and bicarbonate <18 mEq/L.",
                nclexTip: "DKA presentation: 'FRUITY BREATH + FAST BREATHING = DKA'. Assessment priority: ABCs, labs (glucose, pH, ketones), fluid/insulin replacement. Monitor potassium closely!",
                createdAt: Date().addingTimeInterval(-86400) // 1 day ago
            ),
            QuestionBank(
                userId: "user_001",
                questionId: UUID(),
                question: "A client with myocardial infarction (MI) reports chest pain. What is the first nursing action?",
                summaryAnswer: "Place the client in a semi-Fowler position and administer oxygen to maintain SpO2 >94%, then notify the healthcare provider immediately.",
                rationale: "Oxygen increases oxygen availability to the damaged myocardium. Semi-Fowler position reduces cardiac workload and promotes ease of breathing. Immediate notification ensures rapid medical intervention including ECG, troponin levels, and cardiac medications.",
                nclexTip: "MI Priority: 'MONA' - Morphine, Oxygen, Nitroglycerin, Aspirin. Always give oxygen FIRST, then notify provider. Get ECG within 10 minutes!",
                createdAt: Date().addingTimeInterval(-3600) // 1 hour ago
            ),
            QuestionBank(
                userId: "user_001",
                questionId: UUID(),
                question: "What is the most critical nursing assessment for a postoperative patient?",
                summaryAnswer: "The most critical assessment is the ABC check: Airway patency, Breathing adequacy, and Circulation status including vital signs and perfusion.",
                rationale: "Immediate postoperative complications can affect these vital systems due to anesthesia effects, blood loss, and surgical trauma. Compromised airway, breathing, or circulation can rapidly deteriorate into life-threatening conditions. Regular monitoring every 5-15 minutes initially is essential.",
                nclexTip: "Postop Priority: Always check ABCs FIRST! Then pain, I&Os, wound, LOC. Remember: Early ambulation prevents complications like DVT. Encourage coughing/deep breathing.",
                createdAt: Date() // Just now
            ),
        ]
        
        for question in sampleQuestions {
            modelContext.insert(question)
        }
        
        try? modelContext.save()
    }
}
