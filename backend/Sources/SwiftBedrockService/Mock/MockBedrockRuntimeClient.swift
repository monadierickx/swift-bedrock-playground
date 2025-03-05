@preconcurrency import AWSBedrockRuntime
import AWSClientRuntime
import AWSSDKIdentity
import Foundation

public protocol MyBedrockRuntimeClientProtocol: Sendable {
    func invokeModel(input: InvokeModelInput) async throws -> InvokeModelOutput
}

extension BedrockRuntimeClient: @retroactive @unchecked Sendable, MyBedrockRuntimeClientProtocol {}

public struct MockBedrockRuntimeClient: MyBedrockRuntimeClientProtocol {
    public init() {}

    public func invokeModel(input: InvokeModelInput) async throws -> InvokeModelOutput {
        guard let modelId = input.modelId else {
            throw MockBedrockRuntimeClientError.invokeModelError("ModelId in InvokeModelInput is nil")
        }
        guard let inputBody = input.body else {
            throw MockBedrockRuntimeClientError.invokeModelError("Body in InvokeModelInput is nil")
        }

        switch modelId {
        case "amazon.nova-micro-v1:0":
            return InvokeModelOutput(body: try invokeNovaModel(body: inputBody))
        case "amazon.titan-text-premier-v1:0",
            "amazon.titan-text-express-v1",
            "amazon.titan-text-lite-v1":
            return InvokeModelOutput(body: try invokeTitanModel(body: inputBody))
        case "anthropic.claude-3-haiku-20240307-v1:0",
            "anthropic.claude-v1",
            "anthropic.claude-v2",
            "anthropic.claude-v2:1",
            "anthropic.claude-3-5-haiku-20241022-v1:0":
            return InvokeModelOutput(body: try invokeAnthropicModel(body: inputBody))
        default:
            throw MockBedrockRuntimeClientError.invokeModelError("Unknown modelId: \(modelId)")
        }
    }

    private func invokeNovaModel(body: Data) throws -> Data? {
        guard
            let json: [String: Any] = try? JSONSerialization.jsonObject(
                with: body, options: [])
                as? [String: Any]
        else {
            throw MockBedrockRuntimeClientError.invokeModelError("Invalid JSON")
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
            throw MockBedrockRuntimeClientError.invokeModelError("Invalid JSON structure for Nova")
        }
    }

    private func invokeTitanModel(body: Data) throws -> Data? {
        guard
            let json: [String: Any] = try? JSONSerialization.jsonObject(
                with: body, options: [])
                as? [String: Any]
        else {
            throw MockBedrockRuntimeClientError.invokeModelError("Invalid JSON")
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
            throw MockBedrockRuntimeClientError.invokeModelError("Invalid JSON structure for Titan")
        }
    }

    private func invokeAnthropicModel(body: Data) throws -> Data? {
        guard
            let json: [String: Any] = try? JSONSerialization.jsonObject(
                with: body, options: [])
                as? [String: Any]
        else {
            throw MockBedrockRuntimeClientError.invokeModelError("Invalid JSON")
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
            throw MockBedrockRuntimeClientError.invokeModelError("Invalid JSON structure for Anthropic")
        }
    }
}

enum MockBedrockRuntimeClientError: Error {
    case invokeModelError(String)
}
