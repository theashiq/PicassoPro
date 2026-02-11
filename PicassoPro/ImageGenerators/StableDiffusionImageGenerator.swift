//
//  StableDiffusionImageGenerator.swift
//  PicassoPro
//
//  Created by mac 2019 on 9/21/23.
//

import Foundation

final class StableDiffusionImageGenerator {
    
    private static let urlString = "https://modelslab.com/api/v6/realtime/text2img"
    private static let apiKey = "zAXjIPV7I9Sdl1YJ5e6Z4Zl5ucgjd62UbKJ4xrYHFeF47TWzmxFtNe95M4Dj"
    
    private var parameters: [String: Any] = [
        "key": apiKey,
        "prompt": "",
        "negative_prompt": "",
        "width": "512",
        "height": "512",
        "samples": "1",
        "num_inference_steps": "20",
        "seed": "",
        "guidance_scale": 7.5,
        "safety_checker": true,
        "multi_lingual": "no",
        "panorama": "no",
        "self_attention": "no",
        "upscale": "no",
        "embeddings_model": "",
        "webhook": "",
        "track_id": ""
    ]
    
    private func updateParameters(from prompt: InputPrompt) {
        parameters.updateValue(prompt.expression, forKey: "prompt")
        parameters.updateValue(prompt.excludedWords, forKey: "negative_prompt")
        parameters.updateValue(prompt.outputImageWidth, forKey: "width")
        parameters.updateValue(prompt.outputImageHeight, forKey: "height")
    }
    
    private func getImageUrls(prompt: InputPrompt) async throws -> ApiResponseData {
        
        guard let url = URL(string: StableDiffusionImageGenerator.urlString) else {
            throw ImageGenerationError.networkError("Invalid URL")
        }
        
        updateParameters(from: prompt)
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else {
            throw ImageGenerationError.networkError("Invalid HTTP Body")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        if let (data, _) = try? await URLSession.shared.data(for: request) {
            
            if let apiResponseData = try? JSONDecoder().decode(ApiResponseData.self, from: data) {
                return apiResponseData
            }
            else if let rateLimitResponseResult = try? JSONDecoder().decode(RateLimitExceededResponse.self, from: data) {
                throw ImageGenerationError.apiError(rateLimitResponseResult.message)
            }
            else if let invalidKeyResponse = try? JSONDecoder().decode(InvalidKeyResponse.self, from: data) {
                throw ImageGenerationError.apiError(invalidKeyResponse.message)
            }
            else if let failedResponse = try? JSONDecoder().decode(FailedResponse.self, from: data) {
                throw ImageGenerationError.apiError(failedResponse.message)
            }
            else if let validationErrorsResponse = try? JSONDecoder().decode(ValidationErrorsResponse.self, from: data) {
                throw ImageGenerationError.apiError(validationErrorsResponse.message.prompt.first ?? "")
            }
            else if let emptyModalIdErrorResponse = try? JSONDecoder().decode(EmptyModalIdErrorResponse.self, from: data) {
                throw ImageGenerationError.apiError(emptyModalIdErrorResponse.message)
            }
            else {
                throw ImageGenerationError.unknownError()
            }
        }
        else {
            throw ImageGenerationError.networkError("Unknown Network Error")
        }
    }
}

extension StableDiffusionImageGenerator: ImageGeneratorProtocol {
    func generateImage(from input: InputPrompt) async throws -> GeneratedImage {
        let apiResponse = try await getImageUrls(prompt: input)
        if let url = apiResponse.output?.first {
            return .init(url: url)
        } else {
            throw ImageGenerationError.unknownError()
        }
    }
}

// MARK: - Models
struct ApiResponseData: Decodable {
    var status: String?
    var generationTime: Float?
    var id: Int?
    var output: [String]?
}

struct ApiResponseMeta: Decodable {
    var H: Int
    var W: Int
    var enable_attention_slicing: String
    var file_prefix: String
    var guidance_scale: Float
    var model: String
    var n_samples: Int
    var negative_prompt: String
    var outdir: String
    var prompt: String
    var revision: String
    var safetychecker: String
    var seed: Int
    var steps: Int
    var vae: String
}



struct RateLimitExceededResponse: Decodable {
    var status: String
    var message: String
    var tips: String
}
struct InvalidKeyResponse: Decodable {
    var status: String
    var message: String
    var tip: String
}

struct FailedResponse: Decodable {
    var status: String
    var id: String
    var message: String
    var output: String
}

struct ValidationErrorsResponse: Decodable {
    var status: String
    var message: ValidationErrorsPrompt
}
struct ValidationErrorsPrompt: Decodable {
    var prompt: [String]
}

struct EmptyModalIdErrorResponse: Decodable {
    var status: String
    var message: String
}
