//
//  API.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/05.
//

import Foundation
import FirebaseAuth

struct API{
    static let scheme = "https"
    static let host = "millie-login-default-rtdb.firebaseio.com"
    
    
    func getIdToken(completionHandler: @escaping ((String) -> Void)){
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error.localizedDescription)
                return;
            }
            guard let idToken = idToken else {
                return
            }
            
            completionHandler(idToken)
        }
    }
    
    func getURLComponents(_ queryname: String! = nil, _ queryvalue: String! = nil) -> URLComponents{
        var components = URLComponents()
        components.scheme = API.scheme
        components.host = API.host
        components.path = "/users.json"
        
        components.queryItems = [
            URLQueryItem(name: "print", value: "pretty"),
            URLQueryItem(name: "orderBy", value: "\"\(queryname!)\""),
            URLQueryItem(name: "equalTo", value: "\"\(queryvalue!)\"")
        ]
        return components
    }
}
