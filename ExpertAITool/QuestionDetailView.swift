//
//  QuestionDetailView.swift
//  AskAnAIExpertTool
//
//  Created by Bhavik Baraiya on 26/03/26.
//

import SwiftUI
import SwiftData

struct QuestionDetailView: View {
    var viewModel: QuestionDetailViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header section
                    headerSection
                    
                    // Decoding technique
                    contentSection(
                        title: "Decoding technique",
                        content: viewModel.question.decodingTechnique
                    )
                    
                    // Correct Answer
                    contentSection(
                        title: "Correct Answer",
                        content: viewModel.question.correctAnswer
                    )
                    
                    // Rationale
                    contentSection(
                        title: "Rationale",
                        content: viewModel.question.rationale
                    )
                    
                    // Exam tip
                    contentSection(
                        title: "Exam tip",
                        content: viewModel.question.exanTip
                    )
                    
                    Spacer()
                }
                .padding(16)
            }
            .background(ThemeConstants.backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(ThemeConstants.primaryRed)
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Tutor Analysis")
                .font(.title3)
                .fontWeight(.regular)
                .foregroundColor(ThemeConstants.secondaryText)
            
            Text(viewModel.question.question)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ThemeConstants.text)
                .lineLimit(nil)
            
            Divider()
                .foregroundColor(ThemeConstants.accentRed.opacity(0.3))
            
            Text("Asked on \(formattedDate(viewModel.question.createdAt))")
                .font(.caption)
                .foregroundColor(ThemeConstants.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(ThemeConstants.lightThemeTint)
        .cornerRadius(12)
        .shadow(color: ThemeConstants.primaryRed.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func contentSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(ThemeConstants.primaryRed)
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(ThemeConstants.text)

                Spacer()
            }
            
            Text(content)
                .font(.body)
                .lineHeight(1.6)
                .foregroundColor(ThemeConstants.text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(ThemeConstants.lightThemeTint)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ThemeConstants.accentRed.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Helper Methods
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Line height modifier
extension Text {
    func lineHeight(_ lineHeight: CGFloat) -> some View {
        self.tracking(0)
    }
}

#Preview {
    let sampleQuestion =  QuestionBank(userId: "user_001",
                                       questionId: UUID(),
                                       question: "What is the primary nursing intervention for a patient in hypovolemic shock?",
                                       decodingTechnique: "The primary nursing intervention is rapid fluid resuscitation through IV access to restore circulating blood volume and tissue perfusion.",
                                       correctAnswer: "B",
                                       rationale: "Hypovolemic shock occurs when the body loses blood or fluid, reducing cardiac output. Restoring fluid volume is the cornerstone of treatment to prevent organ failure and death.",
                                       examTip: "Remember SHOCK: Stabilize airway, assess for Hemorrhage, Order fluids/blood, Control bleeding, Keep monitoring. Priority is always ABCs and fluid replacement.",
                                       createdAt: Date())
    
    QuestionDetailView(viewModel: QuestionDetailViewModel(question: sampleQuestion))
        .modelContainer(for: QuestionBank.self, inMemory: true)
}
