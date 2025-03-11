import Foundation

// text
extension BedrockModel {
    public static let nova_micro: BedrockModel = BedrockModel(
        id: "amazon.nova-micro-v1:0", family: .nova)
}

// image
extension BedrockModel {
    public static let nova_canvas: BedrockModel = BedrockModel(
        id: "amazon.nova-canvas-v1:0", family: .nova, 
        inputModality: [.text, .image], // CHECKME: niet wat in the catalog staat
        outputModality: [.image])
}
