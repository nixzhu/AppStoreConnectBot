import Foundation
import ArgumentParser
import Bagbutik_Core

struct CommonOptions: ParsableArguments {
    @Option(name: .long, help: "Key ID")
    var keyID: String

    @Option(name: .long, help: "Issuer ID")
    var issuerID: String

    @Option(name: .long, help: "Private Key Path")
    var privateKeyPath: String

    @Option(name: .long, help: "App ID")
    var appID: String

    func service() throws -> BagbutikService {
        // swiftformat:disable acronyms
        try .init(
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
    }
}
