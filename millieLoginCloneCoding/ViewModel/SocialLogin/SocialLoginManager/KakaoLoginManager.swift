//
//  KakaoLoginManager.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/05/04.
//

import Foundation
import UIKit
import KakaoSDKUser
import KakaoSDKCommon
import KakaoSDKAuth

class KakaoLoginManager: NSObject, SocialLoginManagerProtocol {
    private var viewController: UIViewController?
    private var delegate: LoginManagerDelegate?
    private var socialLoginVM: SocialLoginProtocol? = SocialLogin()
    private var socialJoinVM: SocialJoinProtocol? = SocialJoin()
        
    func setSocialLoginPresentationAnchorView(_ viewController: UIViewController?, _ delegate: LoginManagerDelegate?) {
        self.viewController = viewController
        self.delegate = delegate
    }
    
    @MainActor
    func requestLogin() {
        Task{
            do{
                if !UserApi.isKakaoTalkLoginAvailable(){
                    throw LoginError.notInstalledApp(key: "카카오톡")
                }
                
                let accessToken = try await requestKakaoToken()
                guard let userEmail = try await getKakaoAccount()?.email  else {
                    UserApi.shared.unlink(){_ in}
                    throw LoginError.requestAgain(key: "이메일 제공을 동의하지 않으셨습니다. 다시 인증해주세요.")
                }
                
                if viewController is LoginViewController{
                    try await socialLoginVM?.kakaoLogin(userEmail: userEmail, accessToken: accessToken)
                }
                if viewController is JoinViewController{
                    try await socialJoinVM?.kakaoLogin(userEmail: userEmail, accessToken: accessToken)
                }
                delegate?.loginSuccess()
            }
            catch{
                viewController?.presentAlertMessage(message: error.localizedDescription)
            }
        }
    }
    
    ///kakao 로그인 - 카카오톡 계정 인증 요청
    private func requestKakaoToken() async throws -> String {
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
    
    private func getKakaoAccount() async throws -> Account?{
        return try await withCheckedThrowingContinuation{continuation in
            UserApi.shared.me(){ (user, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                continuation.resume(returning: user?.kakaoAccount)
            }
        }
    }
}
