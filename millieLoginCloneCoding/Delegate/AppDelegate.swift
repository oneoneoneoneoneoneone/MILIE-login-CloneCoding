//
//  AppDelegate.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/28.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import KakaoSDKCommon
import NaverThirdPartyLogin

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //firebase 초기화
        FirebaseApp.configure()
        
        //kakao key 설정
        KakaoSDK.initSDK(appKey: Bundle.main.getplistValue(path: "APIKey", key: "Kakao-Native-App-Key"))
        
        //naver key 설정
        let naverConn: NaverThirdPartyLoginConnection = NaverThirdPartyLoginConnection.getSharedInstance()
        naverConn.serviceUrlScheme = "naverlogin"//kServiceAppUrlScheme
        naverConn.consumerKey = Bundle.main.getplistValue(path: "APIKey", key: "Naver-Consumer-Key")
        naverConn.consumerSecret = Bundle.main.getplistValue(path: "APIKey", key: "Naver-Consumer-Secret")
        naverConn.appName = "MillieLoginCloneCoding"//kServiceAppName
        //naver app으로 열기
        naverConn.isNaverAppOauthEnable = true
        naverConn.isInAppOauthEnable = true
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        //GIDSignIn 인스턴스의 handleURL 메서드를 호출하여 인증 프로세스가 끝날 때 애플리케이션이 수신하는 URL을 적절히 처리
        if GIDSignIn.sharedInstance.handle(url){
            return true
        }
        
        if NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options){
            return true
        }
        
        return false
    }
}
