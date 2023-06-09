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
import FirebaseAuthCombineSwift

protocol FirebaseLoginProtocol {
    ///firebase 로그인 - 소셜인증
    func socialLogin(credential: AuthCredential) async throws
    
    ///firebase 커스텀 토큰 인증
    func customLogin(customToken: String) async throws
}

protocol LoginProtocol {
    ///
    func getCurrentUser() -> FirebaseAuth.User?
    
    ///로그인 여부 확인
    func checkLogin() -> Bool
    
    ///firebase 로그인 - 기본로그인(휴대폰)
    func login(phone: String, password: String) async throws
        
    ///firebase 로그아웃
    func logout() throws
    
    ///회원가입 여부 확인
    func checkExistingUserPhoneNumber(phone: String) async throws
    
    
    ///firebase 회원가입 - createUser email로만 회원가입 가능
    ///1. 현재 로그인한 유저정보를 db에 저장시킴
    ///2. db에서 받아온 email정보를 현재로그인 정보에 업데이트
    func createUser() async throws
    
    ///firebase 사용자 정보 업데이트 - 비밀번호
    func userInfoUpdate(password: String) async throws
    
    ///firebase 사용자 정보 업데이트 - 사용자 프로필
    func userInfoUpdate(displayName: String, photoURL: String)
    
    ///firebase 전화번호 로그인 요청
    func phoneNumberLogin(verificationCode: String) async throws
    
    ///firebase 전화번호 로그인 - 인증번호 전송
    ///- 원래 요청이 시간 초과되지 않았다면 SMS를 재차 보내지 않습니다.
    ///- test number - 01000120000 / code - 002002
    func requestVerificationCode(phoneNumber: String?) async throws
    
    ///firebase 전화번호 로그인 - 인증번호 재전송
    func requestVerificationCode() async throws
}


class FirebaseLogin{
    private var dbNetworkManager: DBNetworkManagerProtocol?
    
    ///MFA(다중인증) 여부
    ///
    ///소셜로그인 여부인듯?
    private var isMFAEnabled = false
        
    private var phoneNumber: String = ""
    
    init(networkManager: DBNetworkManagerProtocol? = NetworkManager()) {
        self.dbNetworkManager = networkManager
    }
}

extension FirebaseLogin: LoginProtocol, FirebaseLoginProtocol{
    func getCurrentUser() -> FirebaseAuth.User?{
        return Auth.auth().currentUser
    }
    
    ///회원가입 여부 확인
    func checkExistingUserPhoneNumber(phone: String) async throws{
        if (try await dbNetworkManager?.selectForPhone(phone: phone)?
            .filter{$0.value.id == LoginType.phone.rawValue}
            .isEmpty) == false{
            throw LoginError.foundJoinData(key: "휴대폰 번호")
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
    func logout() throws{
        try Auth.auth().signOut()
    }
    
    ///firebase 로그인 - 기본로그인
    func login(phone: String, password: String) async throws {
        guard let user = try await dbNetworkManager?.selectForPhone(phone: phone) else {
            throw LoginError.nilData(key: "email")
        }
        if user.count == 0{
            throw LoginError.notFoundLoginData
        }
        
        //검색된 회원이 있으면 로그인
        guard let email = user.first?.key else {
            throw LoginError.nilData(key: "email")
        }
        
        //pw
        try await Auth.auth().signIn(withEmail: "\(email)@email.com", password: password)
    }
    
    ///firebase 로그인 - 소셜인증
    func socialLogin(credential: AuthCredential) async throws {
        do{
            //지정된 타사 사용자 인증 정보 로그인
            try await Auth.auth().signIn(with: credential)
        }
        catch {
            let authError = error as NSError
            if self.isMFAEnabled == true, authError.code == AuthErrorCode.secondFactorRequired.rawValue {
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
                throw error
            }
        }
    }
    
    ///firebase 로그인 - 커스텀 토큰 인증
    func customLogin(customToken: String) async throws {
        do{
            try await Auth.auth().signIn(withCustomToken: customToken)
        }
        catch {
            let authError = error as NSError
            if self.isMFAEnabled == true, authError.code == AuthErrorCode.secondFactorRequired.rawValue {
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
                throw error
            }
        }
    }
    
    ///firebase 회원가입 - createUser email로만 회원가입 가능
    ///1. 현재 로그인한 유저정보를 db에 저장시킴
    ///2. db에서 받아온 email정보를 현재로그인 정보에 업데이트
    func createUser() async throws {
        let user = User(id: LoginType.phone.rawValue, email: "", phone: self.phoneNumber)
        guard let dataName = try await dbNetworkManager?.createUser(user: user) else {return}
        
        let email = "\(dataName)@email.com"
        
        try await Auth.auth().currentUser?.updateEmail(to: email)
    }
    
    ///firebase 사용자 정보 업데이트 - 비밀번호
    func userInfoUpdate(password: String) async throws{
        try await Auth.auth().currentUser?.updatePassword(to: password)
    }
    
    ///firebase 사용자 정보 업데이트 - 사용자 프로필 설정 후, db저장 전
    func userInfoUpdate(displayName: String, photoURL: String){
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.photoURL = URL(string: photoURL)
        changeRequest?.commitChanges(){_ in
        }
    }
    
    ///firebase 전화번호 로그인 요청
    func phoneNumberLogin(verificationCode: String) async throws {
        guard let verificationID = UserDefaults.standard.string(forKey: "authId") else {return}
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID,
                                                                 verificationCode: verificationCode) as AuthCredential
        
        try await self.socialLogin(credential: credential)
    }
    
    ///firebase 전화번호 로그인 - 인증번호 전송
    ///- 원래 요청이 시간 초과되지 않았다면 SMS를 재차 보내지 않습니다.
    ///- test number - 01000120000 / code - 002002
    func requestVerificationCode(phoneNumber: String? = nil) async throws {
        if phoneNumber != nil {
            self.phoneNumber = phoneNumber!
        }
        
        Auth.auth().languageCode = "kr";
        let verificationID = try await PhoneAuthProvider.provider().verifyPhoneNumber("+82 \(self.phoneNumber)", uiDelegate: nil)
        //전송, id생성
        self.isMFAEnabled = true
        UserDefaults.standard.set(verificationID, forKey: "authId")
    }
    
    ///firebase 전화번호 로그인 - 인증번호 재전송
    func requestVerificationCode() async throws {
        try await requestVerificationCode(phoneNumber: self.phoneNumber)
    }
}
