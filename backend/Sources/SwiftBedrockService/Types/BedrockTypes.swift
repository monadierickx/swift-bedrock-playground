@preconcurrency import AWSBedrockRuntime
import Foundation

//public enum BedrockModel: Hashable {
//    case anthropicModel(AnthropicModel)
//    case metaModel(MetaModel)
//
//    public func id() -> BedrockModelIdentifier {
//        switch self {
//        case .anthropicModel(let anthropic): return anthropic.rawValue
//        case .metaModel(let meta): return meta.rawValue
//        }
//    }
//}

public protocol BedrockResponse: Decodable {
    init(from data: Data) throws
    func getTextCompletion() -> TextCompletion
}

// extension BedrockResponse {
//     public static func decode<T: Decodable>(_ data: Data) throws -> T {
//         let decoder = JSONDecoder()
//         return try decoder.decode(T.self, from: data)
//     }
//     public static func decode<T: Decodable>(json: String) throws -> T {
//         let data = json.data(using: .utf8)!
//         return try self.decode(data)
//     }
// }

// public protocol BedrockRequest: Encodable {
//     func encode() throws -> Data

//     init(modelId: String, prompt: String, maxTokens: Int?, temperature: Double?)

//     // func getBody() -> Codable
// }

// extension BedrockRequest {
//     func getInvokeModelInput(
//         modelId: String, body: Codable, accept: String = "application/json",
//         contentType: String = "application/json"
//     ) -> InvokeModelInput {
//         do {
//             let jsonData: Data = try JSONEncoder().encode(body) // FIXME
//             return InvokeModelInput(
//                 accept: accept,
//                 body: jsonData,
//                 contentType: contentType,
//                 modelId: modelId)
//         } catch {
//             print("Encoding error: \(error)")
//             fatalError()  // FIXME
//         }
//     }
// }

// extension BedrockRequest {
//     public func encode() throws -> Data {
//         let encoder = JSONEncoder()
//         encoder.keyEncodingStrategy = .convertToSnakeCase
//         return try encoder.encode(self)
//     }
// }
