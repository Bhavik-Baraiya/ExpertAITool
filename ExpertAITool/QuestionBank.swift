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
    var summaryAnswer: String
    var rationale: String
    var nclexTip: String
    var createdAt: Date
    
    init(userId: String, questionId: UUID, question: String, summaryAnswer: String, rationale: String, nclexTip: String, createdAt: Date) {
        self.userId = userId
        self.questionId = questionId
        self.question = question
        self.summaryAnswer = summaryAnswer
        self.rationale = rationale
        self.nclexTip = nclexTip
        self.createdAt = createdAt
    }
}
