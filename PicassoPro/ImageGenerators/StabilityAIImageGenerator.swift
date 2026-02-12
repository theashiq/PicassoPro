//
//  StabilityAIImageGenerator.swift
//  PicassoPro
//
//  Created by Ashiqur Rahman on 12/2/26.
//


import Foundation

final class StabilityAIImageGenerator {
    private static let urlString = "https://api.stability.ai/v2beta/stable-image/generate/sd3"
    private static let apiKey = "sk-N7smZTMS6Du8yC0UrlkSDgRnji2LvMtA3JE0Mljn4M0tLpsi"
    
    func generateImage(prompt: InputPrompt) async throws -> URL {
        let url = URL(string: Self.urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(Self.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("image/*", forHTTPHeaderField: "Accept")
        
        let uuid = UUID().uuidString
        let boundary = "Boundary-\(uuid)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let params = [
            "prompt": prompt.expression,
            "negative_prompt": prompt.excludedWords,
            "output_format": "jpeg"
        ]
        
        var data = Data()
        for (key, value) in params {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(value)\r\n".data(using: .utf8)!)
        }
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = data

        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            let path = FileManager.default.temporaryDirectory.appendingPathComponent("\(uuid).jpeg")
            try responseData.write(to: path)
            return path
        } else {
            throw ImageGenerationError.unknownError((String(data: responseData, encoding: .utf8) ?? "Error"))
        }
    }
}

extension StabilityAIImageGenerator: ImageGeneratorProtocol {
    func generateImage(from input: InputPrompt) async throws -> GeneratedImage {
        let path = try await generateImage(prompt: input)
        return .init(url: path.absoluteString)
    }
}
