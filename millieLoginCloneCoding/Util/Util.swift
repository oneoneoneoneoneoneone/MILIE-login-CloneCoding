//
//  Util.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/17.
//

import Foundation

struct Util{
    static let phoneRegex = /^010-?([0-9]{4})-?([0-9]{4})$/
    static let phone10Regex = /^01([1|6|7|8|9])-?([0-9]{3})-?([0-9]{4})$/
    
    static let passwordRegex = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@$^*_-])[A-Za-z\d!@$^*_-]{8,16}$/
    static let passwordSpecialCharRegex = /[\{\}\[\]\/?.,;:|\)~`+<>\#%&\\\=\(\'\"ㄱ-힣\s]/
    static let passwordLengthRegex = /.{8,16}/
    
    static func setTimeFormat(_ timeInterval: Int) -> String {
        let time = Date(timeIntervalSince1970: TimeInterval(timeInterval))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "m:ss"
        
        return dateFormatter.string(from: time)
    }
}
