import Foundation

public struct ModelInfo: Codable {
    let modelName: String
    let providerName: String
    let modelId: String

    public init(modelName: String, providerName: String, modelId: String){
        self.modelName = modelName
        self.providerName = providerName
        self.modelId = modelId
    }
}
