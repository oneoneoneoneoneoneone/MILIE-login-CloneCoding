//
//  User.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/05.
//

import Foundation

struct User: Codable {
    let email, id, image, name: String
    let nickname, password, phone: String
}
