//
//  SocialView.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/25.
//

import UIKit
import AuthenticationServices

protocol LoginManagerDelegate{
    func loginSuccess()
}

class SocialView: UIView{
    //인증할, 인증하고 돌아올 뷰
    private var viewController: UIViewController?
    private var modalViewController: UIViewController?
    private var viewDelegate: SocialJoinDelegate?
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var kakaoLoginButton: UIButton!
    @IBOutlet weak var naverLoginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: ASAuthorizationAppleIDButton!
    @IBOutlet weak var googleLoginButton: UIButton!
       
    func initSocialView(viewController: UIViewController?,
                        viewDelegate: SocialJoinDelegate? = nil,
                        modalViewController: UIViewController? = nil) {
        self.viewController = viewController
        self.viewDelegate = viewDelegate
        self.modalViewController = modalViewController
                
        setAttribute()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
    }
    
    func xibSetup() {
        let bundle = Bundle(for: SocialView.self)
        bundle.loadNibNamed("SocialView", owner: self, options: nil)
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    private func setAttribute(){
        kakaoLoginButton.layer.cornerRadius = 25
        naverLoginButton.layer.cornerRadius = 25
        facebookLoginButton.layer.cornerRadius = 25
        appleLoginButton.layer.cornerRadius = 25
        googleLoginButton.layer.cornerRadius = 25
        googleLoginButton.layer.borderWidth = 0.5
        googleLoginButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func socialJoinDismissed(){
        modalViewController?.dismiss(animated: false)
    }
    
    @IBAction func kakaoLoginButtonTap(_ sender: UIButton) {
        socialJoinDismissed()
        
        let kakaoLoginManager = KakaoLoginManager()
        
        kakaoLoginManager.setSocialLoginPresentationAnchorView(viewController, self)
        kakaoLoginManager.requestLogin()
    }
    
    @IBAction func naverLoginButtonTap(_ sender: UIButton) {
        socialJoinDismissed()
        
        let naverLoginManager = NaverLoginManager()
        
        naverLoginManager.setSocialLoginPresentationAnchorView(viewController, self)
        naverLoginManager.requestLogin()
    }

    @IBAction func facebookLoginButtonTap(_ sender: UIButton) {
        socialJoinDismissed()
        
        let facebookLoginManager = FacebookLoginManager()
        
        facebookLoginManager.setSocialLoginPresentationAnchorView(viewController, self)
        facebookLoginManager.requestLogin()
    }
    
    @IBAction func appleLoginButtonTap(_ sender: UIButton) {
        socialJoinDismissed()
        
        let appleLoginManager = AppleLoginManager()
        
        appleLoginManager.setSocialLoginPresentationAnchorView(viewController, self)
        appleLoginManager.requestLogin()
    }
    
    @IBAction func googleLoginButtonTap(_ sender: UIButton) {
        socialJoinDismissed()
        
        let googleLoginManager = GoogleLoginManager()
        
        googleLoginManager.setSocialLoginPresentationAnchorView(viewController, self)
        googleLoginManager.requestLogin()
    }
}

extension SocialView: LoginManagerDelegate{
    func loginSuccess() {
        if viewController is LoginViewController{
            //시작화면으로 가서 로그인 여부 확인하게 됨
            viewController?.dismiss(animated: true)
            viewController?.navigationController?.popToRootViewController(animated: true)
        }
        if viewController is JoinViewController{
            //약관 동의 화면으로 이동해야함
            viewDelegate?.moveToJoinTermsofUseViewController()
        }
    }
}
