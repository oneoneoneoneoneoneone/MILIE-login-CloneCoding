//
//  LoginViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/28.
//

import UIKit
import AuthenticationServices
import NaverThirdPartyLogin

protocol AppleLoginManagerDelegate{
    func appleLoginSuccess()
}

class LoginViewController: UIViewController {
    private var loginVM: FirebaseLoginProtocol?
    private var socialLoginVM: SocialLoginProtocol?
    private var appleLoginManager: AppleLoginManager?
    
    @IBOutlet weak var phoneInputView: InputStackView!
    @IBOutlet weak var passwordInputView: InputStackView!

    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var kakaoLoginButton: UIButton!
    @IBOutlet weak var naverLoginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: ASAuthorizationAppleIDButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginVM = FirebaseLogin()
        self.socialLoginVM = SocialLogin()
        self.appleLoginManager = AppleLoginManager(viewController: self, delegate: self, socialLoginVM: socialLoginVM)
        
        setAttribute()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if loginVM.checkLogin(){
//            guard let mainVC =  UIStoryboard(name: "Main", bundle: nil)
//                .instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else {return}
//            mainVC.modalPresentationStyle = .fullScreen
//
//            self.present(mainVC, animated: true)
//        }
    }
    
    private func setAttribute(){
        phoneInputView.delegate = self
        passwordInputView.delegate = self
        appleLoginManager?.delegate = self
        appleLoginManager?.setAppleLoginPresentationAnchorView(self)

        loginButton.layer.cornerRadius = 5
        
        kakaoLoginButton.layer.cornerRadius = 25
        naverLoginButton.layer.cornerRadius = 25
        facebookLoginButton.layer.cornerRadius = 25
        appleLoginButton.layer.cornerRadius = 25
        googleLoginButton.layer.cornerRadius = 25
        googleLoginButton.layer.borderWidth = 0.5
        googleLoginButton.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    @IBAction func loginButtonTap(_ sender: UIButton) {
        guard let phoneNumber = phoneInputView.textField.text,
              let password = passwordInputView.textField.text else {return}
        
        loginVM?.login(phone: phoneNumber, password: password){result in
            if result {
                self.dismiss(animated: true)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    @IBAction func kakaoLoginButtonTap(_ sender: UIButton) {
        socialLoginVM?.kakaoLogin(isLogin: true){result in
            if result{
                //login 성공
                self.dismiss(animated: true)
                self.navigationController?.popToRootViewController(animated: true)
            }
            else{
            }
        }
    }
    
    @IBAction func naverLoginButtonTap(_ sender: UIButton) {
        let naverConn: NaverThirdPartyLoginConnection = NaverThirdPartyLoginConnection.getSharedInstance()
        naverConn.delegate = self
        naverConn.requestThirdPartyLogin()
    }
    
    @IBAction func facebookLoginButtonTap(_ sender: UIButton) {
        
    }
    
    @IBAction func appleLoginButtonTap(_ sender: UIButton) {
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
        socialLoginVM?.googleLogin(isLogin: true, viewController: self){result in
            if result{
                //login 성공
                self.dismiss(animated: true)
                self.navigationController?.popToRootViewController(animated: true)
            }
            else{
            }
        }
    }
}

//MARK: extension

extension LoginViewController: InputStackViewDelegate{
    func inputTextFieldDidChangeSelection(_ textField: UITextField) {
        //text 변경
        if phoneInputView.textField.text == "" || passwordInputView.textField.text == "" {
            loginButton.isEnabled = false
        }
        else{
            loginButton.isEnabled = true
        }
    }
}

///apple
extension LoginViewController: AppleLoginManagerDelegate{
    func appleLoginSuccess() {
    //    DispatchQueue.main.async{
            self.dismiss(animated: true)
            self.navigationController?.popToRootViewController(animated: true)
    //    }
    }
}

///naver Login
extension LoginViewController: NaverThirdPartyLoginConnectionDelegate{
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        //로그인 성공
        guard let accessToken = NaverThirdPartyLoginConnection.getSharedInstance().accessToken else {return}
        
        socialLoginVM?.naverLogin(isLogin:true, accessToken: accessToken){result in
            if result{
                //login 성공
                DispatchQueue.main.async{
                    self.dismiss(animated: true)
                    self.navigationController?.popToRootViewController(animated: true)
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
