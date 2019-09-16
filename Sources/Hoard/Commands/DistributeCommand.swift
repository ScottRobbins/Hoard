import Yams
import Files
import Basic
import SPMUtility
import Foundation

struct DistributeCommand {
    
    let config: HoardConfig
    
    func run() throws {
        let tc = TerminalController(stream: stdoutStream)
        tc?.writeln("Running distribute...", inColor: .cyan)
        
        let bucketRepo: Folder
        let bucketRepoPath: String
        do {
            bucketRepo = try Folder(path: config.repoPath)
            bucketRepoPath = bucketRepo.path
            tc?.writeln("Successfully parsed config", inColor: .green)
        } catch let error {
            tc?.writeln(error.localizedDescription)
            tc?.writeln("Could not parse path to repo", inColor: .red, bold: true)
            exit(1)
        }
        
        let git = Git(repoLocation: bucketRepoPath)
        try git.pull()
        
        let bucketPath = try Folder(path: bucketRepoPath).subfolder(named: "bucket")
        for file in config.files {
            if let oldFile = try? File(path: file.path) {
                let newName = "\(oldFile.name)_hoardcopy"
                tc?.writeln("Renaming file at \(oldFile.path) to \(newName) avoid losing data because of accidental overwriting", inColor: .cyan)
                try oldFile.rename(to: newName, overwrite: true)
            }
            
            let bucketFile = try bucketPath.file(named: file.identifier)
            tc?.writeln("Copying file \(bucketFile.path) to \(file.path)", inColor: .cyan)
            _ = try bucketFile.copy(toPath: file.path, overwrite: true)
        }
        
        tc?.write("Successfully collected and updated files, ", inColor: .green)
    }
}
