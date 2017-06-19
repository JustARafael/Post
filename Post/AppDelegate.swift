//
//  AppDelegate.swift
//  Post
//
//  Created by RAFAEL LI CHEN on 6/5/17.
//  Copyright © 2017 RAFAEL LI CHEN. All rights reserved.
//

import UIKit
import Firebase
import LocalAuthentication

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SwiftyPlistManager.shared.start(plistNames: ["Post"], logging: false)
        FirebaseApp.configure()
        SwiftyPlistManager.shared.getValue(for: "Logout", fromPlistWithName: "Post") { (result, err) in
            if (result as? Int)! == 0 {
                SwiftyPlistManager.shared.getValue(for: "Touch ID", fromPlistWithName: "Post") { (result, err) in
                    if (result as? Int)! == 1 {
                        let context:LAContext = LAContext()
                        var error:NSError?
                        if (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error))
                        {
                            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to Login", reply: { (success, error) -> Void in
                                if (success) {
                                    let touchIdLogin = self.window?.rootViewController as! LoginViewController
                                    touchIdLogin.Email_Login.textColor = UIColor.white
                                    touchIdLogin.Password_Login.textColor = UIColor.white
                                    touchIdLogin.Email_Login.text = "rafaellichen@gmail.com"
                                    touchIdLogin.Password_Login.text = "password"
                                    touchIdLogin.Authenticate_Account()
                                }
                            })
                        }
                    }
                }
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        SwiftyPlistManager.shared.getValue(for: "Touch ID", fromPlistWithName: "Post") { (result, err) in
            if (result as? Int)! == 1 {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginInterface")
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        SwiftyPlistManager.shared.getValue(for: "Touch ID", fromPlistWithName: "Post") { (result, err) in
            if (result as? Int)! == 1 {
                SwiftyPlistManager.shared.getValue(for: "Logout", fromPlistWithName: "Post") { (result, err) in
                    if (result as? Int)! == 0 {
                        let context:LAContext = LAContext()
                        var error:NSError?
                        if (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error))
                        {
                            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to Login", reply: { (success, error) -> Void in
                                if (success) {
                                    let LoginViewController = self.window?.rootViewController as! LoginViewController
                                    LoginViewController.Email_Login.textColor = UIColor.white
                                    LoginViewController.Password_Login.textColor = UIColor.white
                                    LoginViewController.Email_Login.text = "rafaellichen@gmail.com"
                                    LoginViewController.Password_Login.text = "password"
                                    LoginViewController.Authenticate_Account()
                                }
                            })
                        }
                    }
                }
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
