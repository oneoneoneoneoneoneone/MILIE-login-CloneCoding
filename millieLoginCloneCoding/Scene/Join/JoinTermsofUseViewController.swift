//
//  JoinTermsofUseViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/03.
//

import UIKit

protocol TermsofUseTableViewDelegate{
    func enabledNextButton(isEnabled: Bool)
}

///소셜로그인
class JoinTermsofUseViewController: UIViewController {
    private var loginVM: LoginProtocol?
    
    @IBOutlet weak var tableView: TermsofUseTableView!
    @IBOutlet weak var nextButton: UIButton!
    
    init?(coder: NSCoder, loginVM: LoginProtocol?){
        self.loginVM = loginVM
        super.init(coder: coder)
    }
    
    @available(*, unavailable, renamed: "init(coder:delegate:)")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setData()
    }
    
    private func setData(){
        var terms = Bundle().getplistValue(path: "TermsofUse", key: "terms") as [[String: Any]]
        terms.remove(at: 3)
        
        tableView.setData(data: terms)
        tableView.agreeDelegate = self
    }
    
    @IBAction func nextButtonTap(_ sender: UIButton) {
        let joinProfileViewController =  UIStoryboard(name: "Join", bundle: nil)
            .instantiateViewController(identifier: "JoinProfileViewController"){ (coder) -> JoinProfileViewController? in
                return .init(coder: coder, loginVM: self.loginVM)
            }
        
        self.navigationController?.pushViewController(joinProfileViewController, animated: true)
    }
}

extension JoinTermsofUseViewController: TermsofUseTableViewDelegate{
    func enabledNextButton(isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
    }
}
