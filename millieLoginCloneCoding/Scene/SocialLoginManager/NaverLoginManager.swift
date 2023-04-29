//
//  NaverLoginManager.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/29.
//

import UIKit
import NaverThirdPartyLogin

class NaverLoginManager: NSObject {
    private var viewController: UIViewController?
    var delegate: LoginManagerDelegate?
    var socialLoginVM: SocialLoginProtocol?
        
    func setNaverLoginPresentationAnchorView(_ viewController: UIViewController?) {
        self.viewController = viewController
    }
}

extension NaverLoginManager: NaverThirdPartyLoginConnectionDelegate{
    @MainActor
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        guard let accessToken = NaverThirdPartyLoginConnection.getSharedInstance().accessToken else {return}
        let isLogin = viewController is LoginViewController
        
        Task{
            do{
                try await socialLoginVM?.naverLogin(isLogin:isLogin, accessToken: accessToken)
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
