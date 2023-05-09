//
//  SocialJoin.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/05/04.
//

import Foundation
import Firebase

protocol SocialLoginProtocol{
    func verifyUserCredentials(email: String, loginType: LoginType) async throws
    
    func checkExistingUserEmail(email: String, loginType: LoginType) async throws
    
    func kakaoLogin(accessToken: String) async throws
    
    func naverLogin(accessToken: String) async throws
    
    func facebookLogin(idToken: String, nonce: String) async throws
    
    func appleLogin(idToken: String, nonce: String) async throws
    
    func googleLogin(idToken: String, accessToken: String) async throws
}

class SocialLogin{
    private var firebaseLogin: FirebaseLoginProtocol?
    private var dbNetworkManager: DBNetworkManagerProtocol?
    private var serverNetworkManager: ServerNetworkManagerProtocol?

    init(firebaseLogin: FirebaseLoginProtocol? = FirebaseLogin(), dbNetworkManager: DBNetworkManagerProtocol? = NetworkManager(), serverNetworkManager: ServerNetworkManagerProtocol? = NetworkManager()) {
        self.firebaseLogin = firebaseLogin
        self.dbNetworkManager = dbNetworkManager
        self.serverNetworkManager = serverNetworkManager
    }
}
    
extension SocialLogin: SocialLoginProtocol{
    ///소셜로그인 회원정보 검증
    func verifyUserCredentials(email: String, loginType: LoginType) async throws{
        if (try await dbNetworkManager?.selectForEmail(email: email)?
            .filter{$0.value.id == loginType.rawValue}
            .isEmpty) == true{
            throw LoginError.notFoundSocialJoinData(key: loginType.rawValue)
        }
    }
    
    ///소셜로그인 회원 여부 확인 -> 회원가입
    func checkExistingUserEmail(email: String, loginType: LoginType) async throws {
        if (try await dbNetworkManager?.selectForEmail(email: email)?
            .filter{$0.value.id == loginType.rawValue}
            .isEmpty) == false{
            throw LoginError.foundJoinData(key: "\(loginType.rawValue) 계정")
        }
        let user = User(id: loginType.rawValue, email: email, phone: "")
        try await self.dbNetworkManager?.createUser(user: user)
    }
    
    func kakaoLogin(accessToken: String) async throws{
        guard let customToken = try await self.serverNetworkManager?.requestToken(loginType: LoginType.kakao, accessToken: accessToken) else {return}
        
        try await self.firebaseLogin?.customLogin(customToken: customToken)
    }
    
    func naverLogin(accessToken: String) async throws {
        guard let customToken = try await self.serverNetworkManager?.requestToken(loginType: LoginType.naver, accessToken: accessToken) else {return}
        
        try await firebaseLogin?.customLogin(customToken: customToken)
    }
    
    func facebookLogin(idToken: String, nonce: String) async throws {
        let credential = OAuthProvider.credential(withProviderID: "facebook.com",
                                                  idToken: idToken,
                                                  rawNonce: nonce)
        
        try await firebaseLogin?.socialLogin(credential: credential)
    }
    
    func appleLogin(idToken: String, nonce: String) async throws {
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idToken,
                                                  rawNonce: nonce) as AuthCredential

        try await firebaseLogin?.socialLogin(credential: credential)
    }
    
    func googleLogin(idToken: String, accessToken: String) async throws {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: accessToken) as AuthCredential

        try await firebaseLogin?.socialLogin(credential: credential)
    }
}

