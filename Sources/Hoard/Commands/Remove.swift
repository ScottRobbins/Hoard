import ArgumentParser
import Files
import Foundation
import Rainbow
import Yams

struct Remove: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Remove a file from your hoardconfig"
    )
    
    @Argument(
        help: .init(
            "The identifier of the file you want to remove"
        )
    )
    var identifier: String?
    
    func validate() throws {
        if let identifier = identifier {
            guard !identifier.isEmpty else {
                throw ValidationError("Invalid identifier")
            }
        }
    }
    
    func run() throws {
        let configLoader = ConfigurationLoader()
        let config = try configLoader.load()
        let configPath = configLoader.configPath
        
        let identifier: String
        if let _identifier = self.identifier {
            identifier = _identifier
        } else if !config.files.isEmpty {
            identifier = getIdentifier(config: config)
        } else {
            print("There are no files to remove".green)
            return
        }
            
        guard (config.files.contains { $0.identifier == identifier }) else {
            print(#"No file exists in \#(configPath) with the identifier "\#(identifier)""#.yellow)
            return
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
        print(#"Removing file with identifier: "\#(identifier)" from \#(configPath)"#.cyan)
        try fileString.write(toFile: fullConfigPath, atomically: true, encoding: .utf8)
        print(#"Successfully removed file with identifier: "\#(identifier)" from \#(configPath)"#.green)
    }
    
    private func getIdentifier(config: HoardConfig) -> String {
        print("Select the identifier you would like to remove:")
        for (i, file) in config.files.enumerated() {
            print("\(i).  \(file.identifier)")
        }
        
        while(true) {
            print("Identifier (0-\(config.files.count - 1)): ")
            let input = (readLine() ?? "").trimmingCharacters(in: .whitespaces)
            let index = Int(input)
            if let index = index, index >= 0 && index < config.files.count {
                return config.files[index].identifier
            } else {
                print("Did not select valid option".red)
            }
        }
    }
}
