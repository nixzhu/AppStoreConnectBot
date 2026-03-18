import ArgumentParser

struct SubmitBuildToTestFlightCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "submit-build-to-testflight"
    )

    @OptionGroup
    var common: CommonOptions

    @Option(name: .long, help: "Group ID")
    var groupID: String

    @Option(name: .long, help: "Build Version")
    var buildVersion: String

    @Option(name: .long, help: "Whats New")
    var whatsNew: String

    mutating func run() async throws {
        let service = try common.service()

        let worker = SubmitBuildToTestFlightWorker(
            service: service,
            appID: common.appID,
            groupID: groupID,
            buildVersion: buildVersion,
            whatsNew: whatsNew
        )

        try await worker.run()
    }
}
