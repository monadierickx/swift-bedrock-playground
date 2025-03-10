import Foundation

// text
extension BedrockModel {
    public static let nova_micro: BedrockModel = BedrockModel(
        rawValue: "amazon.nova-micro-v1:0", family: .nova)
}

// image
extension BedrockModel {
    public static let nova_canvas: BedrockModel = BedrockModel(
        rawValue: "amazon.nova-canvas-v1:0", family: .nova, inputModality: [.image],
        outputModality: [.image])
}
