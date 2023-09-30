//
//  PicassoProViewModel.swift
//  PicassoPro
//
//  Created by mac 2019 on 9/20/23.
//

import SwiftUI

class PicassoProViewModel: ObservableObject{
    
    @Published var prompt: PromptInput = .empty {
        didSet{
            if !isGeneratingImage && !prompt.isEmpty {
                isGeneratingImage = true
                error = nil
                fetchData()
            }
        }
    }
    
    @Published var imageUrl: String = ""
    @Published var isGeneratingImage: Bool = false
    @Published var error: StableDiffusionError? = nil
    
    var showEmptyPromptSign: Bool{
        prompt.isEmpty && !isGeneratingImage && imageUrl.isEmpty
    }
    
    private func fetchData(){
        Task{
            await StableDiffusionAPIManager.shared.getImageUrls(prompt: prompt){ [self] result in
                DispatchQueue.main.async{
                    self.isGeneratingImage = false
                    
                    switch result{
                    case .success(let apiResponseData):
                        if apiResponseData.output.count > 0{
                            self.imageUrl = apiResponseData.output.first!
                        }
                    case .failure(let error):
                        self.imageUrl = ""
                        self.error = error as? StableDiffusionError
                    }
                }
            }
        }
    }
}


