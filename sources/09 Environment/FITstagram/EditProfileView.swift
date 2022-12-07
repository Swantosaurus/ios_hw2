import SwiftUI

struct EditProfileView: View {
    @AppStorage("username") var username = ""
    @State var image: UIImage?
    @State var isImagePickerPresented = false

    var body: some View {
        VStack(spacing: 16) {
            Rectangle()
                .fill(.gray)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .clipped()
                .overlay(
                    Button {
                        isImagePickerPresented = true
                    } label: {
                        Circle()
                            .fill(.white)
                            .frame(width: 64, height: 64)
                            .overlay(
                                Image(systemName: "pencil")
                                    .resizable()
                                    .padding()
                            )
                    }
                )

            TextField("Username", text: $username)
                .padding()
        }
        .fullScreenCover(isPresented: $isImagePickerPresented) {
            ImagePicker(
                image: $image,
                isPresented: $isImagePickerPresented
            )
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
