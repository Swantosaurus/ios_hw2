//
//  AddImageView.swift
//  FITstagram
//
//  Created by Václav Kobera on 06.12.2022.
//

import SwiftUI

struct AddPostView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject var addPostViewModel : AddPostViewModel
    @State var isImagePickerPresented = false
    //@State var username: String = ""
    @State var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State var text: String = ""
    @Binding var posts: [Post]
    
    var body: some View {
        switch addPostViewModel.uploadState {
        case .NotSent:
            form
        case let .Error(message):
            Text(message)
            Button("Try aagain"){
                addPostViewModel.restart()
            }
        case let .Succes(post):
            Text("Finished with success 🥳")
            Button("Return back"){
                posts.insert(post, at: 0)
                dismiss()
            }.padding(30)
        case .Loading:
            ProgressView()
        }
    }
    
    private var form: some View {
        VStack{
            ScrollView(.horizontal){
                LazyHStack{
                    if case let .Selected(images) = addPostViewModel.imageState {
                        ForEach(images.indices, id: \.self){ index in
                            Image(uiImage: images[index])
                                .resizable()
                                .frame(width: 200, height: 200)
                                .aspectRatio(contentMode: .fit)
                                .overlay {
                                    Button(action: {
                                        do {
                                            try addPostViewModel.removeImageAtIndex(index: index)
                                        } catch {
                                            print("error removing image at index: \(index)")
                                        }
                                    }) {
                                        Image(systemName: "minus")
                                            .foregroundColor(.white)
                                            .font(.system(size: 24))
                                            .frame(width: 42, height: 42)
                                            .background(Color.red)
                                            .cornerRadius(22)
                                    }
                                    .opacity(0.7)
                                    .padding(30)
                                }
                        }
                    }
                }
                .frame(height: 200)
            }
            HStack {
                Button(action: {
                    sourceType = .photoLibrary
                    isImagePickerPresented = true
                }) {
                    Image(systemName: "folder.badge.plus")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .frame(width: 44, height: 44)
                        .background(Color.blue)
                        .cornerRadius(22)
                }
                Button(action: {
                    sourceType = .camera
                    isImagePickerPresented = true
                }){
                    Image(systemName: "camera")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .frame(width: 44, height: 44)
                        .background(Color.blue)
                        .cornerRadius(22)
                }
            }
            
            VStack{
                TextField("Username", text: $addPostViewModel.author)
                TextEditor(text: $text).border(Color.gray, width: 1)
                Button("Send Post") {
                    Task {
                        await addPostViewModel.sendPost(text: text)
                    }
                }
            }.padding()
        }
        .fullScreenCover(isPresented: $isImagePickerPresented){
            ImagePickerUIImageSender(
                sendImage: { image in
                    addPostViewModel.addImage(image: image)
                },
                isPresented: $isImagePickerPresented,
                sourceType: sourceType
            )
        }
    }
}

struct AddImageView_Previews: PreviewProvider {
    @State static var posts: [Post] = []

    static var previews: some View {
        AddPostView(addPostViewModel: AddPostViewModel(), posts: $posts)
    }
}


