//
//  NaverLoginManager.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/29.
//

import Foundation
import NaverThirdPartyLogin

class NaverLoginManager: NSObject, SocialLoginManagerProtocol {
    private var viewController: UIViewController?
    private var delegate: LoginManagerDelegate?
    private var serverNetworkManager: ServerNetworkManagerProtocol? = NetworkManager()
    private var socialLoginVM: SocialLoginProtocol? = SocialLogin()
        
    func setSocialLoginPresentationAnchorView(_ viewController: UIViewController?, _ delegate: LoginManagerDelegate?) {
        self.viewController = viewController
        self.delegate = delegate
    }
    
    func requestLogin(){
        let naverConn: NaverThirdPartyLoginConnection = NaverThirdPartyLoginConnection.getSharedInstance()
        naverConn.delegate = self
        naverConn.requestThirdPartyLogin()
    }
}

extension NaverLoginManager: NaverThirdPartyLoginConnectionDelegate{
    @MainActor
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        Task{
            do{
                guard let accessToken = NaverThirdPartyLoginConnection.getSharedInstance().accessToken else {
                    throw LoginError.nilData(key: "accessToken")
                }
                guard let userEmail = try await serverNetworkManager?.requestNaverLoginData(accessToken: accessToken)?.email else {
                    throw LoginError.nilData(key: "email")
                }
                
                if viewController is LoginViewController{
                    try await socialLoginVM?.verifyUserCredentials(email: userEmail, loginType: LoginType.naver)
                }
                if viewController is JoinViewController{
                    try await socialLoginVM?.checkExistingUserEmail(email: userEmail, loginType: LoginType.naver)
                }
                try await socialLoginVM?.naverLogin(accessToken: accessToken)
                
                NaverThirdPartyLoginConnection.getSharedInstance().resetToken()
                delegate?.loginSuccess()
            }
            catch{
                viewController?.presentAlertMessage(message: error.localizedDescription)
            }
        }
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        viewController?.presentAlertMessage(message: error.localizedDescription)
    }
    
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFinishAuthorizationWithResult recieveType: THIRDPARTYLOGIN_RECEIVE_TYPE) {
        
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailAuthorizationWithRecieveType recieveType: THIRDPARTYLOGIN_RECEIVE_TYPE) {
        
    }
}
