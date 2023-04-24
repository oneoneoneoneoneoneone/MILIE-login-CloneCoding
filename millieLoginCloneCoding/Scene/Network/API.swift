//
//  API.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/05.
//

import Foundation
import FirebaseAuth

struct API{
    static let host = "millie-login-default-rtdb.firebaseio.com"
    
    func getURLComponents(_ queryname: String? = nil, _ queryvalue: String? = nil) -> URLComponents?{
        var components = URLComponents(string: "https://millie-login-default-rtdb.firebaseio.com")
        components?.host = API.host
        components?.path = "/users.json"

        components?.queryItems = [
            URLQueryItem(name: "print", value: "pretty")
        ]
        
        guard let queryname = queryname,
              let queryvalue = queryvalue else {return components}
        
        components?.queryItems!.append(URLQueryItem(name: "orderBy", value: "\"\(queryname)\""))
        components?.queryItems!.append(URLQueryItem(name: "equalTo", value: "\"\(queryvalue)\""))
        
        return components
    }
    
    
    func getUserData(url: URL) async throws -> [String : User]?{
        let urlRequest = URLRequest(url: url)

        //dataTask에 있는 error 리턴 값이 없음.
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let statuseCode = (response as? HTTPURLResponse)?.statusCode,
              (200...299).contains(statuseCode) else {throw NSError(domain: "response", code: 0)}

        let user = try JSONDecoder().decode([String:User].self, from: data)

        return user
    }

    func postUserData(url: URL, user: User) async throws -> String?{
        var urlRequest = try URLRequest(url: url, method: .post)
        urlRequest.httpBody = try JSONEncoder().encode(user)

        //dataTask에 있는 error 리턴 값이 없음.
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let statuseCode = (response as? HTTPURLResponse)?.statusCode,
              (200...299).contains(statuseCode) else {throw NSError(domain: "response", code: 0)}

        let name = try JSONDecoder().decode([String:String].self, from: data).first?.value

        return name
    }
}


