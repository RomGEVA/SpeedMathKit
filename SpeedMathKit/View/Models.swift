import Foundation

enum GameMode: String, Codable, CaseIterable {
    case timeAttack = "Time Attack"
    case countChallenge = "Count Challenge"
    case dailyStreak = "Daily Streak"
    
    var description: String {
        switch self {
        case .timeAttack:
            return "Solve as many problems as possible in the time limit"
        case .countChallenge:
            return "Solve a set number of problems as fast as you can"
        case .dailyStreak:
            return "Daily challenge with increasing difficulty"
        }
    }
    
    var color: String {
        switch self {
        case .timeAttack: return "green"
        case .countChallenge: return "blue"
        case .dailyStreak: return "purple"
        }
    }
}

struct MathProblem: Identifiable, Codable {
    let id: UUID
    let question: String
    let correctAnswer: Int
    let options: [Int]
    let level: Int
    let rank: Rank
    
    init(level: Int, rank: Rank) {
        self.id = UUID()
        self.level = level
        self.rank = rank
        let (question, answer, options) = MathProblemGenerator.generateProblem(for: level, rank: rank)
        self.question = question
        self.correctAnswer = answer
        self.options = options
    }
    
    init(id: UUID, question: String, correctAnswer: Int, options: [Int], level: Int, rank: Rank) {
        self.id = id
        self.question = question
        self.correctAnswer = correctAnswer
        self.options = options
        self.level = level
        self.rank = rank
    }
}

struct GameResult: Identifiable, Codable {
    let id: UUID
    let mode: GameMode
    let score: Int
    let time: TimeInterval
    let date: Date
    let level: Int
    let problemsSolved: Int
    let accuracy: Double
    
    init(mode: GameMode, score: Int, time: TimeInterval, date: Date, level: Int, problemsSolved: Int, accuracy: Double) {
        self.id = UUID()
        self.mode = mode
        self.score = score
        self.time = time
        self.date = date
        self.level = level
        self.problemsSolved = problemsSolved
        self.accuracy = accuracy
    }
    
    init(id: UUID, mode: GameMode, score: Int, time: TimeInterval, date: Date, level: Int, problemsSolved: Int, accuracy: Double) {
        self.id = id
        self.mode = mode
        self.score = score
        self.time = time
        self.date = date
        self.level = level
        self.problemsSolved = problemsSolved
        self.accuracy = accuracy
    }
}

enum Rank: String, CaseIterable, Codable {
    case novice = "Novice"
    case learner = "Learner"
    case adept = "Adept"
    case skilled = "Skilled"
    case expert = "Expert"
    case master = "Master"
    case grandmaster = "Grandmaster"
    case legend = "Legend"
    case mythic = "Mythic"
    case immortal = "Immortal"

    var icon: String {
        switch self {
        case .novice: return "🥉"
        case .learner: return "🥈"
        case .adept: return "🥇"
        case .skilled: return "🏅"
        case .expert: return "🎖"
        case .master: return "🏆"
        case .grandmaster: return "👑"
        case .legend: return "🔥"
        case .mythic: return "🌟"
        case .immortal: return "💎"
        }
    }

    static func rank(forLevel level: Int) -> Rank {
        let index = min((level - 1) / 5, Rank.allCases.count - 1)
        return Rank.allCases[index]
    }
}

struct UserProfile: Codable {
    var name: String
    var currentLevel: Int
    var totalXP: Int
    var currentStreak: Int
    var bestStreak: Int
    var gamesPlayed: Int
    var avatar: String
    
    static let `default` = UserProfile(
        name: "Player",
        currentLevel: 1,
        totalXP: 0,
        currentStreak: 0,
        bestStreak: 0,
        gamesPlayed: 0,
        avatar: "person.circle.fill"
    )

    var currentRank: Rank {
        Rank.rank(forLevel: currentLevel)
    }
}

struct GameSettings: Codable {
    var soundEnabled: Bool
    var hapticEnabled: Bool
    var darkModeEnabled: Bool
    
    static let `default` = GameSettings(
        soundEnabled: true,
        hapticEnabled: true,
        darkModeEnabled: false
    )
} 