import Foundation

public struct AmazonImageRequestBody: BedrockBodyCodable {
    let taskType: String
    let textToImageParams: TextToImageParams
    let imageGenerationConfig: ImageGenerationConfig

    public init(prompt: String, nrOfImages: Int = 3) {
        self.taskType = "TEXT_IMAGE"
        self.textToImageParams = TextToImageParams(text: prompt)
        self.imageGenerationConfig = ImageGenerationConfig(numberOfImages: nrOfImages)
    }

    public struct TextToImageParams: Codable {
        let text: String
    }

    public struct ImageGenerationConfig: Codable {
        let cfgScale: Int
        let seed: Int
        let quality: String
        let width: Int
        let height: Int
        let numberOfImages: Int

        public init(numberOfImages: Int = 3) {
            self.cfgScale = 8
            self.seed = 42
            self.quality = "standard"
            self.width = 1024
            self.height = 1024
            self.numberOfImages = numberOfImages
        }
    }
}
