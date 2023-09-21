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
    
    func getImageUrlFromText(prompt: PromptInput) async throws -> [String]{
        
        parameters.updateValue(prompt.expression, forKey: "prompt")
        parameters.updateValue(prompt.excludedWords, forKey: "negative_prompt")
        parameters.updateValue(prompt.outputImageWidth, forKey: "width")
        parameters.updateValue(prompt.outputImageHeight, forKey: "height")
        
        let url = URL(string: StableDiffusionAPIManager.urlString)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        let (data, _) = try await URLSession.shared.data(for: request)
            
        return try JSONDecoder().decode(ApiResponse.self, from: data).output
    }
}

struct ApiResponse: Decodable{
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
