//
//
//  BlogPostDetailViewModel.swift
//  GlorifyBlog
//
// Copyright (c) 2023 Glorify
//
//

// TODO: Add Unit Tests

import Foundation

class BlogPostDetailViewModel {
    var post: Bindable<Post>
    var title: Bindable<String>
    var isFavorited: Bindable<Bool>
    
    private let postAPI: PostAPIProvider
    
    init(post: Post, postAPI: PostAPIProvider = PostAPI.shared) {
        self.post = .init(post)
        self.title = .init("Post \(post.id)")
        self.isFavorited = .init(postAPI.isPostFavorited(postId: post.id))
        self.postAPI = postAPI
        
        observeData()
    }
    
    func fetchData() {
        postAPI.fetchPost(post.value.id) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case let .success(post):
                    self.post.value = post
                case .failure:
                    self.title.value = "Error :("
                }
            }
        }
    }
    
    private func observeData() {
        // Ensures this view remains up-to-date when changing favorite from another screen
        NotificationCenter.default.addObserver(self, selector: #selector(favoritedPostsDidChange), name: Notification.Name(rawValue: "GlorifyBlogFavoritesChanged"), object: nil)
    }
    
    func updateFavorites() {
        if isFavorited.value {
            removeFromFavorites()
        } else {
            addToFavorites()
        }
    }
    
    private func addToFavorites() {
        postAPI.favorite(post: post.value)
    }
    
    private func removeFromFavorites() {
        postAPI.unfavorite(post: post.value)
    }
    
    @objc
    private func favoritedPostsDidChange() {
        isFavorited.value = postAPI.isPostFavorited(postId: post.value.id)
    }
}
