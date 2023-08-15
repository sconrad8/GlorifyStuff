//
//
//  BlogPostDetailViewController.swift
//  GlorifyBlog
//
// Copyright (c) 2023 Glorify
//
//

import UIKit

class BlogPostDetailViewController: UIViewController {
    
    var post: Post!
    var showsFaveButton: Bool = true
    var isFavorited: Bool = false
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Post \(post.id)"
        isFavorited = isPostFavorited(post)
        updateUI()
        
        URLSession.shared.dataTask(with: URL(string: "https://jsonplaceholder.typicode.com/posts/\(post.id)")!, completionHandler: { [weak self] data, response, error in
            if error != nil {
                print(error!)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                self?.post = Post(json: json ?? [:])
                
                DispatchQueue.main.async {
                    self?.updateUI()
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.titleLabel.text = "Error :("
                }
            }
        }).resume()
    }
    
    func isPostFavorited(_ post: Post) -> Bool {
        UserManager.shared.usersFavoritePosts.map { $0.id }.contains(post.id)
    }
    
    func updateUI() {
        self.titleLabel.text = post.title
        self.bodyLabel.text = post.body
        if showsFaveButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: (isFavorited ? "Unfave" : "Fave"),
                style: .done,
                target: self,
                action: (isFavorited ? #selector(removeFromFavorites) : #selector(addToFavorites)))
        }
        
        // Update Favorites tab bar badge
        let numFavoritedPosts = UserManager.shared.usersFavoritePosts.count
        tabBarController?.tabBar.items?[1].badgeValue = numFavoritedPosts == 0 ? nil : String(numFavoritedPosts)
    }
    
    @objc func addToFavorites() {
        isFavorited = true
        UserManager.shared.userDidFavoritePost(post)
        updateUI()
    }
    
    @objc func removeFromFavorites() {
        isFavorited = false
        UserManager.shared.userDidUnfavoritePost(post)
        updateUI()
    }
    
}
