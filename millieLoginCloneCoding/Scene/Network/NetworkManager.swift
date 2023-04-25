//
//  NetworkManager.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/05.
//

import Foundation

protocol DBNetworkManagerProtocol{
    ///db 모든 유저
    func selectAll() async throws -> [String : User]?
    ///db email 일치 검색
    func selectWhereEmail(email: String) async throws -> [String : User]?
    ///db phone 일치 검색
    func selectWherePhone(phone: String) async throws -> [String : User]?
    ///db user 생성
    func updateUser(user: User) async throws -> String?
}

protocol ServerNetworkManagerProtocol{
    ///naver 유저 정보 가져오기
    func requestNaverLoginData(accessToken: String) async throws -> Response?
    ///localserver customToken 가져오기 (by.kakao)
    func requestToken(accessToken: String) async throws -> String?
}

class NetworkManager{
    let api = API()
    let naverLoginAPI = NaverLoginAPI()
    let localAPI = LocalAPI()
}

extension NetworkManager: DBNetworkManagerProtocol, ServerNetworkManagerProtocol{
    //MARK: db API
    func selectAll() async throws -> [String : User]?{
        guard let url = api.getURLComponents()?.url else {throw NSError(domain: "query", code: 0)}

        return try await api.getUserData(url: url)
    }

    func selectWhereEmail(email: String) async throws -> [String : User]?{
        guard let url = api.getURLComponents("email", email)?.url else {throw NSError(domain: "query", code: 0)}

        return try await api.getUserData(url: url)
    }

    func selectWherePhone(phone: String) async throws -> [String : User]?{
        guard let url = api.getURLComponents("phone", phone)?.url else {throw NSError(domain: "query", code: 0)}
        print(url)
        return try await api.getUserData(url: url)
    }

    func updateUser(user: User) async throws -> String?{
        guard let url = api.getURLComponents()?.url else {throw NSError(domain: "query", code: 0)}
        print(url)
        return try await api.postUserData(url: url, user: user)
    }
    
    //MARK: naver API
    func requestNaverLoginData(accessToken: String) async throws -> Response?{
        guard let url = naverLoginAPI.getURLComponents(accessToken)?.url else {throw NSError(domain: "url", code: 0)}
        print(url)
        
        return try await naverLoginAPI.getNaverLoginData(url: url, accessToken: accessToken)
    }
    
    //MARK: local API
    func requestToken(accessToken: String) async throws -> String?{
        guard let url = localAPI.getURLComponents(accessToken)?.url else {throw NSError(domain: "url", code: 0)}
        print(url)
        return try await localAPI.getToken(url: url, accessToken: accessToken)
    }
}
