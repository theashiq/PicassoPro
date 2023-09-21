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
            if prompt.isEmpty{
                fetchState = .emptyPrompt("Enter prompt below")
            }
            else{
                fetchData()
            }
        }
    }
    @Published var outputUrl: String = ""
    @Published var fetchState: FetchState = .emptyPrompt("Enter prompt below")
    
    func fetchData(){
        fetchState = .fetching
        Task{
            do{
                let urls = try await StableDiffusionAPIManager.shared.getImageUrlFromText(prompt: prompt)
                
                if urls.count > 0{
                    outputUrl = urls[0]
                }
            }
            catch{
                fetchState = .error(error.localizedDescription)
            }
        }
    }
}

enum FetchState: Equatable{
    case emptyPrompt(String)
    case fetching
    case error(String)
}

