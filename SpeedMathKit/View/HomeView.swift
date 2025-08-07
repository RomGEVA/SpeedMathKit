import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var showSettings = false
    @State private var showStats = false
    @State private var animateGradient = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated background gradient
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.3),
                        Color.purple.opacity(0.3),
                        Color.orange.opacity(0.3)
                    ],
                    startPoint: animateGradient ? .topLeading : .bottomTrailing,
                    endPoint: animateGradient ? .bottomTrailing : .topLeading
                )
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header with profile
                        headerSection
                        
                        // Game modes
                        gameModesSection
                        
                        // Stats preview
                        statsPreviewSection
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showStats) {
            StatsView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $viewModel.isGameActive) {
            GameView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $viewModel.showGameOver) {
            GameOverView(viewModel: viewModel)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("SpeedMath")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Train your mental math skills!")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            
            // User profile card
            HStack(spacing: 16) {
                Text(viewModel.userProfile.avatar)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.userProfile.name)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    HStack(spacing: 8) {
                        Text("Level \(viewModel.userProfile.currentLevel)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        HStack(spacing: 4) {
                            Text(viewModel.userProfile.currentRank.icon)
                            Text(viewModel.userProfile.currentRank.rawValue)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.08))
                        .clipShape(Capsule())
                    }
                    // XP Progress bar
                    ProgressView(value: Double(viewModel.userProfile.totalXP % 100), total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(height: 4)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(viewModel.userProfile.currentStreak)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    
                    Text("Streak")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var gameModesSection: some View {
        VStack(spacing: 16) {
            Text("Choose Game Mode")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(GameMode.allCases, id: \.self) { mode in
                    GameModeCard(mode: mode) {
                        viewModel.startGame(mode: mode)
                    }
                }
            }
        }
    }
    
    private var statsPreviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Performance")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                
                Spacer()
                
                Button("View All") {
                    showStats = true
                }
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.blue)
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Best Score",
                    value: "\(viewModel.getBestScore(for: .timeAttack))",
                    icon: "trophy.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Games Played",
                    value: "\(viewModel.userProfile.gamesPlayed)",
                    icon: "gamecontroller.fill",
                    color: .green
                )
            }
        }
    }
}

struct GameModeCard: View {
    let mode: GameMode
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                
                Text(mode.rawValue)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(mode.description)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var iconName: String {
        switch mode {
        case .timeAttack: return "timer"
        case .countChallenge: return "number.circle.fill"
        case .dailyStreak: return "flame.fill"
        }
    }
    
    private var gradientColors: [Color] {
        switch mode {
        case .timeAttack:
            return [.green, .green.opacity(0.7)]
        case .countChallenge:
            return [.blue, .blue.opacity(0.7)]
        case .dailyStreak:
            return [.purple, .purple.opacity(0.7)]
        }
    }
}

struct StatCard: View {
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
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    HomeView()
} 