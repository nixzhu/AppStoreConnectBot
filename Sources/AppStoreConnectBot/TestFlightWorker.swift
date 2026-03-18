import Foundation
import Bagbutik_Core
import Bagbutik_Models
import Bagbutik_AppStore
import Bagbutik_TestFlight
import CustomDump

actor TestFlightWorker {
    private let service: BagbutikService
    private let appID: String
    private let groupID: String
    private let buildVersion: String
    private let whatsNew: String

    init(
        service: BagbutikService,
        appID: String,
        groupID: String,
        buildVersion: String,
        whatsNew: String
    ) {
        self.service = service
        self.appID = appID
        self.groupID = groupID
        self.buildVersion = buildVersion
        self.whatsNew = whatsNew
    }

    func run() async throws {
        guard let build = try await findBuild() else {
            print("No builds found.")
            return
        }

        try await addBuildToGroup(build: build)
        try await updateBuildLocalization(build: build, whatsNew: whatsNew)
        let submission = try await submitBuildToTestFlight(build: build)
        customDump(submission.attributes)
        print("Build \(buildVersion) is submitted to TestFlight.")
    }

    private func findBuild() async throws -> Build? {
        enum Outcome {
            case found(Build)
            case notFound
            case continuePolling
        }

        func checkLatestBuild() async throws -> Outcome {
            let response = try await service.request(
                .listBuildsV1(
                    filters: [.app([appID])],
                    limits: [.limit(1)]
                )
            )

            guard let latestBuild = response.data.first else {
                return .notFound
            }

            if latestBuild.attributes?.version == buildVersion {
                return .found(latestBuild)
            }

            return .continuePolling
        }

        while true {
            switch try await checkLatestBuild() {
            case .found(let build):
                return build
            case .notFound:
                return nil
            case .continuePolling:
                print("Build \(buildVersion) is not available for now.")
                print("Retry in 1 minute…")
                try await Task.sleep(for: .seconds(60))
            }
        }
    }

    private func addBuildToGroup(
        build: Build
    ) async throws {
        try await service.request(
            .createBetaGroupsForBuildV1(
                id: build.id,
                requestBody: .init(
                    data: [.init(id: groupID)]
                )
            )
        )
    }

    private func updateBuildLocalization(
        build: Build,
        whatsNew: String
    ) async throws {
        let locale = "en-US"

        let first = try await service.request(
            .listBetaBuildLocalizationsV1(filters: [.build([build.id])])
        )
        .data
        .first

        let enUS: BetaBuildLocalization = if let first {
            first
        } else {
            try await service.request(
                .createBetaBuildLocalizationV1(
                    requestBody: .init(
                        data: .init(
                            attributes: .init(locale: locale),
                            relationships: .init(build: .init(data: .init(id: build.id)))
                        )
                    )
                )
            )
            .data
        }

        _ = try await service.request(
            .updateBetaBuildLocalizationV1(
                id: enUS.id,
                requestBody: .init(
                    data: .init(
                        id: enUS.id,
                        attributes: .init(whatsNew: whatsNew)
                    )
                )
            )
        )
    }

    private func submitBuildToTestFlight(
        build: Build
    ) async throws -> BetaAppReviewSubmission {
        try await service.request(
            .createBetaAppReviewSubmissionV1(
                requestBody: .init(
                    data: .init(
                        relationships: .init(
                            build: .init(data: .init(id: build.id))
                        )
                    )
                )
            )
        )
        .data
    }
}
