@preconcurrency import AWSBedrockRuntime
import AWSClientRuntime
import AWSSDKIdentity
import Foundation

public protocol MyBedrockRuntimeClientProtocol {
    func invokeModel(input: InvokeModelInput) async throws -> InvokeModelOutput
}

extension BedrockRuntimeClient: MyBedrockRuntimeClientProtocol {}
