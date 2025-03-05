@preconcurrency import AWSBedrock
import AWSClientRuntime
import AWSSDKIdentity
import Foundation

// BedrockClient
public protocol MyBedrockClientProtocol: Sendable {
    func listFoundationModels(input: ListFoundationModelsInput) async throws
        -> ListFoundationModelsOutput
}

extension BedrockClient: @retroactive @unchecked Sendable, MyBedrockClientProtocol {}
// CHECKME: is this the way to go?

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
                    modelId: "anthropic.claude-instant-v3",
                    modelName: "Claude Instant 3",
                    responseStreamingSupported: false
                ),
            ])
    }
}
