//
//  AIExpertService.swift
//  AskAnAIExpertTool
//
//  Created by Bhavik Baraiya on 26/03/26.
//

import Foundation
import FoundationModels

struct AIResponse {
    var summaryAnswer: String
    var rationale: String
    var nclexTip: String
}

class AIExpertService {
    static let shared = AIExpertService()
    var isLoading: Bool = false
    var error: String?
    
    private let systemPrompt = """
        You are a Nurse Educator specializing in NCLEX preparation. Your goal is to mentor students using clinical reasoning.
        
        IMPORTANT: You MUST ALWAYS follow this exact response structure. Output exactly three sections:
        
        1. SUMMARY_ANSWER: A 4-5 sentence direct response to the question.
        2. RATIONALE: A 4-5 sentence explanation of the "why," focusing on pathophysiology or nursing logic.
        3. NCLEX_TIP: A strategic tip (e.g., "Eliminate 'always/never' options") or a mnemonic.
        
        Guiding Frameworks: Always prioritize responses based on ABCs (Airway, Breathing, Circulation), Maslow's Hierarchy, and the Nursing Process (ADPIE).
        
        Always use this format:
        SUMMARY_ANSWER: [Your 4-5 sentence answer]
        RATIONALE: [Your detailed explanation]
        NCLEX_TIP: [Your strategic tip or mnemonic]
    """
    private var languageModelSession: LanguageModelSession?
    
    private init() {
        initializeLanguageModel()
    }
    
    private func initializeLanguageModel() {
        let model = SystemLanguageModel.default
        let instructions = Instructions(systemPrompt)
        self.languageModelSession = LanguageModelSession(model: model, instructions: instructions)
    }
    /// Generate expert response for a given question
    /// - Parameter question: The medical/nursing question to ask
    /// - Returns: AIResponse with summaryAnswer, rationale, and nclexTip
    func generateExpertResponse(for question: String) async throws -> AIResponse {
        // Simulate API call with delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
        
        // For POC, return realistic demo responses
        return await generateDemoResponse(for: question)
    }
    
    /// Generate demo response for demonstration purposes
    private func generateDemoResponse(for question: String) async -> AIResponse {
        
        self.isLoading = true
        
        guard let session = languageModelSession else {
            let errorMessage = "Foundation Models not available. Ensure Apple Intelligence is enabled on your device and the model is downloaded."
            self.error = errorMessage
            self.isLoading = false
            return AIResponse(summaryAnswer: "Error", rationale: "Error", nclexTip: "Error")
        }
        
        self.isLoading = true
        self.error = nil
        
        do {
            let options = GenerationOptions(temperature: 0.7)
            
            // Stream the response from the foundation model
            let respond = try await session.respond(to: question, options: options)
            self.isLoading = session.isResponding
            if(!self.isLoading) {
                return self.parseNursingInfo(from: respond.content)
            }
        } catch {
            let errorMessage: String
            
            if let generationError = error as? LanguageModelSession.GenerationError {
                switch generationError {
                    
                    case .unsupportedLanguageOrLocale:
                        errorMessage = "The requested language or locale is not supported by the model."
                    
                    case .exceededContextWindowSize(_):
                        errorMessage = "The input exceeds the model's context window size."
                    
                    case .assetsUnavailable(_):
                        errorMessage = "Required model assets are unavailable. Please ensure the model is downloaded and up to date."
                    
                    case .guardrailViolation(_):
                        errorMessage = "The model's guardrails were triggered. Please rephrase your question to avoid restricted content."
                    
                    case .unsupportedGuide(_):
                        errorMessage = "The specified guide is not supported by the model."
                    
                    case .decodingFailure(_):
                        errorMessage = "Failed to decode the model's response. Please try again."
                    
                    case .rateLimited(_):
                        errorMessage = "You are being rate limited. Please wait a moment before trying again."
                    
                    case .concurrentRequests(_):
                        errorMessage = "Too many concurrent requests. Please wait a moment before trying again."
                    
                    case .refusal(_, _):
                        errorMessage = "The model refused to generate a response. This may be due to content restrictions or other guardrail triggers."
                    
                    @unknown default:
                        errorMessage = "Model generation error: \(generationError.localizedDescription)"
                }
            } else {
                errorMessage = error.localizedDescription
            }
            
            self.error = errorMessage
            self.isLoading = false
        }
        
        return AIResponse(
            summaryAnswer: "",
            rationale: "",
            nclexTip: ""
        )
    }
    
    private func parseNursingInfo(from text: String) -> AIResponse{
        var currentResponse: AIResponse?
        func extract(from: String, to: String?, in source: String) -> String {
            guard let startRange = source.range(of: from) else { return "" }
            
            let searchRange: Range<String.Index>
            if let to = to, let endRange = source.range(of: to) {
                searchRange = startRange.upperBound..<endRange.lowerBound
            } else {
                searchRange = startRange.upperBound..<source.endIndex
            }
            
            return source[searchRange].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let summary = extract(from: "SUMMARY_ANSWER:", to: "RATIONALE:", in: text)
        currentResponse?.summaryAnswer.append(summary.replacingOccurrences(of: "SUMMARY_ANSWER:", with: ""))
        let rationale = extract(from: "RATIONALE:", to: "NCLEX_TIP:", in: text)
        currentResponse?.rationale.append(rationale.replacingOccurrences(of: "RATIONALE:", with: ""))
        let tip = extract(from: "NCLEX_TIP:", to: nil, in: text)
        currentResponse?.nclexTip.append(tip.replacingOccurrences(of: "NCLEX_TIP:", with: ""))
        
        return currentResponse ?? AIResponse(summaryAnswer: summary, rationale: rationale, nclexTip: tip)
    }
}
