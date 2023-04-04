//
//  LoginViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/28.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {
    private var loginVM: FirebaseLogin!
    private var socialLoginVM: SocialLogin!
    
    @IBOutlet weak var phoneInputView: InputStackView!
    @IBOutlet weak var passwordInputView: InputStackView!

    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var kakaoLoginButton: UIButton!
    @IBOutlet weak var naverLoginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: ASAuthorizationAppleIDButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    
    @IBOutlet weak var phoneNumberLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginVM = FirebaseLogin()
        self.socialLoginVM = SocialLogin(firebaseLogin: loginVM)
        
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

        loginButton.layer.cornerRadius = 5
        
        kakaoLoginButton.layer.cornerRadius = 25
        naverLoginButton.layer.cornerRadius = 25
        facebookLoginButton.layer.cornerRadius = 25
        appleLoginButton.layer.cornerRadius = 25
        googleLoginButton.layer.cornerRadius = 25
        googleLoginButton.layer.borderWidth = 0.5
        googleLoginButton.layer.borderColor = UIColor.lightGray.cgColor
        
        phoneNumberLoginButton.layer.cornerRadius = 5
    }
    
    @IBAction func loginButtonTap(_ sender: UIButton) {
        guard let phoneNumber = phoneInputView.textField.text,
              let password = passwordInputView.textField.text else {return}
    }
    
    @IBAction func kakaoLoginButtonTap(_ sender: UIButton) {
        socialLoginVM.kakaoLogin{result in
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
        
    }
    
    @IBAction func facebookLoginButtonTap(_ sender: UIButton) {
        
    }
    
    @IBAction func appleLoginButtonTap(_ sender: UIButton) {
        //firebase 자격증명에 사용할..
        let cryptography = Cryptography()
        let nonce = cryptography.randomNonceString()
        loginVM.currentNonce = nonce
        
        //사용자의 전체 이름과 이메일 주소에 대한 인증 요청을 수행하여 인증 흐름을 시작
        //시스템은 사용자가 기기에서 Apple ID로 로그인했는지 확인
        //설정에서 Apple ID로 로그인하라는 경고를 표시
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        //firebase에서 사용할..
        request.nonce = cryptography.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @IBAction func googleLoginButtonTap(_ sender: UIButton) {
        socialLoginVM.googleLogin(viewController: self){result in
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
    
    func inputTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        true
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    ///인증에 성공하면 인증 컨트롤러는 앱이 사용자 데이터를 키체인에 저장하는 데 사용하는 위임 기능을 호출
    ///
    ///사용자가 처음 로그인할 때만 표시 이름 등의 사용자 정보를 앱에 공유
    ///이전에 Firebase를 사용하지 않고 Apple을 사용하여 사용자를 앱에 로그인하도록 했으면 Apple은 Firebase에 사용자의 표시 이름을 제공하지 않습니다.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            //firebase 자격증명 사용
            socialLoginVM.appleLogin(IDToken: idTokenString){result in
                if result{
                    //login 성공
                    DispatchQueue.main.async{
                        self.dismiss(animated: true)
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                else{
                }
            }
            //appleIDCredential.identityToken - 바뀜
            //appleIDCredential.user - 일정
            //fullName, email - 2번째 로그인부터 안들어옴
        default:
            break
        }
    }
}

///모달 시트에서 사용자에게 Apple로 로그인 콘텐츠를 제공하는 앱에서 창을 가져오는 함수
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
