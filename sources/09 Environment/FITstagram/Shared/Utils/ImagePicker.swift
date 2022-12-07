//
//  ImagePicker.swift
//  FITstagram
//
//  Created by Václav Kobera on 07.12.2022.
//

import SwiftUI

struct ImagePickerUIImageSender: UIViewControllerRepresentable {
    let sendImage: (UIImage) -> Void
    @Binding var isPresented: Bool
    let sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = sourceType
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(sendImage: sendImage, isPresented: $isPresented)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let sendImage: (UIImage) -> Void
        @Binding var isPresented: Bool

        init(sendImage: @escaping (UIImage) -> Void, isPresented: Binding<Bool>) {
            self.sendImage = sendImage
            self._isPresented = isPresented
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isPresented = false
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            guard let image = info[.originalImage] as? UIImage
            else {
                print("error info[.originalImage] converting to UIImage")
                return
            }
            
            sendImage(image)
            
            self.isPresented = false
        }
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(

        _ uiViewController: UIImagePickerController,
        context: Context
    ) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(image: $image, isPresented: $isPresented)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var image: UIImage?
        @Binding var isPresented: Bool

        init(image: Binding<UIImage?>, isPresented: Binding<Bool>) {
            self._image = image
            self._isPresented = isPresented
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isPresented = false
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            guard let image = info[.originalImage] as? UIImage else { return }
            
            self.image = image
            self.isPresented = false
        }
    }
}
