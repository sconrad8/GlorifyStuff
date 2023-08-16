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
    
    var viewModel: ViewModel! // TODO: Remove forced cast
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
//    init(viewModel: ViewModel) {
//        self.viewModel = viewModel
//
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        viewModel.fetchData()
    }
    
    private func bindViewModel() {
        viewModel.post.bind { [weak self] post in
            guard let self else { return }
            self.titleLabel.text = post.title
            self.bodyLabel.text = post.body
        }
        
        viewModel.title.bind { [weak self] title in
            self?.title = title
        }
        
        viewModel.isFavorited.bind { [weak self] isFavorited in
            guard let self else { return }
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: (isFavorited ? "Unfave" : "Fave"),
                style: .done,
                target: self,
                action: #selector(self.faveButtonTapped))
        }
    }
    
    @objc
    private func faveButtonTapped() {
        viewModel.updateFavorites()
    }
    
}

// MARK: -

extension BlogPostDetailViewController {
    class ViewModel {
        var post: Bindable<Post>
        var title: Bindable<String>
        var isFavorited: Bindable<Bool>
        
        // TODO: Create UserManager Protocol and pass in as dependency
        init(post: Post) {
            self.post = .init(post)
            self.title = .init("Post \(post.id)")
            self.isFavorited = .init(UserManager.shared.isPostFavorited(postId: post.id))
            
            observeData()
        }
        
        func fetchData() {
            // TODO: Break out networking request into Networking layer
            URLSession.shared.dataTask(with: URL(string: "https://jsonplaceholder.typicode.com/posts/\(post.value.id)")!, completionHandler: { [weak self] data, response, error in
                guard let self else { return }
                
                if error != nil {
                    print(error!)
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                    
                    guard let post = Post(json: json ?? [:]) else {
                        // TODO: Throw error
                        return
                    }
                    DispatchQueue.main.async {
                        self.post.value = post
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.title.value = "Error :("
                    }
                }
            }).resume()
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
            UserManager.shared.userDidFavoritePost(post.value)
        }
        
        private func removeFromFavorites() {
            UserManager.shared.userDidUnfavoritePost(post.value)
        }
        
        @objc
        private func favoritedPostsDidChange() {
            isFavorited.value = UserManager.shared.isPostFavorited(postId: post.value.id)
        }
    }
}
