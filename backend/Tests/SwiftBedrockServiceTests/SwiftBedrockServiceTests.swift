import Testing
@testable import SwiftBedrockService

@Suite("SwiftBedrockService Tests")
struct SwiftBedrockServiceTests {
    let mock: SwiftBedrock

    init() async throws {
        mock = try await SwiftBedrock(useMock: true)
    }

    @Test("List all models")
    func listModels() async throws {
        let models = try await mock.listModels()
        #expect(models.count == 2)
        #expect(models[0].modelId == "anthropic.claude-instant-v1")
        #expect(models[0].modelName == "Claude Instant")
        #expect(models[0].providerName == "Anthropic")
    }

    @Test("Complete text using a specific model", arguments: [
        BedrockModel.nova_micro,
        BedrockModel.titan_text_g1_lite,
        BedrockModel.titan_text_g1_express,
        BedrockModel.titan_text_g1_premier,
        BedrockModel.claudev3_haiku,
        BedrockModel.claudev1,
        BedrockModel.claudev2,
        BedrockModel.claudev2_1,
        BedrockModel.claudev3_haiku,
        BedrockModel.claudev3_5_haiku
        ])
    func completeText(model: BedrockModel) async throws {
        let completion: TextCompletion = try await mock.completeText(
            "This is a test",
            with: model,
            maxTokens: 100,
            temperature: 0.5
        )
        #expect(completion.completion == "This is the textcompletion for: This is a test")
    }
    
    @Test("Complete text using a specific temperature", arguments: [0, 0.1, 0.5, 0.8, 1, 1.2, 3, 400, -39.3])
    func invalidTemperatureError(temperature: Double) async throws {
        if temperature <= 1 && temperature >= 0 {
            let completion: TextCompletion = try await mock.completeText(
                "This is a test",
                with: BedrockModel.nova_micro,
                temperature: temperature)
            #expect(completion.completion == "This is the textcompletion for: This is a test")
        } else {
            await #expect(throws: SwiftBedrockError.self) {
                let _: TextCompletion = try await mock.completeText(
                    "This is a test",
                    with: BedrockModel.nova_micro,
                    temperature: temperature)
            }
        }
    }
    
    @Test("Complete text using a specific maxTokens", arguments: [1, 10, 100, 1000, 5000, 0, -1, -199])
    func invalidMaxTokensError(maxTokens: Int) async throws {
        if maxTokens > 0 {
            let completion: TextCompletion = try await mock.completeText(
                "This is a test",
                with: BedrockModel.nova_micro,
                maxTokens: maxTokens)
            #expect(completion.completion == "This is the textcompletion for: This is a test")
        } else {
            await #expect(throws: SwiftBedrockError.self) {
                let _: TextCompletion = try await mock.completeText(
                    "This is a test",
                    with: BedrockModel.nova_micro,
                    maxTokens: maxTokens)
            }
        }
    }
}
