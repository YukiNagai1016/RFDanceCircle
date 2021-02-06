//
//  AppDelegate.swift
//  RFDanceCircle
//
//  Created by 優樹永井 on 2021/02/06.
//

import UIKit
import Firebase
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    override init() {
        super.init()
        FirebaseApp.configure()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //AdMob
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // UserDefaultsの設定
        let ud = UserDefaults.standard
        let isLogin = ud.bool(forKey: "isLogin")
        
        if Auth.auth().currentUser != nil {
            print("ログインちゃんとできてまっせ")
            // ログイン中
            let storyboard:UIStoryboard = UIStoryboard(name: "Main",bundle:Bundle.main)
            window?.rootViewController
                = storyboard.instantiateViewController(withIdentifier: "Main")
            self.window?.makeKeyAndVisible()
        } else {
            let storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle:Bundle.main)
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "Login")
            self.window?.makeKeyAndVisible()
        }
        return true
        return true
    }

}

