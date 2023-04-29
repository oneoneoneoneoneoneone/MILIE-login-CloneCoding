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
import GoogleSignIn
import AuthenticationServices
import KakaoSDKUser
import KakaoSDKCommon
import KakaoSDKAuth
import NaverThirdPartyLogin
import FacebookLogin

protocol SocialLoginProtocol{
    var currentNonce: String? {get set}
    
    func kakaoLogin(isLogin: Bool) async throws
    
    func naverLogin(isLogin: Bool, accessToken: String) async throws
    
    func facebookLogin(isLogin: Bool, userID: String, idToken: String) async throws
    
    func appleLogin(isLogin: Bool, userCode: String, IDToken: String) async throws
    
    func googleLogin(isLogin: Bool, viewController: UIViewController?) async throws
}


class SocialLogin{
    
    private var firebaseLogin: FirebaseLoginProtocol?
    private var dbNetworkManager: DBNetworkManagerProtocol?
    private var serverNetworkManager: ServerNetworkManagerProtocol?

    ///로그인 요청마다 생성되는 임의의 문자열
    ///apple login에 사용
    var currentNonce: String?
    
    init(firebaseLogin: FirebaseLoginProtocol? = FirebaseLogin(), dbNetworkManager: DBNetworkManagerProtocol? = NetworkManager(), serverNetworkManager: ServerNetworkManagerProtocol? = NetworkManager()) {
        self.firebaseLogin = firebaseLogin
        self.dbNetworkManager = dbNetworkManager
        self.serverNetworkManager = serverNetworkManager
    }
}
    
extension SocialLogin: SocialLoginProtocol{
    //MARK: kakao 로그인
    
    func kakaoLogin(isLogin: Bool) async throws{
        if !UserApi.isKakaoTalkLoginAvailable(){
            throw LoginError.notInstalledApp(key: "카카오톡")
        }
        
        let accessToken = try await requestKakaoToken()
        let kakaoAccount = try await requestKakaoAccount()
        
        //이메일이 안들어오면 연결 끊기
        guard let userEmail = kakaoAccount?.email else {
            UserApi.shared.unlink(){_ in}
            throw LoginError.requestAgain(key: "이메일 제공을 동의하지 않으셨습니다. 다시 인증해주세요.")
        }
            
        //db에서 회원 여부 확인
        if (try await self.dbNetworkManager?.selectWhereEmail(email: userEmail)?.filter({$0.value.id == loginType.kakao.rawValue}).keys.first) == nil{
            if isLogin{
                throw LoginError.notFoundSocialJoinData(key: "카카오")
            }
            else{
                //기존유저가 아니면 - db추가
                let user = User(id: loginType.kakao.rawValue, email: userEmail, phone: "", password: "")
                try await self.dbNetworkManager?.updateUser(user: user)
            }
        }
        //회원가입 정보가 있음
        if !isLogin{
            throw LoginError.foundJoinData(key: "카카오 계정")
        }
        
        //로컬서버에서 토큰 발급
        guard let customToken = try await self.serverNetworkManager?.requestToken(loginType: loginType.kakao, accessToken: accessToken) else {return}
        
        //로그인
        try await self.firebaseLogin?.customLogin(customToken: customToken)
    }
    
