//
//
//  SceneDelegate.swift
//  GlorifyBlog
//
// Copyright (c) 2023 Glorify
//
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene),
              let rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "RootTabBarController") as? RootTabBarController else {
            return
        }
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        
        self.window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()
    }
}

