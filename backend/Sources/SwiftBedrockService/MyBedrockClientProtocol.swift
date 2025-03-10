@preconcurrency import AWSBedrock
import AWSClientRuntime
import AWSSDKIdentity
import Foundation

public protocol MyBedrockClientProtocol: Sendable {
    func listFoundationModels(input: ListFoundationModelsInput) async throws
        -> ListFoundationModelsOutput
}

extension BedrockClient: @retroactive @unchecked Sendable, MyBedrockClientProtocol {}
