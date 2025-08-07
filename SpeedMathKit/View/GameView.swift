import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top HUD
                topHUD
                
                Spacer()
                
                // Game content
                gameContent
                
                Spacer()
                
                // Answer options
                answerOptions
                
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
    
    private var topHUD: some View {
        VStack(spacing: 16) {
            // Header with back button and mode
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(viewModel.gameMode.rawValue)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    Text("Level \(viewModel.currentLevel)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Placeholder for symmetry
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .opacity(0)
            }
            
            // Timer and progress
            HStack(spacing: 20) {
                // Score
                VStack(spacing: 4) {
                    Text("\(viewModel.score)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Score")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Timer (for time-based modes)
                if viewModel.gameMode == .timeAttack || viewModel.gameMode == .dailyStreak {
                    VStack(spacing: 4) {
                        Text(timeString)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(timerColor)
                        
                        Text("Time")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                } else {
                    // Progress for count challenge
                    VStack(spacing: 4) {
                        Text("\(viewModel.problemsSolved)/\(viewModel.targetProblems)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Progress")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Streak
                VStack(spacing: 4) {
                    Text("\(viewModel.currentStreak)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    
                    Text("Streak")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            if viewModel.gameMode == .timeAttack || viewModel.gameMode == .dailyStreak {
                ProgressView(value: viewModel.timeRemaining, total: viewModel.timeLimit)
                    .progressViewStyle(LinearProgressViewStyle(tint: timerColor))
                    .frame(height: 6)
            } else {
                ProgressView(value: Double(viewModel.problemsSolved), total: Double(viewModel.targetProblems))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 6)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var gameContent: some View {
        VStack(spacing: 30) {
            if let problem = viewModel.currentProblem {
                // Math problem
                VStack(spacing: 20) {
                    Text(problem.question)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .scaleEffect(viewModel.showFeedback ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.showFeedback)
                    
                    // Feedback indicator
                    if viewModel.showFeedback {
                        HStack(spacing: 8) {
                            Image(systemName: viewModel.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(viewModel.isCorrect ? .green : .red)
                            
                            Text(viewModel.isCorrect ? "Correct!" : "Incorrect")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(viewModel.isCorrect ? .green : .red)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            viewModel.showFeedback ? (viewModel.isCorrect ? Color.green : Color.red) : Color.clear,
                            lineWidth: 3
                        )
                )
                .animation(.easeInOut(duration: 0.3), value: viewModel.showFeedback)
            }
        }
    }
    
    private var answerOptions: some View {
        VStack(spacing: 16) {
            if let problem = viewModel.currentProblem {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(problem.options, id: \.self) { option in
                        AnswerButton(
                            answer: option,
                            isSelected: viewModel.selectedAnswer == option,
                            isCorrect: viewModel.showFeedback && option == problem.correctAnswer,
                            isWrong: viewModel.showFeedback && viewModel.selectedAnswer == option && option != problem.correctAnswer
                        ) {
                            viewModel.submitAnswer(option)
                        }
                    }
                }
            }
        }
    }
    
    private var timeString: String {
        let minutes = Int(viewModel.timeRemaining) / 60
        let seconds = Int(viewModel.timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var timerColor: Color {
        if viewModel.timeRemaining < 10 {
            return .red
        } else if viewModel.timeRemaining < 30 {
            return .orange
        } else {
            return .primary
        }
    }
}

struct AnswerButton: View {
    let answer: Int
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(answer)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(backgroundColor)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: 3)
                )
                .scaleEffect(isSelected ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isSelected)
        }
        .disabled(isSelected)
    }
    
    private var backgroundColor: Color {
        if isCorrect {
            return .green.opacity(0.2)
        } else if isWrong {
            return .red.opacity(0.2)
        } else if isSelected {
            return .blue.opacity(0.2)
        } else {
            return .clear
        }
    }
    
    private var textColor: Color {
        if isCorrect {
            return .green
        } else if isWrong {
            return .red
        } else {
            return .primary
        }
    }
    
    private var borderColor: Color {
        if isCorrect {
            return .green
        } else if isWrong {
            return .red
        } else if isSelected {
            return .blue
        } else {
            return .clear
        }
    }
}

#Preview {
    GameView(viewModel: GameViewModel())
} 