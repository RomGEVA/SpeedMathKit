import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: GameMode? = nil
    
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
            ScrollView {
                VStack(spacing: 20) {
                    performanceOverview
                    performanceChart
                    gameHistory
                    Spacer(minLength: 0)
                }
                .padding()
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private var performanceOverview: some View {
        VStack(spacing: 16) {
            Text("Performance Overview")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                OverviewCard(
                    title: "Total Games",
                    value: "\(viewModel.userProfile.gamesPlayed)",
                    icon: "gamecontroller.fill",
                    color: .blue
                )
                
                OverviewCard(
                    title: "Best Streak",
                    value: "\(viewModel.userProfile.bestStreak)",
                    icon: "flame.fill",
                    color: .orange
                )
                
                OverviewCard(
                    title: "Current Level",
                    value: "\(viewModel.userProfile.currentLevel)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                OverviewCard(
                    title: "Total XP",
                    value: "\(viewModel.userProfile.totalXP)",
                    icon: "bolt.fill",
                    color: .purple
                )
            }
        }
    }
    
    private var performanceChart: some View {
        VStack(spacing: 16) {
            Text("Score Progress")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if #available(iOS 16.0, *) {
                Chart(filteredHistory) { result in
                    LineMark(
                        x: .value("Date", result.date),
                        y: .value("Score", result.score)
                    )
                    .foregroundStyle(Color.blue)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Date", result.date),
                        y: .value("Score", result.score)
                    )
                    .foregroundStyle(Color.blue.opacity(0.1))
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.day().month())
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
            } else {
                // Fallback for iOS 15
                Text("Charts available in iOS 16+")
                    .foregroundColor(.secondary)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var gameHistory: some View {
        VStack(spacing: 16) {
            Text("Recent Games")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if filteredHistory.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No games played yet")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredHistory.prefix(10)) { result in
                            GameHistoryRow(result: result)
                        }
                    }
                }
            }
        }
    }
    
    private var filteredHistory: [GameResult] {
        if let selectedMode = selectedMode {
            return viewModel.gameHistory.filter { $0.mode == selectedMode }
        } else {
            return viewModel.gameHistory
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.blue : Color.clear
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.secondary.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct OverviewCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Text(emojiIcon)
                .font(.system(size: 32))
                .frame(height: 36)
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
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
    
    private var emojiIcon: String {
        switch icon {
        case "gamecontroller.fill": return "🎮"
        case "flame.fill": return "🔥"
        case "star.fill": return "⭐️"
        case "bolt.fill": return "⚡️"
        default: return "❓"
        }
    }
}

struct GameHistoryRow: View {
    let result: GameResult
    
    var body: some View {
        HStack(spacing: 16) {
            // Mode icon
            Image(systemName: modeIcon)
                .font(.system(size: 24))
                .foregroundColor(modeColor)
                .frame(width: 40, height: 40)
                .background(modeColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.mode.rawValue)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                
                Text(dateString)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(result.score)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Level \(result.level)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var modeIcon: String {
        switch result.mode {
        case .timeAttack: return "timer"
        case .countChallenge: return "number.circle.fill"
        case .dailyStreak: return "flame.fill"
        }
    }
    
    private var modeColor: Color {
        switch result.mode {
        case .timeAttack: return .green
        case .countChallenge: return .blue
        case .dailyStreak: return .purple
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: result.date)
    }
}

#Preview {
    StatsView(viewModel: GameViewModel())
} 