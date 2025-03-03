@preconcurrency import AWSBedrock
@preconcurrency import AWSBedrockRuntime
import AWSSDKIdentity
import ClientRuntime
import Foundation
import Hummingbird

struct ModelInfo: Codable {
    let modelName: String
    let providerName: String
    let modelId: String
}