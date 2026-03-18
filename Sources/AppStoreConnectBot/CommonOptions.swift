import ArgumentParser

struct CommonOptions: ParsableArguments {
    @Option(name: .long, help: "Key ID")
    var keyID: String

    @Option(name: .long, help: "Issuer ID")
    var issuerID: String

    @Option(name: .long, help: "Private Key Path")
    var privateKeyPath: String

    @Option(name: .long, help: "App ID")
    var appID: String
}
