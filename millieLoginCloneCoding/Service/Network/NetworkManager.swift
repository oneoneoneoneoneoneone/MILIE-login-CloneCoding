//
//  NetworkManager.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/05.
//

import Foundation

protocol DBNetworkManagerProtocol{
    ///사용자 가입 확인
//    func checkJoinUser(accountKey: String, loginType: LoginType) async throws -> Bool?
    ///db email 일치 검색
    func selectForEmail(email: String) async throws -> [String : User]?
    ///db phone 일치 검색
    func selectForPhone(phone: String) async throws -> [String : User]?
    ///db user 생성
    @discardableResult
    func createUser(user: User) async throws -> String?
}

protocol ServerNetworkManagerProtocol{
    ///naver 유저 정보 가져오기
    func requestNaverLoginData(accessToken: String) async throws -> Response?
    ///localserver customToken 가져오기 (by.kakao)
    func requestToken(loginType: LoginType ,accessToken: String) async throws -> String?
}

class NetworkManager{
    let api = API()
    let naverLoginAPI = NaverLoginAPI()
    let localAPI = LocalAPI()
}

extension NetworkManager: DBNetworkManagerProtocol, ServerNetworkManagerProtocol{
    //MARK: db API
//    func checkJoinUser(accountKey: String, loginType: LoginType) async throws -> Bool?{
//        return try await selectForEmail(email: accountKey)?.filter{$0.value.id == loginType.rawValue}.isEmpty
//    }

    func selectForEmail(email: String) async throws -> [String : User]?{
        guard let url = api.getURLComponents("email", email)?.url else {throw NSError(domain: "query", code: 0)}

        return try await api.getUserData(url: url)
    }

    func selectForPhone(phone: String) async throws -> [String : User]?{
        guard let url = api.getURLComponents("phone", phone)?.url else {throw NSError(domain: "query", code: 0)}
        
        print(url)
        return try await api.getUserData(url: url)
    }

    @discardableResult
    func createUser(user: User) async throws -> String?{
        guard let url = api.getURLComponents()?.url else {throw NSError(domain: "query", code: 0)}
        print(url)
        return try await api.postUserData(url: url, user: user)
    }
    
    //MARK: naver API
    
    func requestNaverLoginData(accessToken: String) async throws -> Response?{
        guard let url = naverLoginAPI.getURLComponents()?.url else {throw NSError(domain: "url", code: 0)}
        print(url)
        
        return try await naverLoginAPI.getNaverLoginData(url: url, accessToken: accessToken)
    }
    
    //MARK: local API
    
    func requestToken(loginType: LoginType ,accessToken: String) async throws -> String?{
        guard let url = localAPI.getURLComponents(path: loginType.rawValue, accessToken: accessToken)?.url else {throw NSError(domain: "url", code: 0)}
        print(url)
        return try await localAPI.getToken(url: url, accessToken: accessToken)
    }
}
