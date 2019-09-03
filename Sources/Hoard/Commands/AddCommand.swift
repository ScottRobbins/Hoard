import Yams
import Files
import Basic
import SPMUtility
import Foundation

struct AddCommand {

    let config: HoardConfig
    let filePath: String
    let configPath: String

    func run() throws {
        let tc = TerminalController(stream: stdoutStream)
        let file: File
        do {
            file = try File(path: filePath)
        } catch {
            tc?.writeln("Could not find file at path \(filePath)", inColor: .red)
            exit(1)
        }

        tc?.write("Enter identifier for file (press enter to use filename as identifier): ")
        let input = (readLine() ?? "").trimmingCharacters(in: .whitespaces)
        let identifier = input.isEmpty ? file.name : input

        let newFiles = config
            .files
            .appending(.init(identifier: identifier,
                             path: file.path))
            .sorted { $0.identifier < $1.identifier }
        let newConfig = HoardConfig(repoPath: config.repoPath,
                                    files: newFiles)
        let encoder = YAMLEncoder()
        let fileString = try encoder.encode(newConfig)

        let fullConfigPath = try File(path: configPath).path
        tc?.writeln("Adding file to \(configPath)", inColor: .cyan)
        try fileString.write(toFile: fullConfigPath, atomically: true, encoding: .utf8)
        tc?.writeln("Successfully added \(identifier) to \(configPath)",
            inColor: .green)
    }
}

extension Array {
    func appending(_ newElement: Element) -> [Element] {
        return self + [newElement]
    }
}
