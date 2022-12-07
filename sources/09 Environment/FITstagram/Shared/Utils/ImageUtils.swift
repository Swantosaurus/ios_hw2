//
//  ImageUtils.swift
//  FITstagram
//
//  Created by Václav Kobera on 06.12.2022.
//

import Foundation
import SwiftUI

/**
  by Josh Bernfeld
  Joinked at https://stackoverflow.com/questions/2658738/the-simplest-way-to-resize-an-uiimage
 */
extension UIImage {
    enum ContentMode {
        case contentFill
        case contentAspectFill
        case contentAspectFit
    }
    
    func resize(withSize size: CGSize, contentMode: ContentMode = .contentAspectFill) -> UIImage? {
        let aspectWidth = size.width / self.size.width
        let aspectHeight = size.height / self.size.height
        
        switch contentMode {
        case .contentFill:
            return resize(withSize: size)
        case .contentAspectFit:
            let aspectRatio = min(aspectWidth, aspectHeight)
            return resize(withSize: CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio))
        case .contentAspectFill:
            let aspectRatio = max(aspectWidth, aspectHeight)
            return resize(withSize: CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio))
        }
    }
    
    private func resize(withSize size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

/**
    by Michal Šrůtek & Vivek & Václav Kobera
    Joinked at https://stackoverflow.com/questions/11251340/convert-between-uiimage-and-base64-string section Swift 5
 */
extension UIImage {
    func encode() throws -> String {
        guard let imageBase64 : String  = self.jpegData(compressionQuality: 1)?.base64EncodedString()
        else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: .init(), debugDescription: "Error encoding base64Image"))
        }
        return imageBase64
    }
    
    static func decode(base64Image: String) throws -> UIImage{
        guard let dataDecoded : Data = Data(base64Encoded: base64Image, options: .ignoreUnknownCharacters)
        else {
            throw EncodingError.invalidValue(base64Image, EncodingError.Context(codingPath: .init(), debugDescription: "Error reading data of base64Image"))
        }
        guard let uiImage = UIImage(data: dataDecoded)
        else {
            throw EncodingError.invalidValue(base64Image, EncodingError.Context(codingPath: .init(), debugDescription: "Error creating UIImage from data"))
        }
        
        return uiImage
    }
}


