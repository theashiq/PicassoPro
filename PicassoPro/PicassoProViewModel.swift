//
//  PicassoProViewModel.swift
//  PicassoPro
//
//  Created by mac 2019 on 9/20/23.
//

import Foundation


class PicassoProViewModel: ObservableObject{
    
    @Published var prompt: PromptInput = .empty {
        didSet{
            if prompt.isEmpty{
                //Show error
            }
            else{
                fetchData()
            }
        }
    }
    
    func fetchData(){
        
    }
}
