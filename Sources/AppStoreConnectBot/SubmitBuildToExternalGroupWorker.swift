import Foundation
import Bagbutik_Core
import Bagbutik_Models
import Bagbutik_AppStore
import Bagbutik_TestFlight
import CustomDump

actor SubmitBuildToExternalGroupWorker {
    private let service: BagbutikService
    private let appID: String
    private let buildVersion: String
    private let groupName: String
    private let whatsNew: String

    init(
        service: BagbutikService,
        appID: String,
        buildVersion: String,
        groupName: String,
        whatsNew: String
    ) {
        self.service = service
        self.appID = appID
        self.buildVersion = buildVersion
        self.groupName = groupName
        self.whatsNew = whatsNew
    }

    func run() async throws {
        print("➡️  Find build…")

        guard let build = try await findBuild() else {
            print("❌  No builds found.")
            return
        }

        customDump(build, name: "Build")

        print("➡️  Update WhatsNew of build…")

        let localization = try await updateWhatsNew(of: build)

        customDump(localization, name: "Localization")

        print("➡️  Find group…")

        guard let group = try await findExternalGroup() else {
            print("❌  No external group named `\(groupName)` found.")
            return
        }

        customDump(group, name: "Group")

        print("➡️  Add build to group if needed…")

        try await addBuildToGroupIfNeeded(build: build, group: group)

        let submissions = try await getSubmissions(for: build)

        guard submissions.isEmpty else {
            customDump(submissions, name: "⚠️  Existing submissions")
            return
        }

        print("➡️  Submit build to review…")

        let submission = try await submitBuildToReview(build: build)

        customDump(submission, name: "Submission")

        print("✅  Build \(buildVersion) is submitted to TestFlight.")
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
                print("Retry in 30 seconds…")
                try await Task.sleep(for: .seconds(30))
            }
        }
    }

    func getSubmissions(for build: Build) async throws -> [BetaAppReviewSubmission] {
        try await service.request(
            .listBetaAppReviewSubmissionsV1(filters: [.build([build.id])])
        )
        .data
    }

    func findExternalGroup() async throws -> BetaGroup? {
        let groups = try await service.request(
            .listBetaGroupsV1(
                filters: [.app([appID])]
            )
        )
        .data

        guard let group = groups.first(where: { $0.attributes?.name == groupName }),
              group.attributes?.isInternalGroup == false
        else { return nil }

        return group
    }

    private func addBuildToGroupIfNeeded(
        build: Build,
        group: BetaGroup
    ) async throws {
        let groupIDs = build.relationships?.betaGroups?.data?.map { $0.id } ?? []

        guard !groupIDs.contains(group.id) else { return }

        try await service.request(
            .createBetaGroupsForBuildV1(
                id: build.id,
                requestBody: .init(
                    data: [.init(id: group.id)]
                )
            )
        )
    }

    private func updateWhatsNew(
        of build: Build
    ) async throws -> BetaBuildLocalization {
        let locale = "en-US"

        let enUS = try await service.request(
            .listBetaBuildLocalizationsV1(filters: [.build([build.id])])
        )
        .data
        .first(where: { $0.attributes?.locale == locale })

        let localization: BetaBuildLocalization = if let enUS {
            enUS
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

        return try await service.request(
            .updateBetaBuildLocalizationV1(
                id: localization.id,
                requestBody: .init(
                    data: .init(
                        id: localization.id,
                        attributes: .init(whatsNew: whatsNew)
                    )
                )
            )
        )
        .data
    }

    private func submitBuildToReview(
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
