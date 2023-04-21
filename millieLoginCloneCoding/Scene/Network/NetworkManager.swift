//
//  NetworkManager.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/05.
//

import Foundation

class NetworkManager{
    let api = API()
    
    func selectAll() async throws -> [String : User]?{
        guard let url = api.getURLComponents().url else {throw NSError(domain: "query", code: 0)}
        
        return try await getUserData(url: url)
    }
    
    func selectWhereEmail(email: String) async throws -> [String : User]?{
        guard let url = api.getURLComponents("email", email).url else {throw NSError(domain: "query", code: 0)}
        
        return try await getUserData(url: url)
    }
    
    func selectWherePhone(phone: String) async throws -> [String : User]?{
        guard let url = api.getURLComponents("phone", phone).url else {throw NSError(domain: "query", code: 0)}
        print(url)
        return try await getUserData(url: url)
    }
    
    func updateUser(user: User) async throws -> String?{//(id: String, phone: String, image: String, name: String, nickName: String, password: String)
        guard let url = api.getURLComponents().url else {throw NSError(domain: "query", code: 0)}
        print(url)
        return try await postUserData(url: url, user: user)
    }
    
    private func getUserData(url: URL) async throws -> [String : User]?{
        let urlRequest = URLRequest(url: url)
        
        //dataTask에 있는 error 리턴 값이 없음.
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let statuseCode = (response as? HTTPURLResponse)?.statusCode,
              (200...299).contains(statuseCode) else {throw NSError(domain: "response", code: 0)}
        
        let user = try JSONDecoder().decode([String:User].self, from: data)//else {throw NSError(domain: "user encoding", code: 0)}
        
        return user
    }
    
    private func postUserData(url: URL, user: User) async throws -> String?{
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
