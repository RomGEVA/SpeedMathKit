import Foundation
import Combine
import SwiftUI

@MainActor
class GameViewModel: ObservableObject {
    @Published var currentProblem: MathProblem?
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var isGameActive = false
    @Published var gameMode: GameMode = .timeAttack
    @Published var selectedAnswer: Int?
    @Published var showFeedback = false
    @Published var isCorrect = false
    @Published var problemsSolved = 0
    @Published var currentStreak = 0
    @Published var showGameOver = false
    @Published var gameResult: GameResult?
    
    // Game settings
    @Published var timeLimit: TimeInterval = 30
    @Published var targetProblems: Int = 10
    @Published var currentLevel: Int = 1
    
    // User data
    @Published var userProfile: UserProfile = .default
    @Published var gameHistory: [GameResult] = []
    @Published var settings: GameSettings = .default
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadUserData()
        loadGameHistory()
        loadSettings()
    }
    
    // MARK: - Game Control
    
    func startGame(mode: GameMode) {
        gameMode = mode
        score = 0
        problemsSolved = 0
        currentStreak = 0
        selectedAnswer = nil
        showFeedback = false
        showGameOver = false
        
        // Set game parameters based on mode
        switch mode {
        case .timeAttack:
            timeLimit = 30
            timeRemaining = timeLimit
        case .countChallenge:
            targetProblems = 10
            timeRemaining = 0
        case .dailyStreak:
            timeLimit = 60
            timeRemaining = timeLimit
        }
        
        isGameActive = true
        generateNewProblem()
        startTimer()
    }
    
    func submitAnswer(_ answer: Int) {
        guard isGameActive, let problem = currentProblem else { return }
        
        selectedAnswer = answer
        let correct = answer == problem.correctAnswer
        
        if correct {
            handleCorrectAnswer()
        } else {
            handleIncorrectAnswer()
        }
        
        showFeedback = true
        isCorrect = correct
        
        // Haptic feedback
        if settings.hapticEnabled {
            let impactFeedback = UIImpactFeedbackGenerator(style: correct ? .medium : .heavy)
            impactFeedback.impactOccurred()
        }
        
        // Auto-advance after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.nextProblem()
        }
    }
    
    private func handleCorrectAnswer() {
        let basePoints = 10
        let streakBonus = currentStreak >= 5 ? 2 : 0
        let levelBonus = currentLevel * 2
        
        let points = basePoints + streakBonus + levelBonus
        score += points
        problemsSolved += 1
        currentStreak += 1
        
        // Level up logic
        if problemsSolved % 3 == 0 && currentStreak >= 3 {
            levelUp()
        }
    }
    
    private func handleIncorrectAnswer() {
        currentStreak = 0
        // No points deducted, just streak reset
    }
    
    private func nextProblem() {
        showFeedback = false
        selectedAnswer = nil
        
        if gameMode == .countChallenge && problemsSolved >= targetProblems {
            endGame()
        } else {
            generateNewProblem()
        }
    }
    
    private func generateNewProblem() {
        currentProblem = MathProblem(level: currentLevel, rank: userProfile.currentRank)
    }
    
    private func levelUp() {
        currentLevel += 1
        userProfile.currentLevel = currentLevel
        userProfile.totalXP += 100
        
        // Animate level up
        withAnimation(.spring()) {
            // Level up animation would go here
        }
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    @MainActor
    private func tick() {
        guard isGameActive else { return }
        if gameMode == .timeAttack || gameMode == .dailyStreak {
            timeRemaining -= 0.1
            if timeRemaining <= 0 {
                endGame()
            }
        }
    }
    
    private func endGame() {
        isGameActive = false
        timer?.invalidate()
        timer = nil
        
        let accuracy = problemsSolved > 0 ? Double(problemsSolved) / Double(problemsSolved + max(0, problemsSolved - currentStreak)) : 0.0
        
        let result = GameResult(
            mode: gameMode,
            score: score,
            time: gameMode == .timeAttack ? timeLimit - timeRemaining : 0,
            date: Date(),
            level: currentLevel,
            problemsSolved: problemsSolved,
            accuracy: accuracy
        )
        
        gameResult = result
        saveGameResult(result)
        updateUserProfile(with: result)
        
        showGameOver = true
    }
    
    func handleGameOverDone() {
        isGameActive = false
        showGameOver = false
    }
    
    // MARK: - Data Persistence
    
    private func saveGameResult(_ result: GameResult) {
        gameHistory.append(result)
        
        // Keep only top 10 results per mode
        let modeResults = gameHistory.filter { $0.mode == result.mode }
        if modeResults.count > 10 {
            let sortedResults = modeResults.sorted { $0.score > $1.score }
            let topResults = Array(sortedResults.prefix(10))
            
            // Remove old results for this mode
            gameHistory.removeAll { $0.mode == result.mode }
            gameHistory.append(contentsOf: topResults)
        }
        
        saveGameHistory()
    }
    
    private func updateUserProfile(with result: GameResult) {
        userProfile.gamesPlayed += 1
        userProfile.totalXP += result.score
        
        // Update streak
        if result.score > 0 {
            userProfile.currentStreak += 1
            if userProfile.currentStreak > userProfile.bestStreak {
                userProfile.bestStreak = userProfile.currentStreak
            }
        } else {
            userProfile.currentStreak = 0
        }
        
        saveUserData()
    }
    
    private func saveUserData() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }
    
    private func loadUserData() {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = profile
            currentLevel = profile.currentLevel
        }
    }
    
    private func saveGameHistory() {
        if let encoded = try? JSONEncoder().encode(gameHistory) {
            UserDefaults.standard.set(encoded, forKey: "gameHistory")
        }
    }
    
    private func loadGameHistory() {
        if let data = UserDefaults.standard.data(forKey: "gameHistory"),
           let history = try? JSONDecoder().decode([GameResult].self, from: data) {
            gameHistory = history
        }
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "gameSettings")
        }
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "gameSettings"),
           let gameSettings = try? JSONDecoder().decode(GameSettings.self, from: data) {
            settings = gameSettings
        }
    }
    
    // MARK: - Public Methods
    
    func resetData() {
        userProfile = .default
        gameHistory = []
        currentLevel = 1
        saveUserData()
        saveGameHistory()
    }
    
    func updateSettings(_ newSettings: GameSettings) {
        settings = newSettings
        saveSettings()
    }
    
    func getBestScore(for mode: GameMode) -> Int {
        return gameHistory
            .filter { $0.mode == mode }
            .max { $0.score < $1.score }?.score ?? 0
    }
    
    func getAverageScore(for mode: GameMode) -> Double {
        let modeResults = gameHistory.filter { $0.mode == mode }
        guard !modeResults.isEmpty else { return 0 }
        
        let totalScore = modeResults.reduce(0) { $0 + $1.score }
        return Double(totalScore) / Double(modeResults.count)
    }
} 