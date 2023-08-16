//
//
//  BlogPostListViewController.swift
//  GlorifyBlog
//
// Copyright (c) 2023 Glorify
//
//

import UIKit

class BlogPostListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LogInViewControllerDelegate {
    
    private let authAPI: AuthAPIProvider = AuthAPI.shared
    private let postAPI: PostAPIProvider = PostAPI.shared
    var posts: [Post] = []
    
    @IBOutlet weak var tableView: UITableView!
    var loadingIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .done, target: self, action: #selector(logOut))
        
        NotificationCenter.default.addObserver(self, selector: #selector(favoritedPostsDidChange), name: Notification.Name(rawValue: "GlorifyBlogFavoritesChanged"), object: nil)
        
        if authAPI.currentUser == nil {
            navigateToLogIn()
        }
    }
    
    func logInViewControllerDidLogIn() {
        navigationItem.title = "Welcome, \(authAPI.currentUser!.username)!"
        showLoadingIndicator(true)
        
        URLSession.shared.dataTask(with: URL(string: "https://jsonplaceholder.typicode.com/posts")!, completionHandler: { [weak self] data, response, error in
            if error != nil {
                print(error!)
                return
            }
            
            do {
                let jsonArray = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String : Any]]
                let posts = (jsonArray ?? []).compactMap({ json -> Post? in
                    return Post(json: json)
                })
                self?.posts = posts
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.showLoadingIndicator(false)
                }
            } catch {
                print("Error during JSON serialization: \(error.localizedDescription)")
            }
        }).resume()
    }
    
    @objc func favoritedPostsDidChange() {
        tableView.reloadData()
    }
    
    @objc func logOut() {
        authAPI.logOut()
        postAPI.clearFavorites()
        navigateToLogIn()
    }
    
    func navigateToLogIn() {
        let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
        loginViewController.modalPresentationStyle = .overFullScreen
        loginViewController.delegate = self
        navigationController?.present(loginViewController, animated: true, completion: nil)
    }
    
    func showLoadingIndicator(_ shouldShow: Bool) {
        if shouldShow {
            let loadingIndicator = UIActivityIndicatorView(style: .large)
            loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(loadingIndicator)
            NSLayoutConstraint.activate([
                loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            view.bringSubviewToFront(loadingIndicator)
            loadingIndicator.startAnimating()
            self.loadingIndicator = loadingIndicator
        } else {
            loadingIndicator?.stopAnimating()
            loadingIndicator?.removeFromSuperview()
            loadingIndicator = nil
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let post = posts[indexPath.row]
        cell.textLabel?.text = post.title
        cell.backgroundColor = postAPI.isPostFavorited(postId: post.id) ? UIColor(red: 239/255, green: 189/255, blue: 102/255, alpha: 1) : .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let postDetailViewController = BlogPostDetailViewController(viewModel: .init(post: post))
        navigationController?.pushViewController(postDetailViewController, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
