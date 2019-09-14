import Yams
import Files
import Basic
import SPMUtility
import Foundation

struct RemoveCommand {

    let config: HoardConfig
    let identifier: String?
    let configPath: String
    private let tc = TerminalController(stream: stdoutStream)

    func run() throws {
        let identifier = self.identifier ?? getIdentifier()

        guard (config.files.contains { $0.identifier == identifier }) else {
            tc?.writeln(#"No file exists in \#(configPath) with the identifier "\#(identifier)""#, inColor: .green)
            exit(0)
        }

        let newFiles = config
            .files
            .drop { $0.identifier == identifier }
            .sorted { $0.identifier.lowercased() < $1.identifier.lowercased() }
        let newConfig = HoardConfig(repoPath: config.repoPath,
                                    files: newFiles)
        let encoder = YAMLEncoder()
        let fileString = try encoder.encode(newConfig)

        let fullConfigPath = try File(path: configPath).path
        tc?.writeln(#"Removing file with identifier: "\#(identifier)" from \#(configPath)"#, inColor: .cyan)
        try fileString.write(toFile: fullConfigPath, atomically: true, encoding: .utf8)
        tc?.writeln(#"Successfully removed file with identifier: "\#(identifier)" from \#(configPath)"#,
            inColor: .green)
    }

    private func getIdentifier() -> String {
        guard !config.files.isEmpty else {
            tc?.writeln("There are no files to remove", inColor: .green)
            exit(0)
        }

        tc?.writeln("Select the identifier you would like to remove:")
        for (i, file) in config.files.enumerated() {
            tc?.writeln("\(i).  \(file.identifier)")
        }

        while(true) {
            tc?.write("Identifier (0-\(config.files.count - 1)): ")
            let input = (readLine() ?? "").trimmingCharacters(in: .whitespaces)
            let index = Int(input)
            if let index = index, index >= 0 && index < config.files.count {
                return config.files[index].identifier
            } else {
                tc?.writeln("Did not select valid option", inColor: .red)
            }
        }
    }
}
