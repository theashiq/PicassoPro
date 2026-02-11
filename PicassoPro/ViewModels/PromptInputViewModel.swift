//
//  PromptInputViewModel.swift
//  PicassoPro
//
//  Created by mac 2019 on 9/20/23.
//

import Foundation
import SwiftUI


class PromptInputViewModel: ObservableObject {
    @Published var prompt: Binding<PromptInput>
    
    @Published var expression: String
    @Published var excludedWordInput: String = ""
    @Published var excludedWords: Set<String>
    @Published var outputImageWidth: Int
    @Published var outputImageHeight: Int
    
    private static func breakExcludedWords(words: String) -> Set<String> {
        Set(words.components(separatedBy: ",").filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).count > 2 })
    }
    
    init(prompt: Binding<PromptInput>) {
        self.prompt = prompt
        
        self.expression = prompt.expression.wrappedValue
        self.excludedWords = PromptInputViewModel.breakExcludedWords(words: prompt.excludedWords.wrappedValue)
        self.outputImageWidth = prompt.outputImageWidth.wrappedValue
        self.outputImageHeight = prompt.outputImageHeight.wrappedValue
    }
    
    func submit() {
        prompt.wrappedValue = PromptInput(
            expression: self.expression,
            excludedWords: self.excludedWords.joined(separator: ","),
            outputImageWidth: self.outputImageWidth,
            outputImageHeight: self.outputImageHeight
        )
    }
    
    func addExcludedWord() {
        let trimmedInput = excludedWordInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedInput.count > 2 {
            
            if !excludedWords.contains(where: { $0.lowercased() ==  trimmedInput.lowercased() }) {
                excludedWords.insert(trimmedInput)
                excludedWordInput = ""
            }
        }
    }
    func removeExcludedWord(word: String) {
        excludedWords.remove(word.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
