import ArgumentParser

struct SubmitBuildToExternalGroupCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "submit-build-to-external-group"
    )

    @OptionGroup
    var common: CommonOptions

    @Option(name: .long, help: "Build Version")
    var buildVersion: String

    @Option(name: .long, help: "Group Name")
    var groupName: String

    @Option(name: .long, help: "What's New")
    var whatsNew: String

    @Option(name: .long, help: "Wait Seconds")
    var waitSeconds: Double = 0

    mutating func run() async throws {
        if waitSeconds > 0 {
            print("🍄 Wait \(waitSeconds) seconds…")
            try await Task.sleep(for: .seconds(waitSeconds))
        }

        let service = try common.service()

        let worker = SubmitBuildToExternalGroupWorker(
            service: service,
            appID: common.appID,
            buildVersion: buildVersion,
            groupName: groupName,
            whatsNew: whatsNew
        )

        try await worker.run()
    }
}
