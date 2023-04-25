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

protocol SocialLoginProtocol{
    var currentNonce: String? {get set}
    
    func kakaoLogin(isLogin: Bool, completionHandler: @escaping ((Bool) -> Void))
    
    func naverLogin(isLogin: Bool, accessToken: String, completionHandler: @escaping ((Bool) -> Void))
    
    func facebookLogin(completionHandler: @escaping ((Bool) -> Void))
    func facebookJoin(completionHandler: @escaping ((Bool) -> Void))
    
    func appleLogin(isLogin: Bool, userCode: String, IDToken: String, completionHandler: @escaping ((Bool) -> Void))
    
    func googleLogin(isLogin: Bool, viewController: UIViewController, completionHandler: @escaping ((Bool) -> Void))
}


class SocialLogin{
    
    private var firebaseLogin: FirebaseLoginProtocol?
    private var dbNetworkManager: DBNetworkManagerProtocol?
    private var serverNetworkManager: ServerNetworkManagerProtocol?

    ///로그인 요청마다 생성되는 임의의 문자열
    ///apple login에 사용
    var currentNonce: String?
    
    init(firebaseLogin: FirebaseLoginProtocol? = nil, dbNetworkManager: DBNetworkManagerProtocol? = nil, serverNetworkManager: ServerNetworkManagerProtocol?) {
        self.firebaseLogin = firebaseLogin
        self.dbNetworkManager = dbNetworkManager
        self.serverNetworkManager = serverNetworkManager
    }
}
    
