//
//  QuestionDetailViewModel.swift
//  AskAnAIExpertTool
//
//  Created by Bhavik Baraiya on 26/03/26.
//

import Foundation
import SwiftData

@Observable
class QuestionDetailViewModel {
    var question: QuestionBank
    
    init(question: QuestionBank) {
        self.question = question
    }
}
