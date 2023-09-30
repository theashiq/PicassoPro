//
//  Image+Ext.swift
//  PicassoPro
//
//  Created by mac 2019 on 10/1/23.
//

import SwiftUI

extension Image {
    @MainActor
    func getUIImage(newSize: CGSize) -> UIImage? {
        let image = resizable()
            .scaledToFill()
            .frame(width: newSize.width, height: newSize.height)
            .clipped()
        return ImageRenderer(content: image).uiImage
    }
}
