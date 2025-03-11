@preconcurrency import AWSBedrockRuntime
import AWSClientRuntime
import AWSSDKIdentity
import Foundation
import SwiftBedrockTypes

public protocol MyBedrockRuntimeClientProtocol: Sendable {
    func invokeModel(input: InvokeModelInput) async throws -> InvokeModelOutput
}

extension BedrockRuntimeClient: @retroactive @unchecked Sendable, MyBedrockRuntimeClientProtocol {}
