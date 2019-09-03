import Yams
import Files
import Basic
import SPMUtility
import Foundation

struct InitCommand {

    func run() throws {
        let tc = TerminalController(stream: stdoutStream)
        tc?.writeln("Running init...", inColor: .cyan)

        let fileManager = FileManager.default
        let currentDirectoryPath = FileManager.default.currentDirectoryPath
        let hoardConfig = HoardConfig(repoPath: currentDirectoryPath,
                                      files: [.init(identifier: "hoardconfig.yml", path: "~/.hoardconfig")])
        let encoder = YAMLEncoder()
        let fileString = try encoder.encode(hoardConfig)
        let fileLocation = fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".hoardconfig").path

        tc?.writeln("Writing to file at \(fileLocation)", inColor: .cyan)
        try fileString.write(toFile: fileLocation, atomically: true, encoding: .utf8)
        tc?.writeln("Successfully created config at \(fileLocation)", inColor: .green)
    }
}
