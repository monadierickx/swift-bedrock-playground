@preconcurrency import AWSBedrock
import AWSClientRuntime
import AWSSDKIdentity
import Foundation

public protocol MyBedrockClientProtocol {
    func listFoundationModels(input: ListFoundationModelsInput) async throws
        -> ListFoundationModelsOutput
}

extension BedrockClient: MyBedrockClientProtocol {}
