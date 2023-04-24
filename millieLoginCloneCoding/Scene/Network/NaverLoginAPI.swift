//
//  NaverLoginAPI.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/23.
//

import Foundation
import Alamofire

struct NaverLoginAPI{
    static let host = "openapi.naver.com"
    
    func getURLComponents(_ accessToken: String) -> URLComponents?{
        var components = URLComponents(string: "https://openapi.naver.com")
        components?.host = NaverLoginAPI.host
        components?.path = "/v1/nid/me"
        
        return components
    }
    
    func getNaverLoginData(url: URL, accessToken: String) async throws -> Response?{
        var urlRequest = URLRequest(url: url)
        urlRequest.headers.add(HTTPHeader(name: "X-Naver-Client-Id", value: Bundle.main.getplistValue(path: "APIKey", key: "Naver-Consumer-Key")))
        urlRequest.headers.add(HTTPHeader(name: "X-Naver-Client-Secret", value: Bundle.main.getplistValue(path: "APIKey", key: "Naver-Consumer-Secret")))
        urlRequest.headers.add(HTTPHeader(name: "Authorization", value: "Bearer \(accessToken)"))

        //dataTask에 있는 error 리턴 값이 없음.
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let statuseCode = (response as? HTTPURLResponse)?.statusCode,
              (200...299).contains(statuseCode) else {throw NSError(domain: "response", code: 0)}

        let userData = try JSONDecoder().decode(Welcome.self, from: data).response

        return userData
    }
}
