//
//  AddPostViewModel.swift
//  FITstagram
//
//  Created by Václav Kobera on 06.12.2022.
//

import Foundation
import SwiftUI

class AddPostViewModel: ObservableObject {
    @Published private(set) var imageState = ImageState.NotSet
    @Published var author = ""
    @Published private(set) var uploadState : UploadState = UploadState.NotSent
    
    
    @MainActor
    func sendPost(text: String) async {
        if case .NotSet = imageState {
            uploadState = .Error("images cannot be empty")
            return
        }
        
        uploadState = .Loading
        
        
        var request = URLRequest(url: URL(string: "https://fitstagram.ackee.cz/api/feed")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 5
        request.setValue(author, forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(ImageData(text: text, photos: prepareImages()))
        } catch {
            print("json envoding Error", error.localizedDescription)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpresponse = response as? HTTPURLResponse {
                switch httpresponse.statusCode {
                case 500..<1000:
                    uploadState = .Error("server is on fire 🔥 call the 🚒")
                case 300..<500:
                    uploadState = .Error("unexpected API usage - you should check your data 🧐")
                case 200..<300:
                    do {
                        uploadState = .Succes(try JSONDecoder().decode(Post.self, from: data))
                    } catch {
                        uploadState = .Error("Error decoding Server Json after successfull request (got 200)")
                    }
                default:
                    uploadState = .Error("I dont even know what happnd here 🤪")
                }
            } else {
                print("Couldnt convert server response to HTTPURLResponse")
            }
        } catch {
            uploadState = .Error("🤖 Beep Boop, There was error connection fitstagram API, Beep Boop")
            print("Conectiong API error", error)
        }
    }
    
    //TODO move this 3 functions to ImageState it self this is functionality of image state not this viewModel there we should just delegate this work to someone else
    /**
     adds image to start of and array
     */
    func addImage(image: UIImage) {
        switch imageState {
        case .NotSet:
            imageState = .Selected([image])
        case let .Selected(images):
            // adding to start so user can always see the new image in UI (when theres a lot of images the view is scrolling and user cant see pics at the end [yes im not inplementing changin order of images cuz my ass is lazy])
            imageState = .Selected([image] + images)
        }
    }
    
    /**
     removes imege at index from ImageState
     */
    func removeImageAtIndex(index: Int) throws {
        switch imageState{
        case .NotSet:
            throw NSError.init()
        case var .Selected(images):
            if(images.count <= 1){
                imageState = .NotSet
            }
            else {
                images.remove(at: index)
                imageState = .Selected(images)
            }
        }
    }
    
    /**
        resize images from ImageState and convert them to base64
     */
    private func prepareImages() -> [String]{
        switch imageState {
        case .NotSet:
            return []
        case let .Selected(images):
            var base64Images : [String] = []
        
            for image in images {
                do{
                    guard let scaledImage = image.resize(withSize: CGSize(width: 2048, height: 2048), contentMode: .contentAspectFit)
                    else{
                        print("coldnt scale image", image)
                        continue
                    }
                    try base64Images.append(scaledImage.encode())
                }
                catch{
                    print("error encoding", error.localizedDescription)
                }
            }
                        
            return base64Images
        }
    }
    
    func restart (){
        imageState = .NotSet
        author = ""
        uploadState = .NotSent
    }
}


enum ImageState {
    case NotSet
    case Selected([UIImage])
}


enum UploadState {
    case NotSent
    case Loading
    case Succes(Post)
    case Error(String)
}
