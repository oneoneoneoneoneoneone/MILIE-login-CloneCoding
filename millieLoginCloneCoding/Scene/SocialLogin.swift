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
            throw NSError(domain: "카카오톡이 설치되지 않았습니다.", code: 0)
        }
        
        //kakao accessToken 요청
        let accessToken = try await requestKakaoToken()
        
        //kakao 회원정보 조회
        let kakaoAccount: Account? = try await withCheckedThrowingContinuation{continuation in
            UserApi.shared.me(){ (user, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                continuation.resume(returning: user?.kakaoAccount)
            }
        }
        
        //이메일이 안들어오면 연결 끊기
        guard let userEmail = kakaoAccount?.email else {
            UserApi.shared.unlink(){_ in}
            throw NSError(domain: "이메일 동의 요청", code: 0)
        }
            
        //db에서 회원 여부 확인
        if (try await self.dbNetworkManager?.selectWhereEmail(email: userEmail)?.filter({$0.value.id == loginType.kakao.rawValue}).keys.first) == nil{
            if isLogin{
                throw NSError(domain: "카카오톡 계정으로 가입 된 정보가 없습니다.", code: 0)
            }
            else{
                //기존유저가 아니면 - db추가
                let user = User(id: loginType.kakao.rawValue, email: userEmail, phone: "", password: "")
                try await self.dbNetworkManager?.updateUser(user: user)
            }
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
            throw NSError(domain: "idToken nil", code: 0)
        }
        
        guard nonce == Cryptography.getNonce(idToken: idToken) else {
            throw NSError(domain: "nonce discrepancy", code: 0)
        }
        
        guard let accessToken = oauthToken?.accessToken else {
            throw NSError(domain: "accessToken nil", code: 0)
        }
        
        return accessToken
    }
    

    
    //MARK: naver 로그인
    func naverLogin(isLogin: Bool, accessToken: String) async throws {
        //Naver 사용자 프로필 호출 API
        guard let userEmail = try await serverNetworkManager?.requestNaverLoginData(accessToken: accessToken)?.email else {return}
        
        //db에서 회원 여부 확인
        if (try await self.dbNetworkManager?.selectWhereEmail(email: userEmail)?.filter({$0.value.id == loginType.kakao.rawValue}).keys.first) == nil{
            if isLogin{
                throw NSError(domain: "네이버 계정으로 가입 된 정보가 없습니다.", code: 0)
            }
            else{
                //기존유저가 아니면 - db추가
                let user = User(id: loginType.naver.rawValue, email: userEmail, phone: "", password: "")
                try await self.dbNetworkManager?.updateUser(user: user)
            }
        }
        
        //로컬서버에서 토큰 발급
        guard let customToken = try await self.serverNetworkManager?.requestToken(loginType: loginType.naver, accessToken: accessToken) else {return}
        
        //로그인
        try await firebaseLogin?.customLogin(customToken: customToken)
    }
    
    //MARK: facebook 로그인
    func facebookLogin(isLogin: Bool, userID: String, idToken: String) async throws {
        guard let nonce = currentNonce else {
            throw NSError(domain: "nonce discrepancy", code: 0)
        }
        
        //db에서 회원가입 여부 확인
        if (try await dbNetworkManager?.selectWhereEmail(email: userID)?.filter({$0.value.id == loginType.apple.rawValue}).first?.key) == nil{
            if isLogin{
                throw NSError(domain: "페이스북 계정으로 가입 된 정보가 없습니다.", code: 0)
            }
            else{
                //기존유저가 아니면 - db추가
                let user = User(id: loginType.facebook.rawValue, email: userID, phone: "", password: "")
                try await dbNetworkManager?.updateUser(user: user)
            }
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
            throw NSError(domain: "nonce discrepancy", code: 0)
        }
        
        //db에서 회원가입 여부 확인
        if (try await dbNetworkManager?.selectWhereEmail(email: userCode)?.filter({$0.value.id == loginType.apple.rawValue}).first?.key) == nil{
            if isLogin{
                throw NSError(domain: "애플 계정으로 가입 된 정보가 없습니다.", code: 0)
            }
            else{
                //기존유저가 아니면 - db추가
                let user = User(id: loginType.apple.rawValue, email: userCode, phone: "", password: "")
                try await dbNetworkManager?.updateUser(user: user)
            }
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
            throw NSError(domain: "idToken nil", code: 0)
        }
        guard let email = signInResult.user.profile?.email else {
            throw NSError(domain: "email nil", code: 0)
        }
        let accessToken = signInResult.user.accessToken.tokenString
            
        //db에서 회원 여부 확인
        if (try await self.dbNetworkManager?.selectWhereEmail(email: email)?.filter({$0.value.id == loginType.google.rawValue}).keys.first) == nil{
            if isLogin{
                throw NSError(domain: "구글 계정으로 가입 된 정보가 없습니다.", code: 0)
            }
            else{
                //기존유저가 아니면 - db추가
                let user = User(id: loginType.google.rawValue, email: email, phone: "", password: "")
                try await self.dbNetworkManager?.updateUser(user: user)
            }
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
            throw NSError(domain: "clientID nil", code: 0)
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        return try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
    }
}
