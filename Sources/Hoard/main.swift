import Foundation
import SPMUtility
import Basic
import Yams

struct DevEnvironmentProgram {

    func run() throws {
        let tc = TerminalController(stream: stdoutStream)
        let parser = ArgumentParser(commandName: nil,
                                    usage: "[--config <config_path>] <command>",
                                    overview: "DevEnvironment will collect your files and commit them to your repo where they are stored")
        let config = parser.add(option: "--config",
                                shortName: "-c",
                                kind: String.self,
                                usage: "A path to your configuration for the utility",
                                completion: .filename)
        let collectParser = parser.add(subparser: "collect", overview: "collect")
        let shouldPushOption = collectParser.add(option: "--shouldPush",
                                           shortName: "-p",
                                           kind: Bool.self,
                                           usage: "Should this command automatically push to your remote git repository?",
                                           completion: .values([
                                            (value: "true", description: "Automatically push to remote git repository"),
                                            (value: "false", description: "Do not automatically push to remote git repository")
                                           ]))

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

        guard let subparser = result.subparser(parser),
            let configFilepath = result.get(config) else
        {
            tc?.writeln("Could not parse arguments", inColor: .red, bold: true)
            tc?.writeln("")
            parser.printUsage(on: stdoutStream)
            exit(1)
        }

        let hoardConfig: HoardConfig
        do {
            let configYamlString = try String(contentsOfFile: configFilepath)
            let decoder = YAMLDecoder()
            hoardConfig = try decoder.decode(HoardConfig.self, from: configYamlString)
        } catch let error {
            tc?.writeln(error.localizedDescription)
            tc?.writeln("Could not parse config file at \(configFilepath)", inColor: .red, bold: true)
            exit(1)
        }

        switch subparser {
        case "collect":
            try CollectCommand(config: hoardConfig,
                               shouldPush: result.get(shouldPushOption)).run()
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

