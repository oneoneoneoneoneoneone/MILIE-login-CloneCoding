//
//  Bundle+plist.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/03.
//

import Foundation

extension Bundle {
    
    func getValue(key: String) -> String {
        // forResource에다 plist 파일 이름을 입력해주세요.
        guard let filePath = Bundle.main.path(forResource: "APIKey", ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: filePath) else {
            fatalError("Couldn't find file 'SecureAPIKeys.plist'.")
        }
        
        // plist 안쪽에 사용할 Key값을 입력해주세요.
        guard let value = plistDict.object(forKey: key) as? String else {
            fatalError("Couldn't find key 'API_Key' in 'SecureAPIKeys.plist'.")
        }
        
        // 또는 키 값을 통해 직접적으로 불러줄 수도 있어요.
        // guard let value = plistDict["API_KEY"] as? String else {
        //     fatalError("Couldn't find key 'API_Key' in 'SecureAPIKeys.plist'.")
        // }
        
        return value
    }
}
