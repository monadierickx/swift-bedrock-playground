import Testing

@testable import SwiftBedrockService

@Suite("SwiftBedrockService Tests")
struct SwiftBedrockServiceTests {
    let bedrock: SwiftBedrock

    init() async throws {
        self.bedrock = try await SwiftBedrock(
            bedrockClient: MockBedrockClient(),
            bedrockRuntimeClient: MockBedrockRuntimeClient()
        )
    }

    @Test("List all models")
    func listModels() async throws {
        let models = try await bedrock.listModels()
        #expect(models.count == 2)
        #expect(models[0].modelId == "anthropic.claude-instant-v1")
        #expect(models[0].modelName == "Claude Instant")
        #expect(models[0].providerName == "Anthropic")
    }

    @Test(
        "Complete text using an implemented model",
        arguments: [
            BedrockModel.nova_micro,
            BedrockModel.titan_text_g1_lite,
            BedrockModel.titan_text_g1_express,
            BedrockModel.titan_text_g1_premier,
            BedrockModel.claudev3_haiku,
            BedrockModel.claudev1,
            BedrockModel.claudev2,
            BedrockModel.claudev2_1,
            BedrockModel.claudev3_haiku,
            BedrockModel.claudev3_5_haiku,
        ])
    func completeTextWithValidModel(model: BedrockModel) async throws {
        let completion: TextCompletion = try await bedrock.completeText(
            "This is a test",
            with: model,
            maxTokens: 100,
            temperature: 0.5
        )
        #expect(completion.completion == "This is the textcompletion for: This is a test")
    }
    
    @Test(
        "Complete text using an unimplemented model",
        arguments: [
            BedrockModel.llama2_13b,
            BedrockModel.llama2_70b
        ])
    func completeTextWithInvalidModel(model: BedrockModel) async throws {
        await #expect(throws: SwiftBedrockError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                "This is a test",
                with: model,
                temperature: 0.8)
        }
    }

    @Test("Complete text using a valid temperature", arguments: [0, 0.2, 0.6, 1])
    func completeTextWithValidTemperature(temperature: Double) async throws {
        let completion: TextCompletion = try await bedrock.completeText(
            "This is a test",
            with: BedrockModel.nova_micro,
            temperature: temperature)
        #expect(completion.completion == "This is the textcompletion for: This is a test")
    }

    @Test("Complete text using an invalid temperature", arguments: [-2.5, -1, 1.00001, 2])
    func completeTextWithInvalidTemperature(temperature: Double) async throws {
        await #expect(throws: SwiftBedrockError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                "This is a test",
                with: BedrockModel.nova_micro,
                temperature: temperature)
        }
    }

    @Test(
        "Complete text using a valid maxTokens",
        arguments: [1, 10, 100, 5000])
    func completeTextWithValidMaxTokens(maxTokens: Int) async throws {
        let completion: TextCompletion = try await bedrock.completeText(
            "This is a test",
            with: BedrockModel.nova_micro,
            maxTokens: maxTokens)
        #expect(completion.completion == "This is the textcompletion for: This is a test")
    }

    @Test(
        "Complete text using an invalid maxTokens",
        arguments: [0, -1, -2])
    func completeTextWithInvalidMaxTokens(maxTokens: Int) async throws {
        await #expect(throws: SwiftBedrockError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                "This is a test",
                with: BedrockModel.nova_micro,
                maxTokens: maxTokens)
        }
    }
}
