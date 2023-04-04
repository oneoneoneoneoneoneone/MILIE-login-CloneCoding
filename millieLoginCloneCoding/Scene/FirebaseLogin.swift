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
    func checkLogin() -> Bool
    func login(credential: AuthCredential, completionHandler: @escaping ((Bool) -> Void))
    func logout() -> Bool
    
    func checkJoin() -> Bool
    func Join(completionHandler: @escaping ((Bool) -> Void))
    
    func phoneNumberLogin(phoneNumber: String, verificationCode: String, completionHandler: @escaping ((Bool) -> Void))
    func requestVerificationCode(phoneNumber: String)
}


class FirebaseLogin: FirebaseLoginProtocol{
    func checkJoin() -> Bool {
        return true
    }
    
    func Join(completionHandler: @escaping ((Bool) -> Void)) {
        
    }
    
    
    ///MFA(다중인증) 여부
    ///
    ///소셜로그인 여부인듯?
    var isMFAEnabled = false
    
    ///로그인 요청마다 생성되는 임의의 문자열
    ///apple login에 사용
    var currentNonce: String?
    
    func checkLogin() -> Bool{
        if Auth.auth().currentUser != nil {
            return true
        }
        else{
            return false
        }
    }
    
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
    
    ///firebase 로그인
    func login(credential: AuthCredential, completionHandler: @escaping ((Bool) -> Void)) {
        //로그인
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            if let error = error {
              let authError = error as NSError
              if self!.isMFAEnabled, authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                // 사용자는 다중 요인 사용자입니다. 두 번째 요인 과제가 필요합니다.
                let resolver = authError
                  .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                var displayNameString = ""
                for tmpFactorInfo in resolver.hints {
                  displayNameString += tmpFactorInfo.displayName ?? ""
                  displayNameString += " "
                }
//                  self?.showTextInputPrompt(
//                  withMessage: "Select factor to sign in\n\(displayNameString)",
//                  completionBlock: { userPressedOK, displayName in
//                    var selectedHint: PhoneMultiFactorInfo?
//                    for tmpFactorInfo in resolver.hints {
//                      if displayName == tmpFactorInfo.displayName {
//                        selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
//                      }
//                    }
//                    PhoneAuthProvider.provider()
//                      .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
//                                         multiFactorSession: resolver
//                                           .session) { verificationID, error in
//                        if error != nil {
//                          print(
//                            "Multi factor start sign in failed. Error: \(error.debugDescription)"
//                          )
//                        } else {
//                          self?.showTextInputPrompt(
//                            withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
//                            completionBlock: { userPressedOK, verificationCode in
//                              let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
//                                .credential(withVerificationID: verificationID!,
//                                            verificationCode: verificationCode!)
//                              let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
//                                .assertion(with: credential!)
//                              resolver.resolveSignIn(with: assertion!) { authResult, error in
//                                if error != nil {
//                                  print(
//                                    "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
//                                  )
//                                } else {
//                                    //self.navigationController?.popViewController(animated: true)
//                                }
//                              }
//                            }
//                          )
//                        }
//                      }
//                  }
//                )
              } else {
                  print(error.localizedDescription)
                  completionHandler(false)
                  return
              }
              // ...
              return
            }
            //로그인 성공
            completionHandler(true)
        }
    }
    
    ///firebase 전화번호 로그인 요청
    func phoneNumberLogin(phoneNumber: String, verificationCode: String, completionHandler: @escaping ((Bool) -> Void)) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authId") else {return}
        
        let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID,
                verificationCode: verificationCode
        ) as AuthCredential
        
        self.login(credential: credential){result in
            completionHandler(result)
        }
    }
        
    ///firebase 전화번호 로그인 - 인증번호 전송
    ///- 원래 요청이 시간 초과되지 않았다면 SMS를 재차 보내지 않습니다.
    ///- test number - 01000120000 / code - 002002
    internal func requestVerificationCode(phoneNumber: String){
        //Change language code to french.
//        Auth.auth().languageCode = "kr";
        
        PhoneAuthProvider.provider()
          .verifyPhoneNumber("+82 \(phoneNumber)", uiDelegate: nil) { verificationID, error in
              if let error = error {
                  print(error.localizedDescription)
                return
              }
              //전송, id생성
              self.isMFAEnabled = true
              UserDefaults.standard.set(verificationID, forKey: "authId")
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
