//
//  FacebookLoginManager.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/27.
//

import UIKit
import FacebookLogin

class FacebookLoginManager: NSObject {
    private var viewController: UIViewController?
    var delegate: LoginManagerDelegate?
    var socialLoginVM: SocialLoginProtocol?
        
    func setFacebookLoginPresentationAnchorView(_ viewController: UIViewController?) {
        self.viewController = viewController
    }
}


extension FacebookLoginManager: LoginButtonDelegate{
    func loginButtonWillLogin(_ loginButton: FBLoginButton) -> Bool {
//
//        if let nonce = nonceTextField?.text, !nonce.isEmpty {
//            loginButton.nonce = nonce
//        }

        return true
    }
    
    @MainActor
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        if let error = error {
          print(error.localizedDescription)
          return
        }
        guard let idToken = AuthenticationToken.current?.tokenString else {return}
        guard let userID = Profile.current?.userID else {return}
        
        let isLogin = viewController is LoginViewController
        
        Task{
            do{
                try await socialLoginVM?.facebookLogin(isLogin: isLogin, userID: userID, idToken: idToken)
                delegate?.loginSuccess()
            }
            catch{
                viewController?.presentAlertMessage(message: error.localizedDescription)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
    }
}
