//
//  LoginViewModel.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/28.
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

protocol FirebaseLoginProtocol {
    ///로그인 여부 확인
    func checkLogin() -> Bool
    
    ///firebase 로그인 - 기본로그인(휴대폰)
    func login(phone: String, password: String, completionHandler: @escaping ((Bool) -> Void))
    
    ///firebase 로그인 - 기본로그인(이메일)
    func login(email: String, password: String, completionHandler: @escaping ((Bool) -> Void))
    
    ///firebase 로그인 - 소셜인증
    func socialLogin(credential: AuthCredential, completionHandler: @escaping ((Bool) -> Void))
    
    ///firebase 커스텀 토큰 인증
    func customLogin(customToken: String, completionHandler: @escaping ((Bool) -> Void))
    
    ///firebase 로그아웃
    func logout() -> Bool
    
    ///회원가입 여부 확인
    func checkJoin(phone: String, completionHandler: @escaping ((Bool) -> Void))
    
    ///유저 생성 join
    func createUser(email: String, password: String, completionHandler: @escaping ((Bool) -> Void))
    
    ///firebase 회원가입 - createUser email로만 회원가입 가능
    ///1. 현재 로그인한 유저정보를 db에 저장시킴
    ///2. db에서 받아온 email정보를 현재로그인 정보에 업데이트
    func Join(password: String, completionHandler: @escaping ((Bool) -> Void))
    
    ///firebase 사용자 정보 업데이트 - 사용자 프로필 설정 후, db저장 전
    func userInfoUpdate(displayName: String, photoURL: String)
    
    
    ///firebase 전화번호 로그인 요청
    func phoneNumberLogin(verificationCode: String, completionHandler: @escaping ((Bool) -> Void))
    
    ///firebase 전화번호 로그인 - 인증번호 전송
    ///- 원래 요청이 시간 초과되지 않았다면 SMS를 재차 보내지 않습니다.
    ///- test number - 01000120000 / code - 002002
    func requestVerificationCode(phoneNumber: String?, completionHandler: @escaping ((Bool) -> Void))
    
    ///firebase 전화번호 로그인 - 인증번호 재전송
    func requestVerificationCode(completionHandler: @escaping ((Bool) -> Void))
}


class FirebaseLogin{
    private var dbNetworkManager: DBNetworkManagerProtocol?
    
    ///MFA(다중인증) 여부
    ///
    ///소셜로그인 여부인듯?
    private var isMFAEnabled = false
        
    private var phoneNumber: String = ""
    
    init(networkManager: DBNetworkManagerProtocol? = nil) {
        self.dbNetworkManager = networkManager
    }
}

extension FirebaseLogin: FirebaseLoginProtocol{
    ///회원가입 여부 확인
    func checkJoin(phone: String, completionHandler: @escaping ((Bool) -> Void)){
        Task(priority: .userInitiated){
            do{
                guard let user = try await dbNetworkManager?.selectWherePhone(phone: phone) else {return}
                
                if user.count > 0{
                    //회원정보 있음
                    completionHandler(true)
                }
                else{
                    completionHandler(false)
                }
                
            }catch{
                print(error.localizedDescription)
            }
        }
        
    }
    
    ///로그인 여부 확인
    func checkLogin() -> Bool{
        if Auth.auth().currentUser != nil {
            return true
        }
        else{
            return false
        }
    }
    
