//
//  Bundle+plist.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/03.
//

import Foundation

extension Bundle {
    
    func getplistValue(path: String, key: String) -> String {
        guard let filePath = Bundle.main.path(forResource: path, ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: filePath) else {
            fatalError("Couldn't find file '\(path).plist'.")
        }
        guard let value = plistDict.object(forKey: key) as? String else {
            fatalError("Couldn't find key \(key) in '\(path).plist'.")
        }
        
        return value
    }
    
    func getplistValue(path: String, key: String) -> [[String: Any]] {
        guard let filePath = Bundle.main.path(forResource: path, ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: filePath) else {
            fatalError("Couldn't find file '\(path).plist'.")
        }
        guard let value = plistDict.object(forKey: key) as? [[String: Any]] else {
            fatalError("Couldn't find key \(key) in '\(path).plist'.")
        }
        
        return value
    }
}
