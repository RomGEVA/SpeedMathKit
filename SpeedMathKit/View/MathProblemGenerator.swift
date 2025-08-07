import Foundation

struct MathProblemGenerator {
    
    static func generateProblem(for level: Int, rank: Rank) -> (question: String, answer: Int, options: [Int]) {
        let (question, answer) = generateQuestionAndAnswer(for: level, rank: rank)
        let options = generateOptions(correctAnswer: answer, level: level, rank: rank)
        return (question, answer, options)
    }
    
    private static func generateQuestionAndAnswer(for level: Int, rank: Rank) -> (question: String, answer: Int) {
        switch rank {
        case .novice, .learner:
            return generateBasicArithmetic(range: 1...12)
        case .adept, .skilled:
            return generateMultiplicationDivision(range: 2...15)
        case .expert, .master:
            return generateMixedOperations(range: -20...30)
        case .grandmaster, .legend:
            return generateAdvancedProblems()
        case .mythic, .immortal:
            return generateHardcoreProblems()
        }
    }
    
    private static func generateBasicArithmetic(range: ClosedRange<Int>) -> (question: String, answer: Int) {
        let a = Int.random(in: range)
        let b = Int.random(in: range)
        let operation = Bool.random() ? "+" : "-"
        
        let answer: Int
        let question: String
        
        if operation == "+" {
            answer = a + b
            question = "\(a) + \(b) = ?"
        } else {
            // Ensure positive result for subtraction
            let larger = max(a, b)
            let smaller = min(a, b)
            answer = larger - smaller
            question = "\(larger) - \(smaller) = ?"
        }
        
        return (question, answer)
    }
    
    private static func generateMultiplicationDivision(range: ClosedRange<Int>) -> (question: String, answer: Int) {
        let operation = Bool.random() ? "*" : "/"
        
        if operation == "*" {
            let a = Int.random(in: range)
            let b = Int.random(in: range)
            let answer = a * b
            let question = "\(a) × \(b) = ?"
            return (question, answer)
        } else {
            let b = Int.random(in: range)
            let answer = Int.random(in: range)
            let a = b * answer
            let question = "\(a) ÷ \(b) = ?"
            return (question, answer)
        }
    }
    
    private static func generateMixedOperations(range: ClosedRange<Int>) -> (question: String, answer: Int) {
        let operations = ["+", "-", "*"]
        let operation = operations.randomElement()!
        
        switch operation {
        case "+":
            let a = Int.random(in: range)
            let b = Int.random(in: range)
            let c = Int.random(in: range)
            let answer = a + b + c
            let question = "\(a) + \(b) + \(c) = ?"
            return (question, answer)
        case "-":
            let a = Int.random(in: range)
            let b = Int.random(in: range)
            let c = Int.random(in: range)
            let answer = a - b - c
            let question = "\(a) - \(b) - \(c) = ?"
            return (question, answer)
        case "*":
            let a = Int.random(in: range)
            let b = Int.random(in: range)
            let answer = a * b
            let question = "\(a) × \(b) = ?"
            return (question, answer)
        default:
            return generateBasicArithmetic(range: range)
        }
    }
    
    private static func generateAdvancedProblems() -> (question: String, answer: Int) {
        let problemTypes = ["fraction", "equation", "sequence"]
        let type = problemTypes.randomElement()!
        
        switch type {
        case "fraction":
            let numerator = Int.random(in: 1...30)
            let denominator = Int.random(in: 2...12)
            let multiplier = Int.random(in: 2...8)
            let answer = (numerator * multiplier) / denominator
            let question = "(\(numerator)/\(denominator)) × \(multiplier) = ?"
            return (question, answer)
        case "equation":
            let x = Int.random(in: 1...20)
            let a = Int.random(in: 2...10)
            let b = Int.random(in: 1...20)
            let answer = x
            let question = "\(a)x + \(b) = \(a * x + b), x = ?"
            return (question, answer)
        case "sequence":
            let start = Int.random(in: 1...20)
            let difference = Int.random(in: 2...10)
            let position = Int.random(in: 3...8)
            let answer = start + (difference * (position - 1))
            let question = "Sequence: \(start), \(start + difference), \(start + 2 * difference), ..., position \(position) = ?"
            return (question, answer)
        default:
            return generateBasicArithmetic(range: 1...20)
        }
    }
    
    private static func generateHardcoreProblems() -> (question: String, answer: Int) {
        let type = Int.random(in: 0...2)
        switch type {
        case 0:
            let a = Int.random(in: -50...100)
            let b = Int.random(in: -50...100)
            let c = Int.random(in: -50...100)
            let d = Int.random(in: -50...100)
            let answer = a + b * c - d
            let question = "\(a) + \(b) × \(c) - \(d) = ?"
            return (question, answer)
        case 1:
            let numerator = Int.random(in: 10...100)
            let denominator = Int.random(in: 2...20)
            let multiplier = Int.random(in: 2...12)
            let answer = (numerator * multiplier) / denominator
            let question = "(\(numerator)/\(denominator)) × \(multiplier) = ?"
            return (question, answer)
        case 2:
            let x = Int.random(in: 1...30)
            let a = Int.random(in: 2...15)
            let b = Int.random(in: 1...30)
            let answer = x
            let question = "\(a)x + \(b) = \(a * x + b), x = ?"
            return (question, answer)
        default:
            return generateAdvancedProblems()
        }
    }
    
    private static func generateOptions(correctAnswer: Int, level: Int, rank: Rank) -> [Int] {
        var options = [correctAnswer]
        
        // Generate distractors based on level complexity
        let distractorCount = 3
        let range = max(2, level * 2 + Rank.allCases.firstIndex(of: rank)!)
        
        for _ in 0..<distractorCount {
            var distractor: Int
            
            repeat {
                // Create distractors that are close to the correct answer
                let variation = Int.random(in: -range...range)
                distractor = correctAnswer + variation
                
                // Ensure distractors are reasonable
                if distractor < 0 && level < 21 {
                    distractor = abs(distractor)
                }
                
                // Add some completely wrong answers for higher levels
                if Rank.allCases.firstIndex(of: rank)! > 4 && Bool.random() {
                    distractor = Int.random(in: -100...100)
                }
                
            } while options.contains(distractor) || distractor == correctAnswer
            
            options.append(distractor)
        }
        
        return options.shuffled()
    }
} 