    ///firebase 로그아웃
    func logout() -> Bool{
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            return true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            return false
        }
    }
    
    ///firebase 로그인 - 기본로그인
    func login(phone: String, password: String, completionHandler: @escaping ((Bool) -> Void)) {
        Task(priority: .userInitiated){
            do{
                guard let user = try await dbNetworkManager?.selectWherePhone(phone: phone) else {return}
                
                if user.count > 0{
                    //검색된 회원이 있으면 로그인
                    guard let email = user.first?.value.email else {return}
                    Auth.auth().signIn(withEmail: email, password: password){ [weak self] authResult, error in
                        if let error = error{
                            print(error.localizedDescription)
                            completionHandler(false)
                            return
                        }
                        //로그인 완료
                        completionHandler(true)
                    }
                }
                else{
                    //가입된 회원정보 없음
                    completionHandler(false)
                }
            }catch{
                print(error.localizedDescription)
            }
        }
        
    }
    
    ///firebase 로그인 - 이메일로그인
    func login(email: String, password: String, completionHandler: @escaping ((Bool) -> Void)){
            Task(priority: .userInitiated){
                do{
                    guard let user = try await dbNetworkManager?.selectWhereEmail(email: email) else {return}
                    
                    if user.count > 0{
                        //검색된 회원이 있으면 로그인
                        guard let email = user.first?.value.email else {return}
                        Auth.auth().signIn(withEmail: email, password: password){ [weak self] authResult, error in
                            if let error = error{
                                print(error.localizedDescription)
                                completionHandler(false)
                                return
                            }
                            completionHandler(true)
                        }
                    }
                    else{
                        completionHandler(false)
                    }
                }catch{
                    print(error.localizedDescription)
                }
            }
            
    }
    
    ///firebase 로그인 - 커스텀 토큰 인증
    func customLogin(customToken: String, completionHandler: @escaping ((Bool) -> Void)) {
        //지정된 타사 사용자 인증 정보 로그인
        Auth.auth().signIn(withCustomToken: customToken) { [weak self] authResult, error in
            if let error = error {
                let authError = error as NSError
                if self?.isMFAEnabled == true, authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                    // 사용자는 다중 요인 사용자입니다. 두 번째 요인 과제가 필요합니다.
                    let resolver = authError
                        .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                    var displayNameString = ""
                    for tmpFactorInfo in resolver.hints {
                        displayNameString += tmpFactorInfo.displayName ?? ""
                        displayNameString += " "
                    }
                }
                else {
                    print(error.localizedDescription)
                    completionHandler(false)
                    return
                }
                return
            }
            //로그인 성공
            completionHandler(true)
        }
    }
    
    ///firebase 로그인 - 소셜인증
    func socialLogin(credential: AuthCredential, completionHandler: @escaping ((Bool) -> Void)) {
        //지정된 타사 사용자 인증 정보 로그인
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            if let error = error {
                let authError = error as NSError
                if self?.isMFAEnabled == true, authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                    // 사용자는 다중 요인 사용자입니다. 두 번째 요인 과제가 필요합니다.
                    let resolver = authError
                        .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                    var displayNameString = ""
                    for tmpFactorInfo in resolver.hints {
                        displayNameString += tmpFactorInfo.displayName ?? ""
                        displayNameString += " "
                    }
                }
                else {
                    print(error.localizedDescription)
                    completionHandler(false)
                    return
                }
                return
            }
            //로그인 성공
            completionHandler(true)
        }
    }
    
    func createUser(email: String, password: String, completionHandler: @escaping ((Bool) -> Void)) {
        Auth.auth().createUser(withEmail: email, password: password){ [weak self] authResult, error in
            if let error = error {
                completionHandler(false)
                return
            }
            completionHandler(true)
        }
    }
    
    ///firebase 회원가입 - createUser email로만 회원가입 가능
    ///1. 현재 로그인한 유저정보를 db에 저장시킴
    ///2. db에서 받아온 email정보를 현재로그인 정보에 업데이트
    func Join(password: String, completionHandler: @escaping ((Bool) -> Void)) {
        guard let phone = Auth.auth().currentUser?.phoneNumber else {return}
        
        let user = User(id: loginType.phone, email: "", phone: phone, password: password)
        
        Task(priority: .userInitiated){
            do{
                guard let dataName = try await dbNetworkManager?.updateUser(user: user) else {return}
                let email = "\(dataName)@email.com"
                
                try await Auth.auth().currentUser?.updateEmail(to: email)
                completionHandler(true)
            }catch{
                //에러처리
                print(error.localizedDescription)
                completionHandler(false)
                return
            }
        }
    }
    
    ///firebase 사용자 정보 업데이트 - 사용자 프로필 설정 후, db저장 전
    func userInfoUpdate(displayName: String, photoURL: String){
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.photoURL = URL(string: photoURL)
        changeRequest?.commitChanges(){error in
            if let error = error {
                //실패
                return
            }
        }
    }
    
    ///firebase 전화번호 로그인 요청
    func phoneNumberLogin(verificationCode: String, completionHandler: @escaping ((Bool) -> Void)) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authId") else {return}
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        ) as AuthCredential
        
        self.socialLogin(credential: credential){result in
            completionHandler(result)
        }
    }
    
    ///firebase 전화번호 로그인 - 인증번호 전송
    ///- 원래 요청이 시간 초과되지 않았다면 SMS를 재차 보내지 않습니다.
    ///- test number - 01000120000 / code - 002002
    internal func requestVerificationCode(phoneNumber: String? = nil, completionHandler: @escaping ((Bool) -> Void)) {
        //Change language code to french.
        //        Auth.auth().languageCode = "kr";
        
        if phoneNumber != nil {
            self.phoneNumber = phoneNumber!
        }
        
        PhoneAuthProvider.provider().verifyPhoneNumber("+82 \(self.phoneNumber)", uiDelegate: nil) { verificationID, error in
            if let error = error {
                print(error.localizedDescription)
                completionHandler(false)
                return
            }
            //전송, id생성
            self.isMFAEnabled = true
            UserDefaults.standard.set(verificationID, forKey: "authId")
            
            completionHandler(true)
        }
    }
    
    ///firebase 전화번호 로그인 - 인증번호 재전송
    internal func requestVerificationCode(completionHandler: @escaping ((Bool) -> Void)) {
        requestVerificationCode(phoneNumber: self.phoneNumber){result in
            completionHandler(result)
        }
    }
        
    ///textField에 안내 메시지 표시
    ///- parameter withMessage: 사용자에게 보여줄 메시지
    ///
//    func showTextInputPrompt(withMessage: String, completionBlock: (Bool, String?)->Void){
//        print(withMessage)
//        //userPressedOK, displayName
//        completionBlock(true, "")
//
//    }
}
