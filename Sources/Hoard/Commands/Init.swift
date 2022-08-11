import ArgumentParser
import Files
import Foundation
import Rainbow
import Yams

struct Init: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Add .hoardconfig to home directory"
    )
    
    func run() throws {
        print("Running init...".cyan)
        
        let fileManager = FileManager.default
        let currentDirectoryPath = FileManager.default.currentDirectoryPath
        
        guard try Folder(path: currentDirectoryPath).containsSubfolder(named: ".git") else {
            throw HoardError("Cannot verify this as a git repo. Run init command from the base directory of your repo".red)
        }
        
        let hoardConfig = HoardConfig(repoPath: currentDirectoryPath,
                                      files: [.init(identifier: "hoardconfig.yml", path: "~/.hoardconfig")])
        let encoder = YAMLEncoder()
        let fileString = try encoder.encode(hoardConfig)
        let fileLocation = fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".hoardconfig").path
        
        guard try Folder(path: fileManager.homeDirectoryForCurrentUser.path)
            .containsFile(named: ".hoardconfig") == false else
        {
            throw HoardError("~/.hoardconfig already exists".red)
        }
        
        print("Writing to file at \(fileLocation)".cyan)
        try fileString.write(toFile: fileLocation, atomically: true, encoding: .utf8)
        print("Successfully created config at \(fileLocation)".green)
    }
}
