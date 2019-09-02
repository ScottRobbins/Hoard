import Foundation
import SPMUtility
import Basic
import Yams
import Files

struct DevEnvironmentProgram {

    func run() throws {
        let tc = TerminalController(stream: stdoutStream)
        let parser = ArgumentParser(commandName: nil,
                                    usage: "[--config <config_path>] <command>",
                                    overview: "Hoard will collect/distribute your files to/from a defined repo")
        let config = parser.add(option: "--config",
                                shortName: "-c",
                                kind: String.self,
                                usage: "A path to your configuration for the utility",
                                completion: .filename)
        let collectParser = parser.add(subparser: "collect",
                                       overview: "Collect your files and commit them to your repo where they are stored")
        let shouldPushOption = collectParser.add(option: "--push",
                                           shortName: "-p",
                                           kind: Bool.self,
                                           usage: "Should this command automatically push to your remote git repository?",
                                           completion: .values([
                                            (value: "true", description: "Automatically push to remote git repository"),
                                            (value: "false", description: "Do not automatically push to remote git repository")
                                           ]))
        parser.add(subparser: "distribute", overview: "distribute")

        let args = Array(CommandLine.arguments.dropFirst())
        let result: ArgumentParser.Result
        do {
            result = try parser.parse(args)
        } catch let error {
            tc?.write(error.localizedDescription)
            tc?.writeln("Could not parse arguments", inColor: .red, bold: true)
            tc?.writeln("")
            parser.printUsage(on: stdoutStream)
            exit(1)
        }

        guard let subparser = result.subparser(parser) else {
            tc?.writeln("Could not parse arguments", inColor: .red, bold: true)
            tc?.writeln("")
            parser.printUsage(on: stdoutStream)
            exit(1)
        }

        let errorMessage: String
        let configFilePath: String
        if let _configFilePath = result.get(config) {
            errorMessage = "Could not parse config file at \(_configFilePath)"
            configFilePath = _configFilePath
        } else {
            errorMessage = "Could not find config file at ~/.hoardconfig and none was specified"
            configFilePath = "~/.hoardconfig"
        }

        let hoardConfig: HoardConfig
        do {
            let configYamlString = try File(path: configFilePath).readAsString()
            let decoder = YAMLDecoder()
            hoardConfig = try decoder.decode(HoardConfig.self, from: configYamlString)
        } catch let error {
            tc?.writeln(error.localizedDescription)
            tc?.writeln(errorMessage, inColor: .red, bold: true)
            exit(1)
        }

        switch subparser {
        case "collect":
            try CollectCommand(config: hoardConfig,
                               shouldPush: result.get(shouldPushOption)).run()
        case "distribute":
            try DistributeCommand(config: hoardConfig).run()
        default:
            tc?.writeln("Internal Error, could not find subparser for known command", inColor: .red, bold: true)
            exit(1)
        }
    }
}

do {
    try DevEnvironmentProgram().run()
} catch let error {
    let tc = TerminalController(stream: stdoutStream)
    tc?.writeln(error.localizedDescription)
    tc?.writeln("Error running command", inColor: .red, bold: true)
    exit(1)
}

