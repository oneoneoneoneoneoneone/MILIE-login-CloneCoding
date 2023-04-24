//
//  LocalAPI.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/23.
//

import Foundation
import Alamofire

struct LocalAPI{
    func getURLComponents(_ accessToken: String) -> URLComponents?{
        var components = URLComponents(string: "http://\(Bundle.main.getplistValue(path: "APIKey", key: "ip"))):8000")
        components?.path = "/verifyToken"
        
        return components
    }
    
    func getToken(url:URL, accessToken: String) async throws -> String{
        var urlRequest = try URLRequest(url: url, method: .post)
        urlRequest.headers.add(HTTPHeader(name: "Accept", value: "application/json"))
        urlRequest.headers.add(HTTPHeader(name: "Content-Type", value: "application/json"))
        
        urlRequest.httpBody = try JSONEncoder().encode(["token": accessToken]) as Data

        //dataTask에 있는 error 리턴 값이 없음.
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let statuseCode = (response as? HTTPURLResponse)?.statusCode,
              (200...299).contains(statuseCode) else {throw NSError(domain: "response", code: 0)}

        guard let idToken = try JSONDecoder().decode([String:String].self, from: data)["firebase_token"] else {throw NSError(domain: "decode", code: 0)}

        return idToken
    }
}