extension SocialLogin: SocialLoginProtocol{
    //MARK: kakao 로그인
    func kakaoLogin(isLogin: Bool, completionHandler: @escaping ((Bool) -> Void)){
        if !UserApi.isKakaoTalkLoginAvailable(){
            //카톡 안깔림
            completionHandler(false)
            return
        }
        
        //accessToken 요청
        self.requestKakaoToken(){accessToken in
            guard accessToken != nil else {
                return
            }
            
            //회원정보 조회
            UserApi.shared.me(){ (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                //회원 여부 확인?
                guard let userEmail = user?.kakaoAccount?.email else {
                    //이메일 동의 재연동 요청
                    UserApi.shared.unlink(){_ in}
                    completionHandler(false)
                    return
                }
                UserApi.shared.logout(){_ in}
                
                Task(priority: .userInitiated){
                    do{
                        //db에서 회원 여부 확인
                        if (try await self.dbNetworkManager?.selectWhereEmail(email: userEmail)?.filter({$0.value.id.rawValue == loginType.kakao.rawValue}).keys.first) == nil{
                            if isLogin{
                                //회원가입 요청 알랏
                                completionHandler(false)
                                return
                            }
                            else{
                                //기존유저가 아니면 - db추가
                                let user = User(id: loginType.kakao, email: userEmail, phone: "", password: "")
                                try await self.dbNetworkManager?.updateUser(user: user)
                                
                            }
                        }
                        
                        //로컬서버에서 토큰 발급
                        guard let customToken = try await self.serverNetworkManager?.requestToken(accessToken: accessToken!) else {return}
                        
                        //로그인
                        self.firebaseLogin?.customLogin(customToken: customToken){result in
                            if result{
                                completionHandler(true)
                            }
                        }
                    }catch{
                        print(error.localizedDescription)
                        return
                    }
                }
            }
        }
    }
    
    ///kakao 로그인 - 카카오톡 계정 인증 요청
    internal func requestKakaoToken(completionHandler: @escaping ((String?) -> Void)){
        // 카카오톡 실행 가능 여부 확인. 토큰 발급
        if (UserApi.isKakaoTalkLoginAvailable()) {
            let cryptography = Cryptography()
            let nonce = cryptography.randomNonceString()
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
                    guard let accessToken = oauthToken?.accessToken else {
                        completionHandler(nil)
                        return
                    }
                    
                    let responseNonce = self.getNonce(idToken: idToken)
                    
                    guard nonce == responseNonce else {
                        print("Invalid state: A login callback was received, but no login request was sent.")
                        completionHandler(nil)
                        return
                    }
                    //                    let credential = OAuthProvider.credential(withProviderID: "kakao.com",
                    //                                                              idToken: idToken,
                    //                                                              rawNonce: nonce) as AuthCredential
                    completionHandler(accessToken)
                }
            }
        }
        else{
            completionHandler(nil)
            return
        }
    }
    
    internal func getNonce(idToken: String) -> String? {
        guard let payLoad = String(idToken.split(separator: ".")[1]).base64Decoded()?.data(using: .utf8) else {return ""}
        let decodePayLoad = try! JSONDecoder().decode(PayLoad.self, from: payLoad)
        let responseNonce = decodePayLoad.nonce
        
        return responseNonce
    }
    
    //MARK: naver 로그인
    func naverLogin(isLogin: Bool, accessToken: String, completionHandler: @escaping ((Bool) -> Void)){
        Task(priority: .userInitiated){
            do{
                //Naver 사용자 프로필 호출 API
                guard let userEmail = try await serverNetworkManager?.requestNaverLoginData(accessToken: accessToken)?.email else {return}
                
                //db에서 회원가입 여부 확인
                guard let dataName = try await dbNetworkManager?.selectWhereEmail(email: userEmail)?.filter({$0.value.id.rawValue == loginType.naver.rawValue}).first?.key else {
                    if isLogin{
                        //회원가입 요청 알랏
                        completionHandler(false)
                        return
                    }
                    else{
                        //기존유저가 아니면 - db추가
                        let user = User(id: loginType.naver, email: userEmail, phone: "", password: "")
                        guard let dataName = try await dbNetworkManager?.updateUser(user: user) else {return}
                        
                        //firebase user 생성
                        firebaseLogin?.createUser(email: userEmail, password: dataName){result in
                            if result{
                                //로그인
                                self.firebaseLogin?.login(email: userEmail, password: dataName){result in
                                    if result{
                                        completionHandler(true)
                                    }
                                }
                            }
                        }
                    }
                    return
                }
                
                //로그인
                self.firebaseLogin?.login(email: userEmail, password: dataName){result in
                    if result{
                        completionHandler(true)
                    }
                }
            }catch{
                print(error.localizedDescription)
                return
            }
        }
    }
    
    //MARK: facebook 로그인
    func facebookLogin(completionHandler: @escaping ((Bool) -> Void)){}
    
    func facebookJoin(completionHandler: @escaping ((Bool) -> Void)) {
        
    }
    
    //MARK: apple 로그인 - 자격증명 생성
    func appleLogin(isLogin: Bool, userCode: String, IDToken: String, completionHandler: @escaping ((Bool) -> Void)){
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        Task(priority: .userInitiated){
            do{
                //db에서 회원가입 여부 확인
                if (try await dbNetworkManager?.selectWhereEmail(email: userCode)?.filter({$0.value.id.rawValue == loginType.apple.rawValue}).first?.key) == nil{
                    if isLogin{
                        //회원가입 요청 알랏
                        completionHandler(false)
                        return
                    }
                    else{
                        //기존유저가 아니면 - db추가
                        let user = User(id: loginType.apple, email: userCode, phone: "", password: "")
                        try await dbNetworkManager?.updateUser(user: user)
                    }
                }
                //자격증명 생성
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: IDToken,
                                                          rawNonce: nonce) as AuthCredential
                
                self.firebaseLogin?.socialLogin(credential: credential){result in
                    if result{
                        completionHandler(true)
                    }
                }
            }catch{
                print(error.localizedDescription)
                return
            }
        }
    }
    
    //MARK: google 로그인 - 자격증명 생성
    func googleLogin(isLogin: Bool, viewController: UIViewController, completionHandler: @escaping ((Bool) -> Void)){
        requestGoogleSignIn(viewController: viewController){ email, credential in
            //db에서 회원 여부 확인
            guard let email = email else {return}
            Task{
                do{
                    if (try await self.dbNetworkManager?.selectWhereEmail(email: email)?.filter({$0.value.id.rawValue == loginType.google.rawValue}).keys.first) == nil{
                        if isLogin{
                            //회원가입 요청 알랏
                            completionHandler(false)
                            return
                        }
                        else{
                            //기존유저가 아니면 - db추가
                            let user = User(id: loginType.google, email: email, phone: "", password: "")
                            try await self.dbNetworkManager?.updateUser(user: user)
                        }
                    }
                    guard let credential = credential else {
                        return
                    }
                    
                    //로그인
                    self.firebaseLogin?.socialLogin(credential: credential){result in
                        if result{
                            completionHandler(true)
                        }
                    }
                }catch{
                    print(error.localizedDescription)
                    return
                }
            }
        }
    }
    
    ///google 로그인 - GoogleSignIn 요청
    internal func requestGoogleSignIn(viewController: UIViewController, completionHandler: @escaping ((String?, AuthCredential?) -> Void)){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            guard error == nil else {
                // ...
                print(error!)
                completionHandler(nil, nil)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                // ...?
                completionHandler(nil, nil)
                return
            }
            
            //로그인 성공
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString) as AuthCredential
            
            completionHandler(user.profile?.email, credential)
        }
    }
}
