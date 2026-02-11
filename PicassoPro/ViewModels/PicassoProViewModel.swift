//
//  PicassoProViewModel.swift
//  PicassoPro
//
//  Created by mac 2019 on 9/20/23.
//

import SwiftUI

@MainActor class PicassoProViewModel: ObservableObject {
    private let imageGenerator: ImageGeneratorProtocol
    @Published var prompt: InputPrompt = .empty {
        didSet {
            if !isGeneratingImage && !prompt.isEmpty {
                isGeneratingImage = true
                alert = nil
                fetchData()
            }
        }
    }
    
    @Published var imageSaveState: TaskState = .toBeDone
    @Published var alert: Alert? = nil
    @Published var isGeneratingImage: Bool = false
    @Published var imageUrl: String = "" {
        didSet {
            imageSaveState = .toBeDone
        }
    }
    
    var showEmptyPromptSign: Bool {
        prompt.isEmpty && !isGeneratingImage && imageUrl.isEmpty
    }
    
    init(imageGenerator: ImageGeneratorProtocol = StableDiffusionImageGenerator()) {
        self.imageGenerator = imageGenerator
    }
    
    @MainActor
    private func fetchData() {
        Task {
            do {
                let generatedImage = try await imageGenerator.generateImage(from: prompt)
                self.imageUrl = generatedImage.url
                self.isGeneratingImage = false
            }
            catch(let error) {
                self.isGeneratingImage = false
                self.imageUrl = ""
                if let sdError = error as? ImageGenerationError {
                    self.alert = .init(from: sdError)
                } else {
                    self.alert = .init("Something Went Wrong", error.localizedDescription)
                }
            }
        }
    }
    
    func saveImage(image: Image) {
        if imageSaveState == .done || imageSaveState == .doing {
            return
        }
        
        let size = CGSize(width: prompt.outputImageWidth, height: prompt.outputImageHeight)
        guard let uiImage = image.getUIImage(newSize: size) else {
            self.alert = .init("Saving Failed", "Failed to save image to the gallery")
            return
        }
        
        let imageSaver = ImageSaver()
        imageSaver.errorHandler = { error in
            self.alert = .init("Saving Failed", error.localizedDescription)
            self.imageSaveState = .failed
        }
        imageSaver.successHandler = { [self] in
            self.alert = .init("Saved", "Image saved to gallery")
            self.imageSaveState = .done
        }
        imageSaver.writeToPhotoAlbum(image: uiImage)
    }
}

struct Alert: Equatable {
    let title: String
    let message: String
    
    init(_ title: String, _ message: String) {
        self.title = title
        self.message = message
    }
}

extension Alert {
    init(from sdError: ImageGenerationError) {
        switch sdError {
        case .apiError(let message):
            self = .init(sdError.rawValue, message)
        case .networkError(let message):
            self = .init(sdError.rawValue, message)
        case .unknownError(let message):
            self = .init(sdError.rawValue, message)
        }
    }
}

enum TaskState {
    case toBeDone
    case doing
    case done
    case failed
}
