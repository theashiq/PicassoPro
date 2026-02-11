//
//  ImageGeneratorProtocol.swift
//  PicassoPro
//
//  Created by Ashiqur Rahman on 12/2/26.
//


import Foundation

protocol ImageGeneratorProtocol {
    func generateImage(from input: InputPrompt) async throws -> GeneratedImage
}

struct GeneratedImage: Codable {
    let url: String
}
