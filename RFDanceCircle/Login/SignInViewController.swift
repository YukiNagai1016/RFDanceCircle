//
//  SignInViewController.swift
//  RFDanceCircle
//
//  Created by 優樹永井 on 2021/02/06.
//

import UIKit

import UIKit
import AnimatedField
import Firebase
import ASSpinnerView

class SignInViewController: UIViewController {
    
    @IBOutlet weak var mailField: AnimatedField!
    @IBOutlet weak var passField: AnimatedField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var spinnerView: ASSpinnerView!
    
    var changed: AuthStateDidChangeListenerHandle!
    var yukinagaiID = "2RkMDh7SUDZDQBBkWg0YDk2kckN2"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animatedFieldFormat()
        mailField.placeholder = "mail address"
        passField.placeholder = "password"
        passField.isSecure = true
        
        loginButton.layer.cornerRadius = 20
        loginButton.layer.masksToBounds = true
        
        
        spinnerView.spinnerLineWidth = 3
        spinnerView.spinnerDuration = 0.5
        spinnerView.spinnerStrokeColor = UIColor.black.cgColor
        spinnerView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        changed = Auth.auth().addStateDidChangeListener({ (auth, user) in
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        Auth.auth().removeStateDidChangeListener(changed)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func Login() {
        let email = self.mailField.text
        let password = self.passField.text
        spinnerView.isHidden = false
        Auth.auth().signIn(withEmail: email ?? "", password: password ?? "") { (auth, error) in
            if error != nil {
                print("ログイン失敗")
                self.spinnerView.isHidden = true
                let alert: UIAlertController = UIAlertController(title: "メールアドレスまたはパスワードが違います", message: "もう一度入力し直してください", preferredStyle:  UIAlertController.Style.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("OK")
                })
                
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                print("ログイン成功！！！")
                print(self.yukinagaiID.count)
                // ログイン状態を保持
                let ud = UserDefaults.standard
                ud.set(true, forKey: "isLogin")
                ud.synchronize()
                
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.spinnerView.isHidden = true
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let next: UIViewController = storyboard.instantiateInitialViewController() as! UIViewController
                    self.present(next, animated: true, completion: nil)
                }
            }
        }
    }
    
    func animatedFieldFormat() {
        var format = AnimatedFieldFormat()
        
        /// Title always visible
        format.titleAlwaysVisible = true
        
        /// Font for title label
        format.titleFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        /// Font for text field
        format.textFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        /// Font for counter
        format.counterFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        /// Line color
        format.lineColor = UIColor.black
        
        /// Title label text color
        format.titleColor = UIColor.black
        
        /// TextField text color
        format.textColor = UIColor.black
        
        /// Counter text color
        format.counterColor = UIColor.black
        
        /// Enable alert
        format.alertEnabled = true
        
        /// Font for alert label
        format.alertFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        /// Alert status color
        format.alertColor = UIColor.red
        
        /// Colored alert field text
        format.alertFieldActive = true
        
        /// Colored alert line
        format.alertLineActive = true
        
        /// Colored alert title
        format.alertTitleActive = true
        
        /// Alert position
        format.alertPosition = .top
        
        /// Enable counter label
        format.counterEnabled = false
        
        /// Set count down if counter is enabled
        format.countDown = false
        
        /// Enable counter animation on change
        format.counterAnimation = false
        
        /// Highlight color when becomes active
        format.highlightColor = UIColor.darkGray
        
        mailField.format = format
        passField.format = format
    }
    
    
    
}
