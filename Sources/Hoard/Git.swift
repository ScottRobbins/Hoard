import Basic
import Foundation

struct GitError: Error { }

struct Git {
    let repoLocation: String
    let tc = TerminalController(stream: stdoutStream)
    
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
        tc?.writeln(fullArgs.map { $0.replacingOccurrences(of: " ", with: "\\ ") }.joined(separator: " "),
                    inColor: .cyan)
        let result = shell(fullArgs)
        if result == 0 {
            return
        } else {
            tc?.writeln("Git command returned nonzero exit code, this may not be an error", inColor: .yellow)
            throw GitError()
        }
    }
}
