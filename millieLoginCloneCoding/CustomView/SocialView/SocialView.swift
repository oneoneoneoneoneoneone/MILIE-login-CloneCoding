//
//  SocialView.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/25.
//

import UIKit
import AuthenticationServices
import FacebookLogin
import NaverThirdPartyLogin

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
    private var naverLoginManager: NaverLoginManager?
    
    private var isLogin = true
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var kakaoLoginButton: UIButton!
    @IBOutlet weak var naverLoginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: ASAuthorizationAppleIDButton!
    @IBOutlet weak var googleLoginButton: UIButton!
       
    func initSocialView(viewController: UIViewController?,
                        viewDelegate: SocialJoinDelegate? = nil,
                        modalViewController: UIViewController? = nil,
                        socialLoginVM: SocialLoginProtocol? = SocialLogin(),
                        appleLoginManager: AppleLoginManager? = AppleLoginManager(),
                        facebookLoginManager: FacebookLoginManager? = FacebookLoginManager(),
                        naverLoginManager: NaverLoginManager? = NaverLoginManager()) {
        self.viewController = viewController
        self.viewDelegate = viewDelegate
        self.modalViewController = modalViewController
        self.socialLoginVM = socialLoginVM
        self.appleLoginManager = appleLoginManager
        self.facebookLoginManager = facebookLoginManager
        self.naverLoginManager = naverLoginManager
        
        self.isLogin = viewController is LoginViewController
        
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
        appleLoginManager?.socialLoginVM = socialLoginVM
        appleLoginManager?.delegate = self
        appleLoginManager?.setAppleLoginPresentationAnchorView(viewController)
        
        facebookLoginManager?.socialLoginVM = socialLoginVM
        facebookLoginManager?.delegate = self
        facebookLoginManager?.setFacebookLoginPresentationAnchorView(viewController)
        
        naverLoginManager?.socialLoginVM = socialLoginVM
        naverLoginManager?.delegate = self
        naverLoginManager?.setNaverLoginPresentationAnchorView(viewController)
                
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
    
    @MainActor
    @IBAction func kakaoLoginButtonTap(_ sender: UIButton) {
        socialJoinDismissed()
        
        Task{
            do{
                try await socialLoginVM?.kakaoLogin(isLogin: isLogin)
                loginSuccess()
            }
            catch{
                viewController?.presentAlertMessage(message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func naverLoginButtonTap(_ sender: UIButton) {
        socialJoinDismissed()
        
        let naverConn: NaverThirdPartyLoginConnection = NaverThirdPartyLoginConnection.getSharedInstance()
        naverConn.delegate = naverLoginManager
        naverConn.requestThirdPartyLogin()
    }

    @IBAction func facebookLoginButtonTap(_ sender: UIButton) {
        socialJoinDismissed()
        
        //firebase 자격증명에 사용할..
        let nonce = Cryptography.randomNonceString()
        socialLoginVM?.currentNonce = nonce

        let loginbutton = FBLoginButton()
        
        loginbutton.delegate = facebookLoginManager
        loginbutton.loginTracking = .limited
        loginbutton.nonce = Cryptography.sha256(nonce)
        
        loginbutton.sendActions(for: .touchUpInside)
    }
    
    @IBAction func appleLoginButtonTap(_ sender: UIButton) {
        socialJoinDismissed()
        
        //firebase 자격증명에 사용할..
        let nonce = Cryptography.randomNonceString()
        socialLoginVM?.currentNonce = nonce
        
        //사용자의 전체 이름과 이메일 주소에 대한 인증 요청을 수행하여 인증 흐름을 시작
        //시스템은 사용자가 기기에서 Apple ID로 로그인했는지 확인
        //설정에서 Apple ID로 로그인하라는 경고를 표시
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        //firebase에서 사용할..
        request.nonce = Cryptography.sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = appleLoginManager
        controller.presentationContextProvider = appleLoginManager
        controller.performRequests()    //요청
    }
    
    @MainActor
    @IBAction func googleLoginButtonTap(_ sender: UIButton) {
        socialJoinDismissed()
        
        Task{
            do{
                try await socialLoginVM?.googleLogin(isLogin: isLogin, viewController: viewController)
                loginSuccess()
            }
            catch{
                viewController?.presentAlertMessage(message: error.localizedDescription)
            }
        }
    }
}

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
