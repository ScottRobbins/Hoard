import ArgumentParser
import Files
import Foundation
import Rainbow
import Yams

struct Collect: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "collect",
        abstract: "Collect your files and commit them to your repo where they are stored"
    )
    
    @Flag(
        name: [.customLong("push"), .customShort("p")],
        help: "Should this command automatically push to your remote git repository?"
    )
    var shouldPush: Bool = true
    
    func run() throws {
        let config = try ConfigurationLoader().load()
        
        print("Running collect...".cyan)
        
        let destinationRepo: Folder
        let destinationRepoPath: String
        do {
            destinationRepo = try Folder(path: config.repoPath)
            destinationRepoPath = destinationRepo.path
            print("Successfully parsed config".green)
        } catch let error {
            print(error.localizedDescription)
            throw HoardError("Could not parse path to destination repo".red.bold)
        }
        
        let git = Git(repoLocation: destinationRepoPath)
        print("Creating bucket if needed".cyan)
        let destinationFolder = try Folder(path: destinationRepoPath).createSubfolderIfNeeded(withName: "bucket")
        for file in config.files {
            do {
                print("Copying \(file.path) to \(destinationFolder.path)".cyan)
                let copiedFile = try File(path: file.path).copy(to: destinationFolder, overwrite: true)
                print("Renaming file to \(file.identifier)".cyan)
                try copiedFile.rename(to: file.identifier, overwrite: true)
                try git.add(copiedFile.path(relativeTo: destinationRepo))
            } catch let error {
                print(error.localizedDescription)
                throw HoardError("Could not copy \(file.path) to \(config.repoPath)/bucket".red.bold)
            }
        }
        
        try? git.commit("-m", "Updated Files")
        
        if shouldPush {
            try? git.push()
        }
        
        print("Successfully collected and updated files, ".green)
        print("validate there were no git errors above".green.bold)
    }
}
