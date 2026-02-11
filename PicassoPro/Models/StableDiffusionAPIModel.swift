//
//  StableDiffusionAPIModel.swift
//  PicassoPro
//
//  Created by mac 2019 on 10/2/23.
//

import Foundation

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
