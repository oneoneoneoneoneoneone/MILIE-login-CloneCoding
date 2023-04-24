//
//  AppleLoginManager.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/25.
//

import AuthenticationServices

final class AppleLoginManager: NSObject {
    var viewController: UIViewController?
    var delegate: AppleLoginManagerDelegate?
    var socialLoginVM: SocialLoginProtocol?
    
    init(viewController: UIViewController? = nil, delegate: AppleLoginManagerDelegate? = nil, socialLoginVM: SocialLoginProtocol? = nil) {
        self.viewController = viewController
        self.delegate = delegate
        self.socialLoginVM = socialLoginVM
    }
    
    func setAppleLoginPresentationAnchorView(_ view: UIViewController) {
        self.viewController = view
    }
}

extension AppleLoginManager: ASAuthorizationControllerDelegate {
    ///인증에 성공하면 인증 컨트롤러는 앱이 사용자 데이터를 키체인에 저장하는 데 사용하는 위임 기능을 호출
    ///
    ///사용자가 처음 로그인할 때만 표시 이름 등의 사용자 정보를 앱에 공유
    ///이전에 Firebase를 사용하지 않고 Apple을 사용하여 사용자를 앱에 로그인하도록 했으면 Apple은 Firebase에 사용자의 표시 이름을 제공하지 않습니다.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential{
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let userCode = appleIDCredential.user
            
            let isLogin = viewController is LoginViewController
            
            //firebase 자격증명 사용
            socialLoginVM?.appleLogin(isLogin: isLogin, userCode: userCode, IDToken: idTokenString){ [self] result in
                if result{
                    //login 성공
                    delegate?.appleLoginSuccess()
                }
                else{
                }
            }
            //appleIDCredential.identityToken - 바뀜
            //appleIDCredential.user - 일정
            //fullName, email - 2번째 로그인부터 안들어옴(옵셔널)
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
