//
//  Item.swift
//  AskAnAIExpertTool
//
//  Created by Bhavik Baraiya on 26/03/26.
//

import Foundation
import SwiftData

@Model
final class QuestionBank {
    var userId: String
    var questionId: UUID
    var question: String
    var decodingTechnique: String
    var correctAnswer: String
    var rationale: String
    var exanTip: String
    var createdAt: Date
    
    init(userId: String, questionId: UUID, question: String, decodingTechnique: String,correctAnswer: String, rationale: String, examTip: String, createdAt: Date) {
        self.userId = userId
        self.questionId = questionId
        self.question = question
        self.decodingTechnique = decodingTechnique
        self.correctAnswer = correctAnswer
        self.rationale = rationale
        self.exanTip = examTip
        self.createdAt = createdAt
    }
}
