//
//  TermsofUseViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/07.
//

import UIKit

class TermsofUseViewController: UIViewController{
    lazy var grayBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 1
        view.clipsToBounds = true
        
        return view
    }()
    
    let tableView: TermsofUseTableView = {
        let tableView = TermsofUseTableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
//    init(delegate: AgencyDelegate) {
//        self.delegate = delegate
//
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        [grayBar, tableView].forEach{
            view.addSubview($0)
        }
        
        let constraints = [
            grayBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            grayBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            grayBar.heightAnchor.constraint(equalToConstant: 5),
            grayBar.widthAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: grayBar.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
