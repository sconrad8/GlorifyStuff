//
//
//  UserManager.swift
//  GlorifyBlog
//
// Copyright (c) 2023 Glorify
//
//

import Foundation

class UserManager {
    
    static var shared = UserManager()
    
    var currentUser: User?
    var usersFavoritePosts: [Post] = []
    
    func logIn(username: String, password: String, completion: @escaping (Error?) -> Void) {
        guard currentUser == nil else {
            completion(nil)
            return
        }
        
        // Simulate API request
        let valid = validateCredentials(username: username, password: password)
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: DispatchTime.now() + 1.0) { [weak self] in
            if valid {
                self?.currentUser = User(username: username)
                completion(nil)
            } else {
                completion(NSError(domain: "com.glorify", code: 123, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials."]))
            }
        }
    }
    
    func validateCredentials(username: String, password: String) -> Bool {
        username == "user" && password == "pass"
    }
    
    func isPostFavorited(postId: Int) -> Bool {
        usersFavoritePosts.contains { $0.id == postId }
    }
    
    func userDidFavoritePost(_ post: Post) {
        usersFavoritePosts.append(post)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "GlorifyBlogFavoritesChanged"),
                                        object: nil)
    }
    
    func userDidUnfavoritePost(_ post: Post) {
        usersFavoritePosts.removeAll { $0.id == post.id }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "GlorifyBlogFavoritesChanged"),
                                        object: nil)
    }
    
}
