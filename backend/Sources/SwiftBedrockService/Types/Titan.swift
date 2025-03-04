// @preconcurrency import AWSBedrock
// @preconcurrency import AWSBedrockRuntime
// import AWSClientRuntime
// import AWSSDKIdentity
// import Foundation

// // {
// //  "modelId": "amazon.titan-text-premier-v1:0",
// //  "contentType": "application/json",
// //  "accept": "application/json",
// //  "body": {
// //     "inputText":"this is where you place your input text",
// //     "textGenerationConfig":
// //     {
// //         "maxTokenCount":3072,
// //         "stopSequences":[],
// //         "temperature":0.7,
// //         "topP":0.9
// //     }}
// // }

// public struct TitanRequest: BedrockRequest {
//     let modelId: String
//     let contentType: String = "application/json"
//     let accept: String = "application/json"
//     let body: TitanBody

//     public init(modelId: String, prompt: String, maxTokens: Int? = 300, temperature: Double? = 0.6) {
//         self.modelId = modelId
//         self.body = TitanBody(
//             inputText: prompt,
//             textGenerationConfig: TextGenerationConfig(
//                 maxTokenCount: maxTokens ?? 300, temperature: temperature ?? 0.6))
//     }

//     // public func getInvokeModelInput(body: Codable) -> InvokeModelInput {
//     //     do { 
//     //         let jsonData: Data = try JSONEncoder().encode(body)
//     //         return InvokeModelInput(
//     //             accept: accept,
//     //             body: jsonData,
//     //             contentType: contentType,
//     //             modelId: modelId)
//     //     } catch {
//     //         print("Encoding error: \(error)")
//     //         fatalError() // FIXME
//     //     }
//     // }

//     // public func getBody() -> any Codable {
//     //     return body
//     // }

//     public struct TitanBody: Codable {
//         let inputText: String
//         let textGenerationConfig: TextGenerationConfig
//     }

//     public struct TextGenerationConfig: Codable {
//         let maxTokenCount: Int
//         // let stopSequences: [String]  // TODO later
//         let temperature: Double
//         // let topP: Double             // TODO later
//     }
// }

// // {
// //     "inputTextTokenCount":5,
// //     "results":[
// //         {
// //             "tokenCount":105,
// //             "outputText":"completion!",
// //             "completionReason":"FINISH"
// //             }
// //     ]
// // }

// struct TitanResponse: BedrockResponse {
//     let inputTextTokenCount: Int
//     let results: [Result]

//     struct Result: Codable {
//         let tokenCount: Int
//         let outputText: String
//         let completionReason: String
//     }

//     public init(from data: Data) throws {
//         let decoder = JSONDecoder()
//         self = try decoder.decode(TitanResponse.self, from: data)
//     }

//     func getTextCompletion() -> TextCompletion {
//         return TextCompletion(results[0].outputText)
//     }
// }
