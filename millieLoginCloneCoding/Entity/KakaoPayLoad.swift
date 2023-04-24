//
//  KakaoPayLoad.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/31.
//

import Foundation

// MARK: - PayLoad
struct PayLoad: Codable {
    let iss: String
    let aud, sub: String
    let iat, exp : Int
    let authTime: Int
    let nonce: String

    enum CodingKeys: String, CodingKey {
        case aud, sub
        case authTime = "auth_time"
        case iss, exp, iat, nonce
    }
}
