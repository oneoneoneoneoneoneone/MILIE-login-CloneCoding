//
//  SocialView.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/25.
//

import UIKit
import AuthenticationServices
import NaverThirdPartyLogin
import FacebookLogin
import FacebookCore
import FacebookAEM

protocol LoginManagerDelegate{
    func loginSuccess()
}

class SocialView: UIView{
    //인증할, 인증하고 돌아올 뷰
    private var viewController: UIViewController?
    private var modalViewController: UIViewController?
    private var viewDelegate: SocialJoinDelegate?
    
    private var socialLoginVM: SocialLoginProtocol?
    private var appleLoginManager: AppleLoginManager?
    private var facebookLoginManager: FacebookLoginManager?
    
    private var isLogin = true
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var kakaoLoginButton: UIButton!
    @IBOutlet weak var naverLoginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: ASAuthorizationAppleIDButton!
    @IBOutlet weak var googleLoginButton: UIButton!
       
    func initSocialView(viewController: UIViewController?, viewDelegate: SocialJoinDelegate? = nil, modalViewController: UIViewController? = nil, socialLoginVM: SocialLoginProtocol? = SocialLogin(), appleLoginManager: AppleLoginManager? = AppleLoginManager(), facebookLoginManager: FacebookLoginManager? = FacebookLoginManager()) {
        self.viewController = viewController
        self.viewDelegate = viewDelegate
        self.modalViewController = modalViewController
        self.socialLoginVM = socialLoginVM
        self.appleLoginManager = appleLoginManager
        self.facebookLoginManager = facebookLoginManager
        
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
        facebookLoginManager?.socialLoginVM = socialLoginVM
        facebookLoginManager?.delegate = self
        facebookLoginManager?.setFacebookLoginPresentationAnchorView(viewController)
        
        appleLoginManager?.socialLoginVM = socialLoginVM
        appleLoginManager?.delegate = self
        appleLoginManager?.setAppleLoginPresentationAnchorView(viewController)
        
        isLogin = viewController is LoginViewController
        
        
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
        
        socialLoginVM?.kakaoLogin(isLogin: isLogin){[weak self] result in
            if result{
                self?.loginSuccess()
            }
            else{
            }
        }
    }
    
    @IBAction func naverLoginButtonTap(_ sender: UIButton) {
        socialJoinDismissed()
        
        let naverConn: NaverThirdPartyLoginConnection = NaverThirdPartyLoginConnection.getSharedInstance()
        naverConn.delegate = self
        naverConn.requestThirdPartyLogin()
    }

    @IBAction func facebookLoginButtonTap(_ sender: UIButton) {
        socialJoinDismissed()
        
        //firebase 자격증명에 사용할..
        let cryptography = Cryptography()
        let nonce = cryptography.randomNonceString()
        socialLoginVM?.currentNonce = nonce

        let loginbutton = FBLoginButton()
        
        loginbutton.delegate = facebookLoginManager
        loginbutton.loginTracking = .limited
//        loginbutton.permissions = ["email"]
        loginbutton.nonce = cryptography.sha256(nonce)
        loginbutton.sendActions(for: .touchUpInside)
    }
    
    @IBAction func appleLoginButtonTap(_ sender: UIButton) {
        socialJoinDismissed()
        
        //firebase 자격증명에 사용할..
        let cryptography = Cryptography()
        let nonce = cryptography.randomNonceString()
        socialLoginVM?.currentNonce = nonce
        
        //사용자의 전체 이름과 이메일 주소에 대한 인증 요청을 수행하여 인증 흐름을 시작
        //시스템은 사용자가 기기에서 Apple ID로 로그인했는지 확인
        //설정에서 Apple ID로 로그인하라는 경고를 표시
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        //firebase에서 사용할..
        request.nonce = cryptography.sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = appleLoginManager
        controller.presentationContextProvider = appleLoginManager
        controller.performRequests()    //요청
    }
    
    @IBAction func googleLoginButtonTap(_ sender: UIButton) {
        socialJoinDismissed()
        
        socialLoginVM?.googleLogin(isLogin: isLogin, viewController: viewController){[weak self] result in
            if result{
                self?.loginSuccess()
            }
            else{
            }
        }
    }
}

///apple
extension SocialView: LoginManagerDelegate{
    func loginSuccess() {
        if isLogin{
            //시작화면으로 가서 로그인 여부 확인하게 됨
            viewController?.dismiss(animated: true)
            viewController?.navigationController?.popToRootViewController(animated: true)
        }
        else{
            //약관 동의 화면으로 이동해야함
            viewDelegate?.moveToJoinTermsofUseViewController()
        }
    }
}


///naver Login
extension SocialView: NaverThirdPartyLoginConnectionDelegate{
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        //로그인 성공
        guard let accessToken = NaverThirdPartyLoginConnection.getSharedInstance().accessToken else {return}
        
        socialLoginVM?.naverLogin(isLogin:isLogin, accessToken: accessToken){[weak self] result in
            if result{
                //login 성공
                DispatchQueue.main.async{
                    self?.loginSuccess()
                }
            }
            else{
            }
            NaverThirdPartyLoginConnection.getSharedInstance().resetToken()
        }
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        //로그인 실패
        print(error.localizedDescription)
    }
    
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
//        NaverThirdPartyLoginConnection.getSharedInstance().resetToken()
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFinishAuthorizationWithResult recieveType: THIRDPARTYLOGIN_RECEIVE_TYPE) {
        
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailAuthorizationWithRecieveType recieveType: THIRDPARTYLOGIN_RECEIVE_TYPE) {
        
    }
}
