//
//  SocialJoinViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/04.
//

import UIKit
import AuthenticationServices

class SocialJoinViewController: UIViewController {
    var delegate: SocialJoinDelegate!
    
    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var kakaoJoinButton: UIButton!
    @IBOutlet weak var naverJoinButton: UIButton!
    @IBOutlet weak var facebookJoinButton: UIButton!
    @IBOutlet weak var appleJoinButton: ASAuthorizationAppleIDButton!
    @IBOutlet weak var googleJoinButton: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        baseView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        baseView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        baseView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.delegate.socialJoinDismissed()

    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations:{
            self.view.alpha = 0.1
        }){_ in
           super.dismiss(animated: flag, completion: completion)
        }
    }
    
    private func setAttribute(){
        baseView.layer.cornerRadius = 10
        
        kakaoJoinButton.layer.cornerRadius = 25
        naverJoinButton.layer.cornerRadius = 25
        facebookJoinButton.layer.cornerRadius = 25
        appleJoinButton.layer.cornerRadius = 25
        googleJoinButton.layer.cornerRadius = 25
        googleJoinButton.layer.borderWidth = 0.5
        googleJoinButton.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    @IBAction func kakaoJoinButtonTap(_ sender: UIButton) {
        dismiss(animated: false){
            self.delegate.kakaoJoin()
        }
    }
    
    @IBAction func naverJoinButtonTap(_ sender: UIButton) {
        dismiss(animated: false){
            self.delegate.naverJoin()
        }
    }
    
    @IBAction func facebookJoinButtonTap(_ sender: UIButton) {
        dismiss(animated: false){
            self.delegate.facebookJoin()
        }
    }
    
    @IBAction func appleJoinButtonTap(_ sender: UIButton) {        dismiss(animated: false){
            self.delegate.appleJoin()
        }
    }
    
    @IBAction func googleJoinButtonTap(_ sender: UIButton) {
        dismiss(animated: false){
            self.delegate.googleJoin()
        }
    }
    
    @IBAction func closeButtonTap(_ sender: UIButton) {
        self.dismiss(animated: false)
    }

}
