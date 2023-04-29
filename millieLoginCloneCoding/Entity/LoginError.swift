//
//  LoginError.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/29.
//

import Foundation

enum LoginError: Error{
    case nilData(key: String)
    case discrepancyData(key: String)
    
    case notFoundLoginData
    case notFoundSocialJoinData(key: String)
    case foundJoinData(key: String)
    
    case notInstalledApp(key: String)
    case requestAgain(key: String)
}

extension LoginError:  LocalizedError{
    public var errorDescription: String?{
        switch self{
        case .nilData(key: let key):
            return NSLocalizedString("\(key) 값이 없습니다.", comment: "")
        case .discrepancyData(key: let key):
            return NSLocalizedString("\(key) 값이 일치하지 않습니다.", comment: "")
        case .notFoundLoginData:
            return NSLocalizedString("아이디 또는 비밀번호가 일치하지 않습니다.", comment: "")
        case .notFoundSocialJoinData(key: let key):
            return NSLocalizedString("\(key) 계정으로 가입 된 정보가 없습니다.", comment: "")
        case .foundJoinData(key: let key):
            return NSLocalizedString("이미 가입된 \(key) 입니다.", comment: "")
        case .notInstalledApp(key: let key):
            return NSLocalizedString("\(key)이 설치되지 않았습니다.", comment: "")
        case .requestAgain(key: let key):
            return NSLocalizedString(key, comment: "")
        }
    }
}
