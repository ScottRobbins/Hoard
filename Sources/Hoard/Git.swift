import Foundation

struct GitError: Error { }

struct Git {
    let repoLocation: String
    
    func add(_ args: String...) throws {
        try run(["add"] + args)
    }
    
    func commit(_ args: String...) throws {
        try run(["commit"] + args)
    }
    
    func push(_ args: String...) throws {
        try run(["push"] + args)
    }
    
    func pull(_ args: String...) throws {
        try run(["pull"] + args)
    }
    
    private func run(_ args: [String]) throws {
        let fullArgs = ["git", "-C", repoLocation] + args
        print(fullArgs.map { $0.replacingOccurrences(of: " ", with: "\\ ") }.joined(separator: " ").cyan)
        let result = shell(fullArgs)
        if result == 0 {
            return
        } else {
            print("Git command returned nonzero exit code, this may not be an error".yellow)
            throw GitError()
        }
    }
}
