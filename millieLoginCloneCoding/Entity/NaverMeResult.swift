//
//  NaverMeResult.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/23.
//

import Foundation

// MARK: - Welcome
struct Welcome: Decodable {
    let resultcode, message: String
    let response: Response
}

// MARK: - Response
struct Response: Decodable {
    let id, nickname: String
    let profileImage: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case id, nickname
        case profileImage = "profile_image"
        case email
    }
}
