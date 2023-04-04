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

protocol SocialLoginProtocol {
    func kakaoLogin(completionHandler: @escaping ((Bool) -> Void))
    func naverLogin(completionHandler: @escaping ((Bool) -> Void))
    func facebookLogin(completionHandler: @escaping ((Bool) -> Void))
    func appleLogin(IDToken: String, completionHandler: @escaping ((Bool) -> Void))
    func googleLogin(viewController: UIViewController, completionHandler: @escaping ((Bool) -> Void))
    
    func requestGoogleSignIn(viewController: UIViewController, completionHandler: @escaping ((AuthCredential?) -> Void))
}


class SocialLogin: SocialLoginProtocol{
    let firebaseLogin: FirebaseLogin
    
    ///MFA(다중인증) 여부
    ///
    ///소셜로그인 여부인듯?
    var isMFAEnabled = false
    
    ///로그인 요청마다 생성되는 임의의 문자열
    ///apple login에 사용
    var currentNonce: String?
    
    
    init(firebaseLogin: FirebaseLogin) {
        self.firebaseLogin = firebaseLogin
    }
    
    
    func kakaoLogin(completionHandler: @escaping ((Bool) -> Void)){
        // 카카오톡 실행 가능 여부 확인. 토큰 발급
        requestKakaoToken(){credential in
            guard let credential = credential else {
                return completionHandler(false)
            }
            
            self.firebaseLogin.login(credential: credential){result in
                completionHandler(result)
            }
        }
        
        //사용자 정보 확인
//        UserApi.shared.me() {(user, error) in
//            if let error = error {
//                print(error)
//            }
//            else {
//                print("me() success.")
//
//                //do something
//                let user = user?.id
//                //자격증명 생성
//            }
//        }
        
    }
    func naverLogin(completionHandler: @escaping ((Bool) -> Void)){}
    func facebookLogin(completionHandler: @escaping ((Bool) -> Void)){}
    
    ///firebase apple 로그인 - 자격증명 생성
    func appleLogin(IDToken: String, completionHandler: @escaping ((Bool) -> Void)){
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        
        //자격증명 생성
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: IDToken,
                                                  rawNonce: nonce) as AuthCredential
        
        self.firebaseLogin.login(credential: credential){result in
            completionHandler(true)
        }
    }
    
    ///firebase google 로그인 - 자격증명 생성
    func googleLogin(viewController: UIViewController, completionHandler: @escaping ((Bool) -> Void)){
        requestGoogleSignIn(viewController: viewController){ credential in
            guard let credential = credential else {
                return completionHandler(false)
            }
            
            self.firebaseLogin.login(credential: credential){result in
                completionHandler(true)
            }
        }
    }

    ///Kakao 로그인 요청
    internal func requestKakaoToken(completionHandler: @escaping ((AuthCredential?) -> Void)){
        // 카카오톡 실행 가능 여부 확인. 토큰 발급
        if (UserApi.isKakaoTalkLoginAvailable()) {
            let cryptography = Cryptography()
            let nonce = cryptography.randomNonceString()
            
//            UserApi.shared.me() { (user, error) in
//                if let error = error {
//                    print(error)
//                    completionHandler(nil)
//                }
//                else {
//                    if let user = user {
//                        var scopes = [String]()
//                                    if (user.kakaoAccount?.profileNeedsAgreement == true) { scopes.append("profile") }
//                                    if (user.kakaoAccount?.emailNeedsAgreement == true) { scopes.append("account_email") }
////                                    if (user.kakaoAccount?.birthdayNeedsAgreement == true) { scopes.append("birthday") }
////                                    if (user.kakaoAccount?.birthyearNeedsAgreement == true) { scopes.append("birthyear") }
////                                    if (user.kakaoAccount?.genderNeedsAgreement == true) { scopes.append("gender") }
////                                    if (user.kakaoAccount?.phoneNumberNeedsAgreement == true) { scopes.append("phone_number") }
////                                    if (user.kakaoAccount?.ageRangeNeedsAgreement == true) { scopes.append("age_range") }
//                                    if (user.kakaoAccount?.ciNeedsAgreement == true) { scopes.append("account_ci") }
//
//                        if scopes.count > 0 {
                            
                            UserApi.shared.loginWithKakaoTalk(nonce: nonce){(oauthToken, error) in
                                if let error = error {
                                    print(error)
                                    completionHandler(nil)
                                }
                                else {
                                    guard let idToken = oauthToken?.idToken else {
                                        completionHandler(nil)
                                        return
                                    }
                                    
                                    let responseNonce = self.getNonce(idToken: idToken)
                                    
                                    guard nonce == responseNonce else {
                                        print("Invalid state: A login callback was received, but no login request was sent.")
                                        completionHandler(nil)
                                        return
                                    }
                                    
                                    let credential = OAuthProvider.credential(withProviderID: "kakao.com",
                                                                              idToken: idToken,
                                                                              rawNonce: nonce) as AuthCredential
                                    
                                    completionHandler(credential)
                                }
                            }
//                        }
//                    }
//                }
//            }
        }
        else{
            completionHandler(nil)
            return
        }
    }
    
    ///GoogleSignIn 로그인 요청
    internal func requestGoogleSignIn(viewController: UIViewController, completionHandler: @escaping ((AuthCredential?) -> Void)){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [weak self] result, error in
            guard error == nil else {
                // ...
                print(error)
                completionHandler(nil)
                return
            }

            guard let user = result?.user,
            let idToken = user.idToken?.tokenString
            else {
                // ...?
                completionHandler(nil)
                return
            }
            //로그인 성공
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString) as AuthCredential
            
            completionHandler(credential)
        }
    }
    
    func getNonce(idToken: String) -> String? {
        guard let payLoad = String(idToken.split(separator: ".")[1]).base64Decoded()?.data(using: .utf8) else {return ""}
        let decodePayLoad = try! JSONDecoder().decode(PayLoad.self, from: payLoad)
        let responseNonce = decodePayLoad.nonce
        
        return responseNonce
    }
}
