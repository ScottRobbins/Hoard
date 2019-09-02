import Yams
import Files
import Basic
import SPMUtility
import Foundation

struct CollectCommand {

    let config: HoardConfig
    let shouldPush: Bool

    init(config: HoardConfig, shouldPush: Bool?) {
        self.config = config
        self.shouldPush = shouldPush ?? true
    }

    func run() throws {
        let tc = TerminalController(stream: stdoutStream)
        tc?.writeln("Running collect...", inColor: .cyan)

        let destinationRepo: Folder
        let destinationRepoPath: String
        do {
            destinationRepo = try Folder(path: config.repoPath)
            destinationRepoPath = destinationRepo.path
            tc?.writeln("Successfully parsed config", inColor: .green)
        } catch let error {
            tc?.writeln(error.localizedDescription)
            tc?.writeln("Could not parse path to destination repo", inColor: .red, bold: true)
            exit(1)
        }

        let git = Git(repoLocation: destinationRepoPath)
        tc?.writeln("Creating bucket if needed", inColor: .cyan)
        let destinationFolder = try Folder(path: destinationRepoPath).createSubfolderIfNeeded(withName: "bucket")
        for file in config.files {
            do {
                tc?.writeln("Copying \(file.path) to \(destinationFolder.path)", inColor: .cyan)
                let copiedFile = try File(path: file.path).copy(to: destinationFolder, overwrite: true)
                tc?.writeln("Renaming file to \(file.identifier)", inColor: .cyan)
                try copiedFile.rename(to: file.identifier, overwrite: true)
                try git.add(copiedFile.path(relativeTo: destinationRepo))
            } catch let error {
                tc?.writeln(error.localizedDescription)
                tc?.writeln("Could not copy \(file.path) to \(config.repoPath)/bucket", inColor: .red, bold: true)
                exit(1)
            }
        }

        try? git.commit("-m", "Updated Files")

        if shouldPush {
            try? git.push()
        }

        tc?.write("Successfully collected and updated files, ", inColor: .green)
        tc?.writeln("validate there were no git errors above", inColor: .green, bold: true)
    }
}
