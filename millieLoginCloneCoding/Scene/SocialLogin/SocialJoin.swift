//
//  SocialJoin.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/05/04.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseCore

protocol SocialJoinProtocol{
    func kakaoLogin(userEmail: String, accessToken: String) async throws
    
    func naverLogin(userEmail: String, accessToken: String) async throws
    
    func facebookLogin(userID: String, idToken: String, nonce: String) async throws
    
    func appleLogin(userCode: String, IdToken: String, nonce: String) async throws
    
    func googleLogin(email: String, idToken: String, accessToken: String) async throws
}

class SocialJoin{
    private var firebaseLogin: FirebaseLoginProtocol?
    private var dbNetworkManager: DBNetworkManagerProtocol?
    private var serverNetworkManager: ServerNetworkManagerProtocol?

    init(firebaseLogin: FirebaseLoginProtocol? = FirebaseLogin(), dbNetworkManager: DBNetworkManagerProtocol? = NetworkManager(), serverNetworkManager: ServerNetworkManagerProtocol? = NetworkManager()) {
        self.firebaseLogin = firebaseLogin
        self.dbNetworkManager = dbNetworkManager
        self.serverNetworkManager = serverNetworkManager
    }
}
    
extension SocialJoin: SocialJoinProtocol{    
    func kakaoLogin(userEmail: String, accessToken: String) async throws{
        if try await dbNetworkManager?.checkJoinUser(accountKey: userEmail, loginType: LoginType.kakao) == true {
            throw LoginError.foundJoinData(key: "카카오 계정")
        }
        let user = User(id: LoginType.kakao.rawValue, email: userEmail, phone: "", password: "")
        try await self.dbNetworkManager?.updateUser(user: user)
        
        //로컬서버에서 토큰 발급
        guard let customToken = try await self.serverNetworkManager?.requestToken(loginType: LoginType.kakao, accessToken: accessToken) else {return}
        
        try await self.firebaseLogin?.customLogin(customToken: customToken)
    }
    
    func naverLogin(userEmail: String, accessToken: String) async throws {
        if try await dbNetworkManager?.checkJoinUser(accountKey: userEmail, loginType: LoginType.naver) == true {
            throw LoginError.foundJoinData(key: "네이버 계정")
        }
        
        let user = User(id: LoginType.naver.rawValue, email: userEmail, phone: "", password: "")
        try await self.dbNetworkManager?.updateUser(user: user)

        //로컬서버에서 토큰 발급
        guard let customToken = try await self.serverNetworkManager?.requestToken(loginType: LoginType.naver, accessToken: accessToken) else {return}
        
        try await firebaseLogin?.customLogin(customToken: customToken)
    }
    
    func facebookLogin(userID: String, idToken: String, nonce: String) async throws {        
        if try await dbNetworkManager?.checkJoinUser(accountKey: userID, loginType: LoginType.facebook) == true {
            throw LoginError.foundJoinData(key: "페이스북 계정")
        }
        
        let user = User(id: LoginType.facebook.rawValue, email: userID, phone: "", password: "")
        try await dbNetworkManager?.updateUser(user: user)
        
        //자격증명 생성
        let credential = OAuthProvider.credential(withProviderID: "facebook.com",
                                                  idToken: idToken,
                                                  rawNonce: nonce)
        
        try await firebaseLogin?.socialLogin(credential: credential)
    }
    
    func appleLogin(userCode: String, IdToken: String, nonce: String) async throws {
        if try await dbNetworkManager?.checkJoinUser(accountKey: userCode, loginType: LoginType.apple) == true {
            throw LoginError.foundJoinData(key: "애플 계정")
        }
        
        let user = User(id: LoginType.apple.rawValue, email: userCode, phone: "", password: "")
        try await dbNetworkManager?.updateUser(user: user)

        //자격증명 생성
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: IdToken,
                                                  rawNonce: nonce) as AuthCredential

        try await firebaseLogin?.socialLogin(credential: credential)
    }
    
    func googleLogin(email: String, idToken: String, accessToken: String) async throws {
        if try await dbNetworkManager?.checkJoinUser(accountKey: email, loginType: LoginType.google) == true {
            throw LoginError.foundJoinData(key: "구글 계정")
        }
        
        let user = User(id: LoginType.google.rawValue, email: email, phone: "", password: "")
        try await self.dbNetworkManager?.updateUser(user: user)

        //자격증명 생성
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: accessToken) as AuthCredential

        try await firebaseLogin?.socialLogin(credential: credential)
    }
}
