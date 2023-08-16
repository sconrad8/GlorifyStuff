//
//
//  RootTabBarController.swift
//  GlorifyBlog
//
// Copyright (c) 2023 Glorify
//
//

import UIKit

class RootTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObservers()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(favoritedPostsDidChange), name: Notification.Name(rawValue: "GlorifyBlogFavoritesChanged"), object: nil)
    }
    
    @objc
    private func favoritedPostsDidChange() {
        let numFavoritedPosts = UserManager.shared.usersFavoritePosts.count
        tabBar.items?[1].badgeValue = numFavoritedPosts == 0 ? nil : String(numFavoritedPosts)
    }
    
}
