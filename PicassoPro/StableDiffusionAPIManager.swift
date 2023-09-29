//
//  StableDiffusionAPIManager.swift
//  PicassoPro
//
//  Created by mac 2019 on 9/21/23.
//

import Foundation

final class StableDiffusionAPIManager{
    private static let urlString = "https://stablediffusionapi.com/api/v3/text2img"
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
        "safety_checker": "yes",
        "multi_lingual": "no",
        "panorama": "no",
        "self_attention": "no",
        "upscale": "no",
        "embeddings_model": "",
        "webhook": "",
        "track_id": ""
    ]
    
    static let shared = StableDiffusionAPIManager()
    
    private init(){}
    
    private func updateParameters(from prompt: PromptInput) {
        parameters.updateValue(prompt.expression, forKey: "prompt")
        parameters.updateValue(prompt.excludedWords, forKey: "negative_prompt")
        parameters.updateValue(prompt.outputImageWidth, forKey: "width")
        parameters.updateValue(prompt.outputImageHeight, forKey: "height")
    }
    
    func getImageUrls(prompt: PromptInput, completed: @escaping (Result<ApiResponseData, Error>) -> Void) async {
        
        guard let url = URL(string: StableDiffusionAPIManager.urlString) else {
            completed(Result.failure(StableDiffusionError.networkError("Invalid URL")))
            return
        }
        
        updateParameters(from: prompt)
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else{
            completed(.failure(StableDiffusionError.networkError("Invalid HTTP Body")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        if let (data, _) = try? await URLSession.shared.data(for: request) {
            
            if let apiResponseData = try? JSONDecoder().decode(ApiResponseData.self, from: data){
                completed(.success(apiResponseData))
            }
            else if let rateLimitResponseResult = try? JSONDecoder().decode(RateLimitExceededResponse.self, from: data){
                completed(.failure(StableDiffusionError.apiError(rateLimitResponseResult.message)))
            }
            else if let invalidKeyResponse = try? JSONDecoder().decode(InvalidKeyResponse.self, from: data){
                completed(.failure(StableDiffusionError.apiError(invalidKeyResponse.message)))
            }
            else if let failedResponse = try? JSONDecoder().decode(FailedResponse.self, from: data){
                completed(.failure(StableDiffusionError.apiError(failedResponse.message)))
            }
            else if let validationErrorsResponse = try? JSONDecoder().decode(ValidationErrorsResponse.self, from: data){
                completed(.failure(StableDiffusionError.apiError(validationErrorsResponse.message.prompt.first ?? "")))
            }
            else if let emptyModalIdErrorResponse = try? JSONDecoder().decode(EmptyModalIdErrorResponse.self, from: data){
                completed(.failure(StableDiffusionError.apiError(emptyModalIdErrorResponse.message)))
            }
            else{
                completed(.failure(StableDiffusionError.unknownError))
            }
        }
        else{
            completed(.failure(StableDiffusionError.networkError("Unknown Network Error")))
        }
    }
}

enum StableDiffusionError: Error, LocalizedError, Equatable{
    case apiError(String)
    case networkError(String)
    case unknownError
    
    var errorDescription: String?{
        switch self{
        case .apiError(let message):
            return message
        case .networkError(let message):
            return message
        case .unknownError:
            return "An unknown error occurred. Please retry after sometime."
        }
    }
}

extension StableDiffusionError: RawRepresentable {

    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "API Error":  self = .apiError("API Error")
        case "Network Error":  self = .networkError("Network Error")
        case "Unknown Error":  self = .unknownError
        default:
            return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .apiError: return "API Error"
        case .networkError: return "Network Error"
        case .unknownError: return "Unknown Error"
        }
    }
}

struct ApiResponseData: Decodable{
    var status: String
    var generationTime: Float
    var id: Int
    var output: [String]
    var meta: ApiResponseMeta
}

struct ApiResponseMeta: Decodable{
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



struct RateLimitExceededResponse: Decodable{
    var status: String
    var message: String
    var tips: String
}
struct InvalidKeyResponse: Decodable{
    var status: String
    var message: String
    var tip: String
}

struct FailedResponse: Decodable{
    var status: String
    var id: String
    var message: String
    var output: String
}

struct ValidationErrorsResponse: Decodable{
    var status: String
    var message: ValidationErrorsPrompt
}
struct ValidationErrorsPrompt: Decodable{
    var prompt: [String]
}

struct EmptyModalIdErrorResponse: Decodable{
    var status: String
    var message: String
}
