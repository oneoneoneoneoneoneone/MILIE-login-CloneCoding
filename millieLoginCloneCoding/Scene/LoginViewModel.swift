//
//  LoginViewModel.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/28.
//

import Foundation
import FirebaseAuth
import Firebase

class LoginViewModel{
    
    ///MFA(다중인증) 여부
    ///
    ///소셜로그인 여부인듯?
    var isMFAEnabled = false
    
    func checkLogin() -> Bool{
        if Auth.auth().currentUser != nil {
            return true
        }
        else{
            return false
        }
    }
    
    func logout(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    
    ///firebase 전화번호 로그인 - 인증번호 전송
    ///- 원래 요청이 시간 초과되지 않았다면 SMS를 재차 보내지 않습니다.
    ///- test number - 01000120000 / code - 002002
    func getverificationCode(phoneNumber: String){
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
    
    ///firebase 전화번호 로그인 요청
    func phoneNumberLogin(phoneNumber: String, verificationCode: String, completionHandler: @escaping ((Bool) -> Void)) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authId") else {return}
        
        let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID,
                verificationCode: verificationCode
        ) as AuthCredential
        
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
    
    ///textField에 안내 메시지 표시
    ///- parameter withMessage: 사용자에게 보여줄 메시지
    ///
    func showTextInputPrompt(withMessage: String, completionBlock: (Bool, String?)->Void){
        print(withMessage)
        //userPressedOK, displayName
        completionBlock(true, "")
        
    }
}
