//
//  GoogleLoginManager.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/05/04.
//

import Foundation
import GoogleSignIn
import Firebase

class GoogleLoginManager: NSObject, SocialLoginManagerProtocol {
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
                guard let viewController = viewController else {return}
                let signInResult = try await requestGoogleSignIn(viewController: viewController)
                        
                guard let idToken = signInResult.user.idToken?.tokenString else {
                    throw LoginError.nilData(key: "idToken")
                }
                guard let email = signInResult.user.profile?.email else {
                    throw LoginError.nilData(key: "email")
                }
                let accessToken = signInResult.user.accessToken.tokenString
                                    
                if viewController is LoginViewController{
                    try await socialLoginVM?.googleLogin(email: email, idToken: idToken, accessToken: accessToken)
                }
                if viewController is JoinViewController{
                    try await socialJoinVM?.googleLogin(email: email, idToken: idToken, accessToken: accessToken)
                }
                delegate?.loginSuccess()
            }
            catch{
                viewController?.presentAlertMessage(message: error.localizedDescription)
            }
        }
    }
    
    ///google 로그인 - GoogleSignIn 요청
    private func requestGoogleSignIn(viewController: UIViewController) async throws -> GIDSignInResult{
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
