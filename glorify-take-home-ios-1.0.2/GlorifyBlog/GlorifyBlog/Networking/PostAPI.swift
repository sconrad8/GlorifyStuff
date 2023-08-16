//
//
//  UserManager.swift
//  GlorifyBlog
//
// Copyright (c) 2023 Glorify
//
//

import Foundation

protocol PostAPIProvider {
    var favoritePosts: [Post] { get }
    
    func isPostFavorited(postId: Int) -> Bool
    func favorite(post: Post)
    func unfavorite(post: Post)
    func clearFavorites()
}

class PostAPI: PostAPIProvider {
    
    static var shared = PostAPI()
    
    private init() {}
    
    private(set) var favoritePosts: [Post] = [] {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "GlorifyBlogFavoritesChanged"),
                                            object: nil)
        }
    }
    
    func isPostFavorited(postId: Int) -> Bool {
        favoritePosts.contains { $0.id == postId }
    }
    
    func favorite(post: Post) {
        favoritePosts.append(post)
    }
    
    func unfavorite(post: Post) {
        favoritePosts.removeAll { $0.id == post.id }
    }
    
    func clearFavorites() {
        favoritePosts.removeAll()
    }
    
}