    ///kakao 로그인 - 카카오톡 계정 인증 요청
    internal func requestKakaoToken() async throws -> String {
        let nonce = Cryptography.randomNonceString()
        
        let oauthToken: OAuthToken? = try await withCheckedThrowingContinuation{continuation in
            UserApi.shared.loginWithKakaoTalk(nonce: nonce){(oauthToken, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                continuation.resume(returning: oauthToken)
            }
        }
        
        guard let idToken = oauthToken?.idToken else {
            throw LoginError.nilData(key: "idToken")
        }
        
        guard nonce == Cryptography.getNonce(idToken: idToken) else {
            throw LoginError.discrepancyData(key: "nonce")
        }
        
        guard let accessToken = oauthToken?.accessToken else {
            throw LoginError.nilData(key: "accessToken")
        }
        
        return accessToken
    }
    
    internal func requestKakaoAccount() async throws -> Account?{
        return try await withCheckedThrowingContinuation{continuation in
            UserApi.shared.me(){ (user, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                continuation.resume(returning: user?.kakaoAccount)
            }
        }
    }

    
    //MARK: naver 로그인
    func naverLogin(isLogin: Bool, accessToken: String) async throws {
        //Naver 사용자 프로필 호출 API
        guard let userEmail = try await serverNetworkManager?.requestNaverLoginData(accessToken: accessToken)?.email else {return}
        
        //db에서 회원 여부 확인
        if (try await self.dbNetworkManager?.selectWhereEmail(email: userEmail)?.filter({$0.value.id == loginType.naver.rawValue}).keys.first) == nil{
            if isLogin{
                throw LoginError.notFoundSocialJoinData(key: "네이버")
            }
            else{
                //기존유저가 아니면 - db추가
                let user = User(id: loginType.naver.rawValue, email: userEmail, phone: "", password: "")
                try await self.dbNetworkManager?.updateUser(user: user)
            }
        }
        //회원가입 정보가 있음
        if !isLogin{
            throw LoginError.foundJoinData(key: "네이버 계정")
        }
        
        //로컬서버에서 토큰 발급
        guard let customToken = try await self.serverNetworkManager?.requestToken(loginType: loginType.naver, accessToken: accessToken) else {return}
        
        //로그인
        try await firebaseLogin?.customLogin(customToken: customToken)
    }
    
    //MARK: facebook 로그인
    func facebookLogin(isLogin: Bool, userID: String, idToken: String) async throws {
        guard let nonce = currentNonce else {
            throw LoginError.discrepancyData(key: "nonce")
        }
        
        //회원가입 정보가 없음
        if (try await dbNetworkManager?.selectWhereEmail(email: userID)?.filter({$0.value.id == loginType.facebook.rawValue}).first?.key) == nil{
            if isLogin{
                throw LoginError.notFoundSocialJoinData(key: "페이스북")
            }
            else{
                let user = User(id: loginType.facebook.rawValue, email: userID, phone: "", password: "")
                try await dbNetworkManager?.updateUser(user: user)
            }
        }
        //회원가입 정보가 있음
        if !isLogin{
            throw LoginError.foundJoinData(key: "페이스북 계정")
        }
        
        //자격증명 생성
        let credential = OAuthProvider.credential(withProviderID: "facebook.com",
                                                  idToken: idToken,
                                                  rawNonce: nonce)
        
        //로그인
        try await firebaseLogin?.socialLogin(credential: credential)
    }
    
    
    //MARK: apple 로그인 - 자격증명 생성
    func appleLogin(isLogin: Bool, userCode: String, IDToken: String) async throws {
        guard let nonce = currentNonce else {
            throw LoginError.discrepancyData(key: "nonce")
        }
        
        //db에서 회원가입 여부 확인
        if (try await dbNetworkManager?.selectWhereEmail(email: userCode)?.filter({$0.value.id == loginType.apple.rawValue}).first?.key) == nil{
            if isLogin{
                throw LoginError.notFoundSocialJoinData(key: "애플")
            }
            else{
                //기존유저가 아니면 - db추가
                let user = User(id: loginType.apple.rawValue, email: userCode, phone: "", password: "")
                try await dbNetworkManager?.updateUser(user: user)
            }
        }
        //회원가입 정보가 있음
        if !isLogin{
            throw LoginError.foundJoinData(key: "애플 계정")
        }
        
        //자격증명 생성
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: IDToken,
                                                  rawNonce: nonce) as AuthCredential
        //로그인
        try await firebaseLogin?.socialLogin(credential: credential)
    }
    
    //MARK: google 로그인 - 자격증명 생성
    func googleLogin(isLogin: Bool, viewController: UIViewController?) async throws {
        guard let viewController = viewController else {return}
        let signInResult = try await requestGoogleSignIn(viewController: viewController)
                
        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw LoginError.nilData(key: "idToken")
        }
        guard let email = signInResult.user.profile?.email else {
            throw LoginError.nilData(key: "email")
        }
        let accessToken = signInResult.user.accessToken.tokenString
            
        //db에서 회원 여부 확인
        if (try await self.dbNetworkManager?.selectWhereEmail(email: email)?.filter({$0.value.id == loginType.google.rawValue}).keys.first) == nil{
            if isLogin{
                throw LoginError.notFoundSocialJoinData(key: "구글")
            }
            else{
                //기존유저가 아니면 - db추가
                let user = User(id: loginType.google.rawValue, email: email, phone: "", password: "")
                try await self.dbNetworkManager?.updateUser(user: user)
            }
        }
        //회원가입 정보가 있음
        if !isLogin{
            throw LoginError.foundJoinData(key: "구글 계정")
        }
        
        //자격증명 생성
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: accessToken) as AuthCredential
        //로그인
        try await firebaseLogin?.socialLogin(credential: credential)
    }
    
    ///google 로그인 - GoogleSignIn 요청
    internal func requestGoogleSignIn(viewController: UIViewController) async throws -> GIDSignInResult{
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw LoginError.nilData(key: "clientId")
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        return try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
    }
}
