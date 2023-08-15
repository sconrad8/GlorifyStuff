//
//
//  Post.swift
//  GlorifyBlog
//
// Copyright (c) 2023 Glorify
//
//

import Foundation

struct Post {
    
    let id: Int
    let title: String
    let body: String?
    
    init?(json: [String : Any]) {
        self.id = (json["id"] as? Int) ?? -1
        self.title = (json["title"] as? String) ?? ""
        self.body = json["body"] as? String
    }
    
}
