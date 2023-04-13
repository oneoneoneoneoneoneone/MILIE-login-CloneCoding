//
//  TermsofUseTableView.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/07.
//

import UIKit

@IBDesignable
class TermsofUseTableView: UITableView{
    var agreeDelegate: TermsofUseTableViewDelegate!
    
    private var terms: [[String: Any]] = []
    private var checkedCells: [Int] = []
    
    ///init 안탐
    init(agreeDelegate: TermsofUseTableViewDelegate){
        self.agreeDelegate = agreeDelegate
        
        super.init(frame: .zero, style: .plain)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setAttribute()
    }
    
    private func setAttribute(){
        self.isMultipleTouchEnabled = true
        self.separatorStyle = .none
        self.register(TermsCell.self, forCellReuseIdentifier: "TermsCell")
        
        let header = TermsHeader(frame: .zero)
        header.isUserInteractionEnabled = true
        header.allCheckButton.addTarget(self, action: #selector(allCheckButtonTap), for: .touchUpInside)
        self.tableHeaderView = header
        tableHeaderView?.frame.size.height = 60
        
        self.delegate = self
        self.dataSource = self
    }
    
    private func setAgreeCheck(_ sender: TermsCell, row: Int){
        
        if checkedCells.contains(row){
            sender.checkButton.isSelected = true
            sender.label.textColor = .black
        }
        else{
            sender.checkButton.isSelected = false
            sender.label.textColor = .darkGray
        }
        
        checkEssentialAgree()
    }
    
    private func checkEssentialAgree(){
        agreeDelegate.enabledNextButton(isEnabled: checkedCells.sorted().contains([0, 1, 2]))
    }
    
    func setData(data: [[String: Any]]){
        self.terms = data
    }
    
    @objc private func allCheckButtonTap(_ sender: UIButton){
        if !sender.isSelected {
            sender.isSelected = true
            for i in 0..<terms.count{
                checkedCells.append(i)
            }
        }
        else {
            sender.isSelected = false
            checkedCells.removeAll()
        }
        
        self.reloadData()
    }
    
    @objc private func detailButtonTap(_ sender: UIButton){
        //화면전환
        
    }
}

extension TermsofUseTableView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        terms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TermsCell", for: indexPath) as? TermsCell else {return UITableViewCell()}
//        cell.tag = indexPath.row
        cell.label.text = (terms[indexPath.row]["text"] as? String)!
        cell.detailButton.isUserInteractionEnabled = true
        cell.detailButton.addTarget(self, action: #selector(detailButtonTap), for: .touchUpInside)
        
        setAgreeCheck(cell, row: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TermsCell", for: indexPath) as? TermsCell else {return}
        
        if checkedCells.contains(indexPath.row){
            checkedCells.removeAll(where: {$0 == indexPath.row})
        }else{
            checkedCells.append(indexPath.row)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
