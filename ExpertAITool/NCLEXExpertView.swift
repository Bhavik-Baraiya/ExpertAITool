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
                .navigationTitle("NCLEX Expert")
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
            QuestionDetailView(viewModel: QuestionDetailViewModel(question: viewModel.questions.first!))
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
            
            Text("Tap the floating AI button to ask your first medical question")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemeConstants.white)
    }
    
    private var listView: some View {
        List {
            ForEach(viewModel.questions, id: \.questionId) { question in
                NavigationLink(destination: QuestionDetailView(viewModel: QuestionDetailViewModel(question: question))) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(question.question)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .lineLimit(2)
                        
                        Text(formattedDate(question.createdAt))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }
            }
            .onDelete(perform: deleteQuestion)
        }
        .listStyle(.plain)
        .background(ThemeConstants.white)
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
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(Color.black.opacity(0.8))
            .cornerRadius(16)
        }
    }
    
    private var askQuestionSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ask an NCLEX Question")
                        .font(.headline)
                    
                    Text("Enter your medical or nursing question for expert analysis")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                TextEditor(text: $questionInput)
                    .font(.body)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(ThemeConstants.lightThemeTint)
                    .cornerRadius(8)
                    .foregroundStyle(viewModel.isLoading ? Color.gray : Color.primary)
                    .disabled(viewModel.isLoading ? true : false)
                
                Button(action: submitQuestion) {
                    Text(viewModel.isLoading ? "Generating..." : "Submit Question")
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
                }
            }
            .background(ThemeConstants.white)
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
