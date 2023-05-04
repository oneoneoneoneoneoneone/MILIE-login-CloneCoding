//
//  AppleLoginManager.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/25.
//

import Foundation
import AuthenticationServices

protocol SocialLoginManagerProtocol{
    func setSocialLoginPresentationAnchorView(_ viewController: UIViewController?, _ delegate: LoginManagerDelegate?)
    func requestLogin()
}

final class AppleLoginManager: NSObject, SocialLoginManagerProtocol {
    private var viewController: UIViewController?
    private var delegate: LoginManagerDelegate?
    private var socialLoginVM: SocialLoginProtocol? = SocialLogin()
    private var socialJoinVM: SocialJoinProtocol? = SocialJoin()
    
    ///로그인 요청마다 생성되는 임의의 문자열
    private var currentNonce: String?
    
    func setSocialLoginPresentationAnchorView(_ viewController: UIViewController?, _ delegate: LoginManagerDelegate?) {
        self.viewController = viewController
        self.delegate = delegate
    }
    
    func requestLogin(){
        //사용자의 전체 이름과 이메일 주소에 대한 인증 요청을 수행하여 인증 흐름을 시작
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        currentNonce = Cryptography.randomNonceString()
        guard let currentNonce = currentNonce else {return}
        request.nonce = Cryptography.sha256(currentNonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()    //요청
    }
}

extension AppleLoginManager: ASAuthorizationControllerDelegate {
    ///인증에 성공하면 인증 컨트롤러는 앱이 사용자 데이터를 키체인에 저장하는 데 사용하는 위임 기능을 호출
    ///
    ///사용자가 처음 로그인할 때만 표시 이름 등의 사용자 정보를 앱에 공유
    ///이전에 Firebase를 사용하지 않고 Apple을 사용하여 사용자를 앱에 로그인하도록 했으면 Apple은 Firebase에 사용자의 표시 이름을 제공하지 않습니다.
    @MainActor
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task{
            do{
                guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {return}
                guard let currentNonce = currentNonce else{
                    throw LoginError.discrepancyData(key: "nonce")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    throw LoginError.nilData(key: "appleIDToken")
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    throw LoginError.etcData(key: "Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                }
                let userCode = appleIDCredential.user
                
                if viewController is LoginViewController{
                    try await socialLoginVM?.appleLogin(userCode: userCode, IdToken: idTokenString, nonce: currentNonce)
                }
                if viewController is JoinViewController{
                    try await socialJoinVM?.appleLogin(userCode: userCode, IdToken: idTokenString, nonce: currentNonce)
                }
                delegate?.loginSuccess()
            }
            catch{
                viewController?.presentAlertMessage(message: error.localizedDescription)
            }
        }
    }
}

///모달 시트에서 사용자에게 Apple로 로그인 콘텐츠를 제공하는 앱에서 창을 가져오는 함수
extension AppleLoginManager: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return (viewController?.view.window)!
    }
}
