//
//
//  AuthAPI.swift
//  GlorifyBlog
//
// Copyright (c) 2023 Glorify
//
//

import Foundation

protocol AuthAPIProvider {
    var currentUser: User? { get }
    
    func logIn(username: String, password: String, completion: @escaping (Error?) -> Void)
    func logOut()
    func validateCredentials(username: String, password: String) -> Bool
}

class AuthAPI: AuthAPIProvider {
    static var shared = AuthAPI()
    
    var currentUser: User?
    
    private init() {}
    
    func logIn(username: String, password: String, completion: @escaping (Error?) -> Void) {
        guard currentUser == nil else {
            completion(nil)
            return
        }
        
        // Simulate API request
        let valid = validateCredentials(username: username, password: password)
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: DispatchTime.now() + 1.0) { [weak self] in
            if valid {
                self?.currentUser = User(username: username)
                completion(nil)
            } else {
                completion(NSError(domain: "com.glorify", code: 123, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials."]))
            }
        }
    }
    
    func logOut() {
        currentUser = nil
    }
    
    func validateCredentials(username: String, password: String) -> Bool {
        username == "user" && password == "pass"
    }
}
