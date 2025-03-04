// @preconcurrency import AWSBedrock
// @preconcurrency import AWSBedrockRuntime
// import AWSClientRuntime
// import AWSSDKIdentity
// import Foundation

// // {
// //   "modelId": "amazon.nova-micro-v1:0",
// //   "contentType": "application/json",
// //   "accept": "application/json",
// //   "body": {
// //     "inferenceConfig": {
// //       "max_new_tokens": 1000
// //     },
// //     "messages": [
// //       {
// //         "role": "user",
// //         "content": [
// //           {
// //             "text": "this is where you place your input text"
// //           }
// //         ]
// //       }
// //     ]
// //   }
// // }

// public struct NovaRequest: BedrockRequest {
//     let modelId: String
//     let contentType: String = "application/json"
//     let accept: String = "application/json"
//     let body: NovaBody

//     init(modelId: String, prompt: String, maxTokens: Int? = 300, temperature: Double? = 0.6) {
//         self.modelId = modelId
//         self.body = NovaBody(
//             inferenceConfig: InferenceConfig(max_new_tokens: maxTokens ?? 300),
//             messages: [Message(role: .user, content: [Content(text: prompt)])])
//     }

//     func getInvokeModelInput() -> InvokeModelInput {
//         do { 
//             let jsonData: Data = try JSONEncoder().encode(body)
//             return InvokeModelInput(
//                 accept: accept,
//                 body: jsonData,
//                 contentType: contentType,
//                 modelId: modelId)
//         } catch {
//             print("Encoding error: \(error)")
//             fatalError() // FIXME
//         }
//     }

//     public struct NovaBody: Codable {
//         let inferenceConfig: InferenceConfig
//         let messages: [Message]
//     }

//     public struct InferenceConfig: Codable {
//         let max_new_tokens: Int
//     }

//     public struct Message: Codable {
//         let role: Role
//         let content: [Content]
//     }

//     public struct Content: Codable {
//         let text: String
//     }
// }

// // {
// //     "output":{
// //         "message":{
// //             "content":[
// //                 {"text":"completion!"}
// //             ],
// //             "role":"assistant"
// //         }},
// //     "stopReason":"end_turn",
// //     "usage":{
// //         "inputTokens":5,
// //         "outputTokens":244,
// //         "totalTokens":249,
// //         "cacheReadInputTokenCount":0,
// //         "cacheWriteInputTokenCount":0
// //     }
// // }

// struct NovaResponse: Codable {
//     let output: Output
//     let stopReason: String
//     let usage: Usage

//     struct Output: Codable {
//         let message: Message
//     }
    
//     struct Message: Codable {
//         let content: [Content]
//         let role: Role
//     }

//     struct Content: Codable {           // FIXME: DRY
//         let text: String
//     }

//     struct Usage: Codable {
//         let inputTokens: Int
//         let outputTokens: Int
//         let totalTokens: Int
//         let cacheReadInputTokenCount: Int
//         let cacheWriteInputTokenCount: Int
//     }

//     public init(from data: Data) throws {
//         let decoder = JSONDecoder()
//         self = try decoder.decode(NovaResponse.self, from: data)
//     }

//     func getTextCompletion() -> TextCompletion {
//         return TextCompletion(output.message.content[0].text)
//     }
// }
