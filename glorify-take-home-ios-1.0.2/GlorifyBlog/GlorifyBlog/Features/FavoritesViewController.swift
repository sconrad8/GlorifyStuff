//
//
//  FavoritesViewController.swift
//  GlorifyBlog
//
// Copyright (c) 2023 Glorify
//
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let postAPI: PostAPIProvider = PostAPI.shared
    
    var posts: [Post] {
        postAPI.favoritePosts
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Faves (\(posts.count))"
        tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(favoritedPostsDidChange), name: Notification.Name(rawValue: "GlorifyBlogFavoritesChanged"), object: nil)
    }
    
    @objc func favoritedPostsDidChange() {
        navigationItem.title = "Faves (\(posts.count))"
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = posts[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BlogPostDetailViewController") as! BlogPostDetailViewController
        let post = posts[indexPath.row]
        postDetailViewController.viewModel = .init(post: post)
        navigationController?.pushViewController(postDetailViewController, animated: true)
    }
    
}
