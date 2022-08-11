import ArgumentParser
import Foundation
import Files
import Rainbow
import Yams

@main
struct Hoard: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: nil,
        abstract: "Hoard will collect/distribute your files to/from a defined repo",
        version: "0.2.0",
        subcommands: [
            Add.self,
            Collect.self,
            Distribute.self,
            Init.self,
            Remove.self,
        ]
    )
}
