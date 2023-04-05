//
//  NetworkManager.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/05.
//

import Foundation

class NetworkManager{
    let api = API()
    
    func selectAll() async throws -> [String : User]!{
        guard let url = api.getURLComponents().url else {throw NSError(domain: "query", code: 0)}
        
        return try await fetchUser(url: url)
    }
    
    func selectWhereEmail(email: String) async throws -> [String : User]!{
        guard let url = api.getURLComponents("email", email).url else {throw NSError(domain: "query", code: 0)}
        
        return try await fetchUser(url: url)
    }
    func selectWherePhone(phone: String) async throws -> [String : User]!{
        guard let url = api.getURLComponents("phone", phone).url else {throw NSError(domain: "query", code: 0)}
        print(url)
        return try await fetchUser(url: url)
    }
    
    private func fetchUser(url: URL) async throws -> [String : User]!{
        let urlRequest = URLRequest(url: url)
        
        //dataTask에 있는 error 리턴 값이 없음.
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let statuseCode = (response as? HTTPURLResponse)?.statusCode,
              (200...299).contains(statuseCode) else {throw NSError(domain: "response", code: 0)}
        
        let user = try JSONDecoder().decode([String:User].self, from: data)//else {throw NSError(domain: "user encoding", code: 0)}
        
        return user
    }
}
