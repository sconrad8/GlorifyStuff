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
    
    private let viewModel: ViewModel
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.numberOfLines = 0
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bindViewModel()
        viewModel.fetchData()
    }
    
    private func setupView() {
        // TODO: Add constraint extensions to clean this up and improve readability. Or just build in SwiftUI :)
        
        view.backgroundColor = .systemBackground
        
        addSubviews()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)
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
