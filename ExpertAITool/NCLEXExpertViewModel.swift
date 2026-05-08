//
//  NCLEXExpertViewModel.swift
//  AskAnAIExpertTool
//
//  Created by Bhavik Baraiya on 26/03/26.
//

import Foundation
import SwiftData

@Observable
class NCLEXExpertViewModel {
    var questions: [QuestionBank] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var currentUserID: String = "user_001"
    
    private let aiService = AIExpertService.shared
    
    /// Fetch all questions from SwiftData
    func fetchQuestions(from modelContext: ModelContext) {
        do {
            let descriptor = FetchDescriptor<QuestionBank>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            questions = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Failed to fetch questions: \(error.localizedDescription)"
        }
    }
    
    /// Ask a new question and get AI response
    func askQuestion(_ questionText: String, modelContext: ModelContext) async {
        guard !questionText.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a question"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Generate AI response
            let aiResponse = try await aiService.generateExpertResponse(for: questionText)
            
            // Create new QuestionBank record
            
            let newQuestion = QuestionBank(userId: currentUserID,
                                           questionId: UUID(), question: questionText,
                                           decodingTechnique: aiResponse.decodingTechnique,
                                           correctAnswer: aiResponse.correctAnswer,
                                           rationale: aiResponse.rationale,
                                           examTip: aiResponse.examTip,
                                           createdAt: Date())
            
            // Insert into SwiftData
            modelContext.insert(newQuestion)
            try modelContext.save()
            
            // Add to local array
            questions.insert(newQuestion, at: 0)
            
            isLoading = false
        } catch {
            errorMessage = "Failed to generate response: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Delete a question
    func deleteQuestion(_ question: QuestionBank, from modelContext: ModelContext) {
        modelContext.delete(question)
        try? modelContext.save()
        questions.removeAll { $0.questionId == question.questionId }
    }
}
