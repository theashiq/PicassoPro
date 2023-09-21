//
//  PromptInput.swift
//  PicassoPro
//
//  Created by mac 2019 on 9/20/23.
//

import Foundation


struct PromptInput{
    var expression: String
    var excludedWords: String
    var outputImageWidth: Int
    var outputImageHeight: Int
    
    static var empty: PromptInput{
        PromptInput(expression: "", excludedWords: "", outputImageWidth: 512, outputImageHeight: 512)
    }
    
    var isEmpty: Bool{
        expression.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
    }
}
