import Foundation
import ArgumentParser
import Bagbutik_Core

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
        // swiftformat:disable acronyms
        let service = try BagbutikService(
            jwt: .init(
                keyId: common.keyID,
                issuerId: common.issuerID,
                privateKeyPath: common.privateKeyPath
            ),
            fetchData: { request, delegate in
                try await URLSession.shared.data(for: request, delegate: delegate)
            }
        )
        // swiftformat:enable acronyms

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
