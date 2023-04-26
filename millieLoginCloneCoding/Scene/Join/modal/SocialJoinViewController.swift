//
//  SocialJoinViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/04.
//

import UIKit

protocol SocialJoinModalDelegate{
    func socialJoinDismissed()
}

class SocialJoinViewController: UIViewController {
    private var viewController: UIViewController?
    private var viewDelegate: SocialJoinDelegate?
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var socialView: SocialView!
    
    //코드에서 스토리보드로 초기화할때 호출되는 init
    init?(coder: NSCoder, viewController: UIViewController?, viewDelegate: SocialJoinDelegate?) {
        self.viewController = viewController
        self.viewDelegate = viewDelegate
        super.init(coder: coder)
    }
    
    @available(*, unavailable, renamed: "init(coder:delegate:)")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewController?.view.alpha = 1

    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations:{
            if flag{
                self.view.alpha = 0.1
            }
        })
        {_ in
           super.dismiss(animated: false, completion: completion)
        }
    }
    
    private func setAttribute(){
        socialView.initSocialView(viewController: viewController, viewDelegate: viewDelegate, modalViewController: self)
        baseView.layer.cornerRadius = 10
    }
    
    private func setLayout(){
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        baseView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        baseView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35).isActive = true
        baseView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
    }
    
    @IBAction func closeButtonTap(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
