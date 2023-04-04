//
//  AgencySelectViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/04.
//

import UIKit

class AgencySelectViewController: UIViewController{
    final let agencyList = ["SKT", "KT", "LG U+", "SKT 알뜰폰", "KT 알뜰폰", "LG U+ 알뜰폰"]
    let delegate: AgencyDelegate?

    lazy var grayBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 1
        view.clipsToBounds = true
        
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        
        let label = UILabel()
        label.text = "통신사 선택"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        tableView.tableHeaderView = label
        
        tableView.dataSource = self
        tableView.delegate = self

        return tableView
    }()
    
    init(delegate: AgencyDelegate) {
        self.delegate = delegate
    
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        delegate?.dismissed()
    }
}

extension AgencySelectViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        agencyList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = agencyList[indexPath.row]

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.sendValue(selectedAgency: agencyList[indexPath.row])
        self.dismiss(animated: true)
    }
}
