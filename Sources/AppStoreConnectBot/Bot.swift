import Foundation
import ArgumentParser
import Bagbutik_Core

@main
struct Bot: AsyncParsableCommand {
    @Option(name: .long, help: "Key ID")
    var keyID: String

    @Option(name: .long, help: "Issuer ID")
    var issuerID: String

    @Option(name: .long, help: "Private Key Path")
    var privateKeyPath: String

    @Option(name: .long, help: "App ID")
    var appID: String

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
                keyId: keyID,
                issuerId: issuerID,
                privateKeyPath: privateKeyPath
            ),
            fetchData: { request, delegate in
                try await URLSession.shared.data(for: request, delegate: delegate)
            }
        )
        // swiftformat:enable acronyms

        let worker = TestFlightWorker(
            service: service,
            appID: appID,
            groupID: groupID,
            buildVersion: buildVersion,
            whatsNew: whatsNew
        )

        try await worker.run()
    }
}
