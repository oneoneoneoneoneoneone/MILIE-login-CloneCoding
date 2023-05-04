//
//  SocialLogin.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/04.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseCore

protocol SocialLoginProtocol{
    func kakaoLogin(userEmail: String, accessToken: String) async throws
    
    func naverLogin(userEmail: String, accessToken: String) async throws
    
    func facebookLogin(userID: String, idToken: String, nonce: String) async throws
    
    func appleLogin(userCode: String, IdToken: String, nonce: String) async throws
    
    func googleLogin(email: String, idToken: String, accessToken: String) async throws
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
    func kakaoLogin(userEmail: String, accessToken: String) async throws{
        if try await dbNetworkManager?.checkJoinUser(accountKey: userEmail, loginType: LoginType.kakao) == false {
            throw LoginError.notFoundSocialJoinData(key: "카카오")
        }
        //로컬서버에서 토큰 발급
        guard let customToken = try await self.serverNetworkManager?.requestToken(loginType: LoginType.kakao, accessToken: accessToken) else {return}
        
        try await self.firebaseLogin?.customLogin(customToken: customToken)
    }

    func naverLogin(userEmail: String, accessToken: String) async throws {        
        if try await dbNetworkManager?.checkJoinUser(accountKey: userEmail, loginType: LoginType.naver) == false {
            throw LoginError.notFoundSocialJoinData(key: "네이버")
        }
        //로컬서버에서 토큰 발급
        guard let customToken = try await self.serverNetworkManager?.requestToken(loginType: LoginType.naver, accessToken: accessToken) else {return}
        
        try await firebaseLogin?.customLogin(customToken: customToken)
    }
    
    func facebookLogin(userID: String, idToken: String, nonce: String) async throws {
        if try await dbNetworkManager?.checkJoinUser(accountKey: userID, loginType: LoginType.facebook) == false {
            throw LoginError.notFoundSocialJoinData(key: "페이스북")
        }
        //자격증명 생성
        let credential = OAuthProvider.credential(withProviderID: "facebook.com",
                                                  idToken: idToken,
                                                  rawNonce: nonce)
        
        try await firebaseLogin?.socialLogin(credential: credential)
    }
    
    func appleLogin(userCode: String, IdToken: String, nonce: String) async throws {
        if try await dbNetworkManager?.checkJoinUser(accountKey: userCode, loginType: LoginType.apple) == false {
            throw LoginError.notFoundSocialJoinData(key: "애플")
        }
        
        //자격증명 생성
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: IdToken,
                                                  rawNonce: nonce) as AuthCredential

        try await firebaseLogin?.socialLogin(credential: credential)
    }
    
    func googleLogin(email: String, idToken: String, accessToken: String) async throws {
        if try await dbNetworkManager?.checkJoinUser(accountKey: email, loginType: LoginType.google) == false {
            throw LoginError.notFoundSocialJoinData(key: "구글")
        }
        
        //자격증명 생성
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: accessToken) as AuthCredential

        try await firebaseLogin?.socialLogin(credential: credential)
    }
}
