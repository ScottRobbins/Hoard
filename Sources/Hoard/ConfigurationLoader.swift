import Files
import Yams

struct ConfigurationLoader {
    let configPath = "~/.hoardconfig"

    func load() throws -> HoardConfig {
        do {
            let configYamlString = try File(path: configPath).readAsString()
            let decoder = YAMLDecoder()
            return try decoder.decode(HoardConfig.self, from: configYamlString)
        } catch let error {
            print(error.localizedDescription)
            throw HoardError("Could not find config file at \(configPath)".red.bold)
        }
    }
}
