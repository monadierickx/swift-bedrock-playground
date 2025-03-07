@preconcurrency import AWSBedrockRuntime
import AWSClientRuntime
import AWSSDKIdentity
import Foundation
import SwiftBedrockService

public struct MockBedrockRuntimeClient: MyBedrockRuntimeClientProtocol {
    public init() {}

    public func invokeModel(input: InvokeModelInput) async throws -> InvokeModelOutput {
        guard let modelId = input.modelId else {
            throw AWSBedrockRuntime.ValidationException(message: "Malformed input request, please reformat your input and try again.")
        }
        guard let inputBody = input.body else {
            throw AWSBedrockRuntime.ValidationException(message: "Malformed input request, please reformat your input and try again.")
        }
        let model: BedrockModel = try BedrockModel(modelId)
        switch model.family {
        case .nova:
            return InvokeModelOutput(body: try invokeNovaModel(body: inputBody))
        case .titan:
            return InvokeModelOutput(body: try invokeTitanModel(body: inputBody))
        case .anthropic:
            return InvokeModelOutput(body: try invokeAnthropicModel(body: inputBody))
        default:
            throw AWSBedrockRuntime.ValidationException(message: "Malformed input request, please reformat your input and try again.")
        }
    }

    private func invokeNovaModel(body: Data) throws -> Data? {
        guard
            let json: [String: Any] = try? JSONSerialization.jsonObject(
                with: body, options: [])
                as? [String: Any]
        else {
            throw AWSBedrockRuntime.ValidationException(message: "Malformed input request, please reformat your input and try again.")
        }
        if let messages = json["messages"] as? [[String: Any]],
            let firstMessage = messages.first,
            let content = firstMessage["content"] as? [[String: Any]],
            let firstContent = content.first,
            let inputText = firstContent["text"] as? String
        {
            return """
                {
                    "output":{
                        "message":{
                            "content":[
                                {"text":"This is the textcompletion for: \(inputText)"}
                            ],
                            "role":"assistant"
                        }},
                    "stopReason":"end_turn",
                    "usage":{
                        "inputTokens":5,
                        "outputTokens":244,
                        "totalTokens":249,
                        "cacheReadInputTokenCount":0,
                        "cacheWriteInputTokenCount":0
                    }
                }
                """.data(using: .utf8)!
        } else {
            throw AWSBedrockRuntime.ValidationException(message: "Malformed input request, please reformat your input and try again.")
        }
    }

    private func invokeTitanModel(body: Data) throws -> Data? {
        guard
            let json: [String: Any] = try? JSONSerialization.jsonObject(
                with: body, options: [])
                as? [String: Any]
        else {
            throw AWSBedrockRuntime.ValidationException(message: "Malformed input request, please reformat your input and try again.")
        }
        if let inputText = json["inputText"] as? String {
            return """
                {
                    "inputTextTokenCount":5,
                    "results":[
                        {
                            "tokenCount":105,
                            "outputText":"This is the textcompletion for: \(inputText)",
                            "completionReason":"FINISH"
                            }
                    ]
                }
                """.data(using: .utf8)!
        } else {
            throw AWSBedrockRuntime.ValidationException(message: "Malformed input request, please reformat your input and try again.")
        }
    }

    private func invokeAnthropicModel(body: Data) throws -> Data? {
        guard
            let json: [String: Any] = try? JSONSerialization.jsonObject(
                with: body, options: [])
                as? [String: Any]
        else {
            throw AWSBedrockRuntime.ValidationException(message: "Malformed input request, please reformat your input and try again.")
        }
        if let messages = json["messages"] as? [[String: Any]],
            let firstMessage = messages.first,
            let content = firstMessage["content"] as? [[String: Any]],
            let firstContent = content.first,
            let inputText = firstContent["text"] as? String
        {
            return """
                {
                    "id":"msg_bdrk_0146cw8Wd6Dn8WZiQWeF6TEj",
                    "type":"message",
                    "role":"assistant",
                    "model":"claude-3-haiku-20240307",
                    "content":[
                        {
                            "type":"text",
                            "text":"This is the textcompletion for: \(inputText)"
                        }],
                    "stop_reason":"max_tokens",
                    "stop_sequence":null,
                    "usage":{
                        "input_tokens":12,
                        "output_tokens":100}
                }
                """.data(using: .utf8)!
        } else {
            throw AWSBedrockRuntime.ValidationException(message: "Malformed input request, please reformat your input and try again.")
        }
    }
}
