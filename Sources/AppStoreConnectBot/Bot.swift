import ArgumentParser

@main
struct Bot: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        subcommands: [
            SubmitBuildToTestFlightCommand.self,
        ]
    )
}
