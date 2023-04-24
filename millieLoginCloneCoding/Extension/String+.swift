//
//  String+.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/04.
//

import Foundation

extension String {
    func base64Encoded() -> String? { // base64 인코딩 수행 실시
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return ""
    }

    func base64Decoded() -> String? { // base64 디코딩 수행 실시
        if let data = Data(base64Encoded: self.padding(toLength: ((self.count+3)/4)*4, withPad: "=", startingAt: 0), options: .ignoreUnknownCharacters) {
            return String(data: data, encoding: .utf8)
        }
        
        return ""
    }
}
