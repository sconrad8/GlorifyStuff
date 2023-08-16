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
    
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void)
    func fetchPost(_ postId: Int, completion: @escaping (Result<Post, Error>) -> Void)
    
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
    
    // MARK: -
    
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        URLSession.shared.dataTask(with: URL(string: "https://jsonplaceholder.typicode.com/posts")!, completionHandler: { data, response, error in
            if let error {
                print(error)
                completion(.failure(error))
                return
            }
            
            do {
                let jsonArray = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String : Any]]
                let posts = (jsonArray ?? []).compactMap({ json -> Post? in
                    return Post(json: json)
                })
                
                completion(.success(posts))
            } catch {
                print("Error during JSON serialization: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }).resume()
    }
    
    func fetchPost(_ postId: Int, completion: @escaping (Result<Post, Error>) -> Void) {
        URLSession.shared.dataTask(with: URL(string: "https://jsonplaceholder.typicode.com/posts/\(postId)")!, completionHandler: { data, response, error in
            if let error {
                print(error)
                completion(.failure(error))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                
                guard let post = Post(json: json ?? [:]) else {
                    completion(.failure(PostAPIError.deserializationFailed))
                    return
                }
                
                completion(.success(post))
            } catch {
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }).resume()
    }
    
    // MARK: - Favorites
    
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

enum PostAPIError: Error {
    case deserializationFailed
}
