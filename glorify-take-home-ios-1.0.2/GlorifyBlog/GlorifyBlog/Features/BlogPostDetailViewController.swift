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
}
