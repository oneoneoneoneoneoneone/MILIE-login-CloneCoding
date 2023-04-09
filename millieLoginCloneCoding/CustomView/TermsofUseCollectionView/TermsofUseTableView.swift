//
//  TermsofUseTableView.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/07.
//

import UIKit

class TermsofUseTableView: UITableView{
    var terms: [[String: Any]] = []
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        setAttribute()
        getData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setAttribute(){
        self.isMultipleTouchEnabled = true
        self.separatorStyle = .none
        self.register(TermsCell.self, forCellReuseIdentifier: "TermsCell")
        self.delegate = self
        self.dataSource = self
    }
    
    func getData(){
        terms = Bundle().getplistValue(path: "TermsofUse", key: "terms") as [[String: Any]]
    }
    
    @objc func detailButtonTap(_ sender: UIButton){
        //화면전환
        
    }
}

extension TermsofUseTableView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        terms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TermsCell", for: indexPath) as? TermsCell else {return UITableViewCell()}
        cell.tag = indexPath.row
        cell.label.text = (terms[indexPath.row]["text"] as? String)!
        cell.detailButton.addTarget(self, action: #selector(detailButtonTap), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TermsCell", for: indexPath) as? TermsCell
        
        
    }
    
}
