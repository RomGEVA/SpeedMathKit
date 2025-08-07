import SwiftUI

struct GameOverView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showConfetti = false
    
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
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Text("Game Over!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(viewModel.gameMode.rawValue)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                // Results card
                resultsCard
                
                // Action buttons
                actionButtons
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            showConfetti = true
        }
    }
    
    private var resultsCard: some View {
        VStack(spacing: 24) {
            // Score display
            VStack(spacing: 8) {
                Text("Final Score")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("\(viewModel.score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            // Stats grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                StatItem(
                    title: "Problems Solved",
                    value: "\(viewModel.problemsSolved)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatItem(
                    title: "Accuracy",
                    value: "\(Int(viewModel.gameResult?.accuracy ?? 0 * 100))%",
                    icon: "target",
                    color: .blue
                )
                
                StatItem(
                    title: "Time",
                    value: timeString,
                    icon: "clock.fill",
                    color: .orange
                )
                
                StatItem(
                    title: "Level",
                    value: "\(viewModel.currentLevel)",
                    icon: "star.fill",
                    color: .yellow
                )
            }
            
            // Performance comparison
            if let result = viewModel.gameResult {
                VStack(spacing: 8) {
                    let bestScore = viewModel.getBestScore(for: viewModel.gameMode)
                    let isNewRecord = result.score >= bestScore && bestScore > 0
                    
                    if isNewRecord {
                        HStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                            
                            Text("New Record!")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.yellow)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Text("Best Score: \(bestScore)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: {
                viewModel.showGameOver = false
                viewModel.startGame(mode: viewModel.gameMode)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Play Again")
                }
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            Button(action: {
                viewModel.handleGameOverDone()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                    Text("Done")
                }
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private var timeString: String {
        guard let result = viewModel.gameResult else { return "0:00" }
        
        if viewModel.gameMode == .timeAttack || viewModel.gameMode == .dailyStreak {
            let minutes = Int(result.time) / 60
            let seconds = Int(result.time) % 60
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return "N/A"
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    GameOverView(viewModel: GameViewModel())
} 