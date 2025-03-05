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
}
