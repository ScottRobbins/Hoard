import ArgumentParser
import Files
import Foundation
import Rainbow
import Yams

struct Add: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add a file to your hoardconfig"
    )

    @Argument(
        help: .init(
            "The path to the file you want to add"
        )
    )
    var filePath: String
    
    func validate() throws {
        guard !filePath.isEmpty else {
            throw ValidationError("Invalid file path")
        }
    }

    func run() throws {
        let configLoader = ConfigurationLoader()
        let config = try configLoader.load()
        let configPath = configLoader.configPath
        
        let file: File
        do {
            file = try File(path: filePath)
        } catch {
            throw ValidationError("Could not find file at path \(filePath)".red)
        }

        print("Enter identifier for file (press enter to use filename as identifier): ")
        let input = (readLine() ?? "").trimmingCharacters(in: .whitespaces)
        let identifier = input.isEmpty ? file.name : input

        let newFiles = config
            .files
            .appending(.init(identifier: identifier,
                             path: file.path))
            .sorted { $0.identifier.lowercased() < $1.identifier.lowercased() }
        let newConfig = HoardConfig(repoPath: config.repoPath,
                                    files: newFiles)
        let encoder = YAMLEncoder()
        let fileString = try encoder.encode(newConfig)

        let fullConfigPath = try File(path: configPath).path
        print("Adding file to \(configPath)".cyan)
        try fileString.write(toFile: fullConfigPath, atomically: true, encoding: .utf8)
        print("Successfully added \(identifier) to \(configPath)".green)
    }
}

extension Array {
    func appending(_ newElement: Element) -> [Element] {
        return self + [newElement]
    }
}
