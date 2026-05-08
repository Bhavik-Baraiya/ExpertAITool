//
//  NCLEXExpertView.swift
//  AskAnAIExpertTool
//
//  Created by Bhavik Baraiya on 26/03/26.
//

import SwiftUI
import SwiftData

struct NCLEXExpertView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = NCLEXExpertViewModel()
    @State private var showInputSheet = false
    @State private var showOutputSheet = false
    @State var questionInput: String
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.5
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    if viewModel.questions.isEmpty {
                        emptyStateView
                    } else {
                        listView
                    }
                }
                .navigationTitle("CCM Tutor")
                .navigationBarTitleDisplayMode(.inline)
            }
            
            // Loading overlay
            if viewModel.isLoading {
                loadingOverlay
            }
            
            // Floating AI button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    floatingAIButton
                        .padding(20)
                }
            }
        }
        .onAppear {
            viewModel.fetchQuestions(from: modelContext)
        }
        .sheet(isPresented: $showInputSheet) {
            askQuestionSheet
        }
        .sheet(isPresented: $showOutputSheet) {
            if let firstQuestion = viewModel.questions.first {
                QuestionDetailView(viewModel: QuestionDetailViewModel(question: firstQuestion))
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "stethoscope.circle")
                .font(.system(size: 64))
                .foregroundColor(ThemeConstants.primaryRed)
            
            Text("No Questions Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(ThemeConstants.text)
            
            Text("Tap the floating  AI button below to start decoding your first question.")
                .font(.body)
                .foregroundColor(ThemeConstants.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemeConstants.backgroundColor)
    }
    
    private var listView: some View {
        List {
            ForEach(viewModel.questions, id: \.questionId) { question in
                NavigationLink(destination: QuestionDetailView(viewModel: QuestionDetailViewModel(question: question))) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(question.question)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(ThemeConstants.text)
                            .lineLimit(2)
                        
                        Text(formattedDate(question.createdAt))
                            .font(.caption)
                            .foregroundColor(ThemeConstants.secondaryText)
                    }
                    .padding(.vertical, 8)
                }
            }
            .onDelete(perform: deleteQuestion)
        }
        .listStyle(.plain)
        .background(ThemeConstants.backgroundColor)
    }
    
    private var floatingAIButton: some View {
        Button(action: { showInputSheet = true }) {
            ZStack {
                // Glow ring (pulsing when not loading)
                if !viewModel.isLoading {
                    Circle()
                        .stroke(ThemeConstants.primaryRed, lineWidth: 2)
                        .opacity(glowOpacity)
                        .scaleEffect(pulseScale)
                }
                
                // Main button circle
                Circle()
                    .fill(ThemeConstants.primaryRed)
                    .scaleEffect(viewModel.isLoading ? 1.1 : 1.0)
                
                // Icon
                Image(systemName: "sparkles")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 64, height: 64)
        }
        .disabled(viewModel.isLoading)
        .onAppear {
            startPulseAnimation()
        }
        .shadow(color: ThemeConstants.primaryRed.opacity(0.5), radius: 12, x: 0, y: 4)
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .tint(ThemeConstants.primaryRed)
                    .scaleEffect(1.5)
                
                Text("Generating Expert Response...")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeConstants.text)
            }
            .padding(32)
            .background(ThemeConstants.backgroundColor.opacity(0.95))
            .cornerRadius(16)
        }
    }
    
    private var askQuestionSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Decode Your Question")
                        .font(.headline)
                        .foregroundColor(ThemeConstants.text)
                    
                    Text("Get simplified explanations, clinical rationale, decoding strategies, and exam-focused tips for medical and nursing questions.")
                        .font(.caption)
                        .foregroundColor(ThemeConstants.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                TextEditor(text: $questionInput)
                    .font(.body)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(ThemeConstants.lightThemeTint)
                    .cornerRadius(8)
                    .foregroundStyle(viewModel.isLoading ? ThemeConstants.secondaryText : ThemeConstants.text)
                    .disabled(viewModel.isLoading ? true : false)
                
                Button(action: submitQuestion) {
                    Text(viewModel.isLoading ? "Decoding..." : "Submit Question")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(ThemeConstants.primaryRed)
                        .cornerRadius(8)
                        .disabled(questionInput.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)
                }
                .disabled(questionInput.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)
                
                Spacer()
            }
            .padding(16)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showInputSheet = false
                        questionInput = ""
                    }
                    .disabled(viewModel.isLoading)
                    .foregroundColor(ThemeConstants.primaryRed)
                }
            }
            .background(ThemeConstants.backgroundColor)
        }
        .interactiveDismissDisabled(viewModel.isLoading)
    }
    
    // MARK: - Helper Methods
    
    private func submitQuestion() {
        Task {
            await viewModel.askQuestion(questionInput, modelContext: modelContext)
            if viewModel.errorMessage == nil {
                showInputSheet = false
                showOutputSheet = true
                questionInput = ""
            }
        }
    }
    
    private func deleteQuestion(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteQuestion(viewModel.questions[index], from: modelContext)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.3
            glowOpacity = 0.2
        }
    }
}

#Preview {
    NCLEXExpertView(questionInput: "")
        .modelContainer(for: QuestionBank.self, inMemory: true)
}
