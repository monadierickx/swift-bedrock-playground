@preconcurrency import AWSBedrock
import AWSClientRuntime
import AWSSDKIdentity
import Foundation
import SwiftBedrockService

public struct MockBedrockClient: MyBedrockClientProtocol {
    public init() {}

    public func listFoundationModels(input: ListFoundationModelsInput) async throws
        -> ListFoundationModelsOutput
    {
        return ListFoundationModelsOutput(
            modelSummaries: [
                BedrockClientTypes.FoundationModelSummary(
                    modelId: "anthropic.claude-instant-v1",
                    modelName: "Claude Instant",
                    providerName: "Anthropic",
                    responseStreamingSupported: false
                ),
                BedrockClientTypes.FoundationModelSummary(
                    modelId: "anthropic.claude-instant-v2",
                    modelName: "Claude Instant 2",
                    providerName: "Anthropic",
                    responseStreamingSupported: true
                ),
                BedrockClientTypes.FoundationModelSummary(
                    modelId: "unknownID",
                    modelName: "Claude Instant 3",
                    providerName: nil,
                    responseStreamingSupported: false
                ),
            ])
    }
}
