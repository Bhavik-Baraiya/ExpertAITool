//
//  AIExpertService.swift
//  AskAnAIExpertTool
//
//  Created by Bhavik Baraiya on 26/03/26.
//

import Foundation
import FoundationModels

struct AIResponse {
    var decodingTechnique: String
    var correctAnswer: String
    var rationale: String
    var examTip: String
}

class AIExpertService {
    static let shared = AIExpertService()
    var isLoading: Bool = false
    var error: String?
    
    private let systemInstructions = """
        You are a certified case management (CCM) exam coach with deep expertise in case management principles, rehabilitation, and healthcare coordination.
        When I give you a CCM exam multiple-choice question.
    
        IMPORTANT: You MUST ALWAYS follow this exact response structure. Output exactly three sections:
    
        ---
        1. DECODING_TECHNIQUE

        - Identify the key role/context clues in the question stem
        - Highlight the action word (e.g., "prioritise", "first", "best")
        - Explain how to eliminate each wrong answer using case management logic
        - Name the test-taking strategy used (e.g., Maslow's hierarchy, ABC priority, scope of practice, client-centered care)

        2. CORRECT_ANSWER

        - State the letter and full answer text
        - Write one clear sentence explaining why it is the strongest choice

        3. RATIONALE

        - Explain why the correct answer aligns with CCM core competencies
        - Briefly state why each remaining option (A, B, C, D) is incorrect
          or secondary in this scenario
    
        4. EXAM_TIP

        - A strategic tip (e.g., "Eliminate 'always/never' options") or a mnemonic.
        ---
    
        Always use this format:
        DECODING_TECHNIQUE: [Your 5-7 sentence decoded questions analysis]
        CORRECT_ANSWER: [Your clear sentence of wny it is the strongest choice]
        RATIONALE: [Your detailed explanation]
        EXAM_TIP: [Your strategic tip or mnemonic]
    """
    private var languageModelSession: LanguageModelSession?
    
    private init() {
        initializeLanguageModel()
    }
    
    private func initializeLanguageModel() {
        let model = SystemLanguageModel.default
        let instructions = Instructions(systemInstructions)
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
            return AIResponse(decodingTechnique: "", correctAnswer: "", rationale: "", examTip: "")
        }
        
        self.isLoading = true
        self.error = nil
        
        do {
            let options = GenerationOptions(temperature: 0.0)
            
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
        
        return AIResponse(decodingTechnique: "", correctAnswer: "", rationale: "", examTip: "")
    }
    
    private func parseNursingInfo(from text: String) -> AIResponse {
        func extract(from: String, to: String?, in source: String) -> String {
            guard let startRange = source.range(of: from) else { return "" }
            
            let searchRange: Range<String.Index>
            if let to = to, let endRange = source.range(of: to, range: startRange.upperBound..<source.endIndex) {
                searchRange = startRange.upperBound..<endRange.lowerBound
            } else {
                searchRange = startRange.upperBound..<source.endIndex
            }
            
            return String(source[searchRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let decodingTechnique = extract(from: "DECODING_TECHNIQUE:", to: "CORRECT_ANSWER:", in: text)
        let correctAnswer = extract(from: "CORRECT_ANSWER:", to: "RATIONALE:", in: text)
        let rationale = extract(from: "RATIONALE:", to: "EXAM_TIP:", in: text)
        let examTip = extract(from: "EXAM_TIP:", to: nil, in: text)

        return AIResponse(
            decodingTechnique: decodingTechnique,
            correctAnswer: correctAnswer,
            rationale: rationale,
            examTip: examTip
        )
    }
}
