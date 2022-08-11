import ArgumentParser
import Files
import Foundation
import Rainbow
import Yams

struct Distribute: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "distribute",
        abstract: "Distribute files from your repo to the file's locations specified in your config"
    )
    
    func run() throws {
        let config = try ConfigurationLoader().load()
        
        print("Running distribute...".cyan)
        
        let bucketRepo: Folder
        let bucketRepoPath: String
        do {
            bucketRepo = try Folder(path: config.repoPath)
            bucketRepoPath = bucketRepo.path
            print("Successfully parsed config".green)
        } catch let error {
            print(error.localizedDescription)
            throw HoardError("Could not parse path to repo".red.bold)
        }
        
        let git = Git(repoLocation: bucketRepoPath)
        try git.pull()
        
        let bucketPath = try Folder(path: bucketRepoPath).subfolder(named: "bucket")
        for file in config.files {
            if let oldFile = try? File(path: file.path) {
                let newName = "\(oldFile.name)_hoardcopy"
                print("Renaming file at \(oldFile.path) to \(newName) avoid losing data because of accidental overwriting".cyan)
                try oldFile.rename(to: newName, overwrite: true)
            }
            
            let bucketFile = try bucketPath.file(named: file.identifier)
            print("Copying file \(bucketFile.path) to \(file.path)".cyan)
            _ = try bucketFile.copy(toPath: file.path, overwrite: true)
        }
        
        print("Successfully collected and updated files, ".green)
    }
}
