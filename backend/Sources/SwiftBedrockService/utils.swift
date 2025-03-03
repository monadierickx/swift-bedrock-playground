import Foundation
@preconcurrency import AWSBedrock
@preconcurrency import AWSBedrockRuntime
import AWSSDKIdentity
import ClientRuntime

func initializeLogging() async {
    await SDKLoggingSystem().initialize(logLevel: .warning)
}

func configureBedrockRuntimeClient() async -> BedrockRuntimeClient {
    do {
        let identityResolver = try SSOAWSCredentialIdentityResolver()

        let runtimeClientConfig = try await BedrockRuntimeClient.BedrockRuntimeClientConfiguration(
            region: "us-east-1")
        runtimeClientConfig.awsCredentialIdentityResolver = identityResolver

        return  BedrockRuntimeClient(config: runtimeClientConfig)
    } catch {
        print("Error: \(error)")
        exit(1)
    }
}

// func configureBedrockClient() async -> BedrockClient {
//     do {
//         let identityResolver = try SSOAWSCredentialIdentityResolver()
//         let clientConfig = try await BedrockClient.BedrockClientConfiguration(region: "us-east-1")
//         clientConfig.awsCredentialIdentityResolver = identityResolver

//         return BedrockClient(config: clientConfig)
//     } catch {
//         print("Error: \(error)")
//         exit(1)
//     }
// }

func loadPNGFromDisk(filePath: String) throws -> Data {
    let fileURL = URL(fileURLWithPath: filePath)
    
    guard FileManager.default.fileExists(atPath: filePath) else {
        fatalError("File not found at path: \(filePath)")
    }
    
    do {
        let data = try Data(contentsOf: fileURL)
        return data
    } catch {
        fatalError("Unable to load data: \(error)")
    }
}

func getImageAsBase64(filePath path: String) throws -> String {
    let imageData = try loadPNGFromDisk(filePath: path)
    return imageData.base64EncodedString()
}

func savePNGToDisk(data: Data, filePath: String) throws {
    let fileURL = URL(fileURLWithPath: filePath)
    
    do {
        try data.write(to: fileURL)
    } catch {
        fatalError("Unable to save data: \(error)")
    }
}

func getTimestamp() -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd_hh-mm_a"
    return formatter.string(from: date)
}

// video generation 

import CoreGraphics
import ImageIO

func resizeImage(at filePath: String) -> Data {
    // Load the original image data
    guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
        fatalError("Could not load image data from file")
    }
    
    // Create an image source
    guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
          let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
        fatalError("Could not create image source")
    }
    
    // Create the context with desired size
    let width: Int = 1280
    let height: Int = 720
    guard let context = CGContext(data: nil,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: 0, // Let Core Graphics calculate the bytes per row
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
        fatalError("Could not create context")
    }
    
    // Fill with white background to remove transparency
    context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
    
    // Draw the image in the context
    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    // Get the resized image
    guard let resizedImage = context.makeImage() else {
        fatalError("Could not create resized image")
    }
    
    // Convert to PNG data
    let mutableData = NSMutableData()
    guard let destination = CGImageDestinationCreateWithData(mutableData, "public.png" as CFString, 1, nil) else {
        fatalError("Could not create image destination")
    }
    
    // Set properties to ensure no alpha channel
    let imageProperties = [
        kCGImageDestinationLossyCompressionQuality: 1.0,
        kCGImagePropertyHasAlpha: false
    ] as CFDictionary
    
    CGImageDestinationAddImage(destination, resizedImage, imageProperties)
    guard CGImageDestinationFinalize(destination) else {
        fatalError("Could not finalize image")
    }
    
    return mutableData as Data
}

func getImageAsBase64AndResize(filePath: String) -> String {
    let imageData = resizeImage(at: filePath)
    return imageData.base64EncodedString()
}


