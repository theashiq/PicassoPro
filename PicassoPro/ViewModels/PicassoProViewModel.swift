//
//  PicassoProViewModel.swift
//  PicassoPro
//
//  Created by mac 2019 on 9/20/23.
//

import SwiftUI

@MainActor class PicassoProViewModel: ObservableObject{
    
    @Published var prompt: PromptInput = .empty {
        didSet{
            if !isGeneratingImage && !prompt.isEmpty {
                isGeneratingImage = true
                alertStatus = .none
                fetchData()
            }
        }
    }
    
    @Published var imageSaveState: TaskState = .toBeDone
    @Published var alertStatus: AlertStatus = .none
    @Published var isGeneratingImage: Bool = false
    @Published var imageUrl: String = ""{
        didSet{
            imageSaveState = .toBeDone
        }
    }
    
    var showEmptyPromptSign: Bool{
        prompt.isEmpty && !isGeneratingImage && imageUrl.isEmpty
    }
    
    @MainActor
    private func fetchData(){
        Task {
            do {
                let apiResponseData = try await StableDiffusionAPIManager.shared.getImageUrls(prompt: prompt)
                if let output = apiResponseData.output, output.count > 0{
                    self.imageUrl = output.first!
                } else {
                    self.imageUrl = ""
                    self.alertStatus = .fail("Error Occurred", "Something went wrong. Please try again.")
                }
                self.isGeneratingImage = false
            }
            catch(let error) {
                self.isGeneratingImage = false
                self.imageUrl = ""
                if let sdError = error as? StableDiffusionError {
                    self.alertStatus = .init(from: sdError)
                } else {
                    self.alertStatus = .fail("Error Occurred", error.localizedDescription)
                }
            }
        }
    }
    
    func saveImage(image: Image){
        
        if imageSaveState == .done || imageSaveState == .doing{
            return
        }
        
        let size = CGSize(width: prompt.outputImageWidth, height: prompt.outputImageHeight)
        guard let uiImage = image.getUIImage(newSize: size) else {
            self.alertStatus = .fail("Saving Failed", "Failed to save image to the gallery")
            return
        }
        
        let imageSaver = ImageSaver()
        imageSaver.errorHandler = { error in
            self.alertStatus = .fail("Saving Failed", error.localizedDescription)
            self.imageSaveState = .failed
        }
        imageSaver.successHandler = { [self] in
            self.alertStatus = .success("Saved", "Image saved to gallery")
            self.imageSaveState = .done
        }
        imageSaver.writeToPhotoAlbum(image: uiImage)
    }
}

enum AlertStatus: Equatable{
    case none
    case success(String, String)
    case fail(String, String)
    
    var message: String{
        switch self{
        case .none:
            return ""
        case .success( _, let message):
            return message
        case .fail(_, let message):
            return message
        }
    }
    
    var title: String{
        switch self{
        case .none:
            return ""
        case .success(let title, _):
            return title
        case .fail(let title, _):
            return title
        }
    }
}

extension AlertStatus{
    init(from sdError: StableDiffusionError) {
        switch sdError{
        case .apiError(let message):
            self = .success(sdError.rawValue, message)
        case .networkError(let message):
            self = .success(sdError.rawValue, message)
        case .unknownError(let message):
            self = .success(sdError.rawValue, message)
        }
    }
}

enum TaskState{
    case toBeDone
    case doing
    case done
    case failed
}
