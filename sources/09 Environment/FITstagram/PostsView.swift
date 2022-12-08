//
//  PostsView.swift
//  FITstagram
//
//  Created by Igor Rosocha on 19.10.2022.
//

import SwiftUI

//{
//    "postedAt" : "2022-04-15T08:46:01Z",
//    "text" : "đ¤",
//    "id" : "E7574AAB-2E6F-43EE-A803-1234953DC36A",
//    "photos" : [
//        "https:\/\/fitstagram.ackee.cz:443\/images\/176C9C71-9FB9-47C8-BE0C-27C9700E3A5C.jpg"
//    ],
//    "likes" : [
//
//    ],
//    "numberOfComments" : 0,
//    "author" : {
//        "username" : "zatim_bez_nazvu",
//        "id" : "C455A70A-A20F-4CAB-8940-F260AFB2F4C6"
//    }
//}

struct PostsView: View {
    @State var posts: [Post] = []
    
    @State var path = NavigationPath()
    @State var newPost : Post? = nil
    
    var body: some View {
        
        NavigationStack(path: $path) {
            Group {
                if posts.isEmpty {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .task {
                            await fetchPosts()
                        }
                        
                } else {
                    ZStack {
                        ScrollViewReader { scroller in
                            scrollView
                                .overlay{
                                    addNewPostFloatingButton
                                        
                                }
                                .overlay{
                                    scrollToNewPost(scroller: scroller)
                                }
                        }
                    }
                }
            }
            .navigationDestination(for: String.self) { string in
                Text(string)
            }
            .navigationDestination(for: Int.self) { integer in
                Text("\(integer)")
            }
            .navigationDestination(for: Post.self) { post in
                //               CommentsView(viewModel: CommentsViewModel(postID: post.id))
                PostDetailView(viewModel: PostDetailViewModel(postID: post.id))
            }
            .navigationDestination(for: AddPost.self){ addPost in
                AddPostView(addPostViewModel: AddPostViewModel(),
                            posts: $posts, newPost: $newPost, path: $path)
            }
            .navigationTitle("FITstagram")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    
    private func scrollToNewPost(scroller: ScrollViewProxy) -> some View {
        HStack {
            if(newPost != nil){
                Spacer()
                VStack {
                    Button(action: {
                        scroller.scrollTo(newPost)
                        newPost = nil
                    }) {
                        Image(systemName: "doc")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .frame(width: 44, height: 44)
                            .background(Color.green)
                            .cornerRadius(22)
                    }
                    Spacer()
                }
                .task(waitFiveSec)
            }
        }
        .padding(42)
    }
    
    private var scrollView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem()]) {
                ForEach(posts) { post in
                    PostView(
                        post: post,
                        onCommentsButtonTap: {
                            path.append(post)
                        }
                    )
                    .id(post)
                    .onTapGesture {
                        path.append(post)
                    }
                }
            }
        }
    }
    
    private var addNewPostFloatingButton: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Button(action: {
                    path.append(AddPost())
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .frame(width: 44, height: 44)
                        .background(Color.blue)
                        .cornerRadius(22)
                }
            }
        }
        .padding(42)
    }
        
    private func fetchPosts() async {
        var request = URLRequest(url: URL(string: "https://fitstagram.ackee.cz/api/feed/")!)
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            self.posts = try JSONDecoder().decode([Post].self, from: data)
        } catch {
            print("[ERROR]", error)
        }
    }
    
    @Sendable
    private func waitFiveSec() async {
        do {
            
            try await Task.sleep(for: .seconds(5))
        }
        catch {
            print("try Error", error.localizedDescription)
        }
        newPost = nil
    }
}


/**
    just for navigation to add post screen
 */
struct AddPost: Hashable{}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
