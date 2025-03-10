import Foundation

public struct AmazonImageRequestBody: BedrockBodyCodable {
    let taskType: String
    let textToImageParams: TextToImageParams?
    let imageVariationParams: ImageVariationParams?
    let imageGenerationConfig: ImageGenerationConfig

    public static func textToImage(prompt: String, nrOfImages: Int = 3) -> Self {
        return AmazonImageRequestBody(prompt: prompt, nrOfImages: nrOfImages)
    }

    private init(prompt: String, nrOfImages: Int) {
        self.taskType = "TEXT_IMAGE"
        self.textToImageParams = TextToImageParams(text: prompt)
        self.imageVariationParams = nil
        self.imageGenerationConfig = ImageGenerationConfig(nrOfImages: nrOfImages)
    }

    public static func imageVariation(
        prompt: String, referenceImage: String, similarity: Double = 0.6, nrOfImages: Int = 3
    ) -> Self {
        return AmazonImageRequestBody(
            prompt: prompt, referenceImage: referenceImage, similarity: similarity,
            nrOfImages: nrOfImages)
    }

    private init(prompt: String, referenceImage: String, similarity: Double, nrOfImages: Int) {
        self.taskType = "IMAGE_VARIATION"
        self.textToImageParams = nil
        self.imageVariationParams = ImageVariationParams(
            text: prompt, referenceImage: referenceImage, similarity: similarity)
        self.imageGenerationConfig = ImageGenerationConfig(nrOfImages: nrOfImages)
    }

    public struct TextToImageParams: Codable {
        let text: String
    }

    public struct ImageVariationParams: Codable {
        let text: String
        let images: [String]
        let similarityStrength: Double

        public init(text: String, referenceImage: String, similarity: Double) {
            self.text = text
            self.images = [referenceImage]
            self.similarityStrength = similarity
        }
    }

    public struct ImageGenerationConfig: Codable {
        let cfgScale: Int
        let seed: Int
        let quality: String
        let width: Int
        let height: Int
        let numberOfImages: Int

        public init(nrOfImages: Int = 3) {
            self.cfgScale = 8
            self.seed = 42
            self.quality = "standard"
            self.width = 1024
            self.height = 1024
            self.numberOfImages = nrOfImages
        }
    }
}
