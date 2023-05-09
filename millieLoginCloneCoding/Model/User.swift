//
//  User.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/05.
//

import Foundation

struct User: Codable {
    let id: String
    let email: String
    let phone: String
    let password: String
}

enum loginType: String, Codable{
    case phone, naver, kakao, facebook, apple, google
}
