//
//  AddScheduleViewController.swift
//  RFDanceCircle
//
//  Created by 優樹永井 on 2021/02/06.
//

import UIKit
import Firebase
import FirebaseDatabase
import ASSpinnerView

class AddScheduleViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet var button: UIButton!
    @IBOutlet weak var spinnerView: ASSpinnerView!
    
    var ref: DatabaseReference!
    
    let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.timeZone = NSTimeZone.local
        dp.locale = Locale(identifier: "ja")
        dp.addTarget(self, action: #selector(dateChange), for: .valueChanged)
        return dp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        timeTextField.inputView = datePicker
        timeTextField.delegate = self
        
        shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2
        
        shadowView.layer.cornerRadius = 7
        textView.layer.cornerRadius = 7
        textView.layer.masksToBounds = true
        
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        
        spinnerView.spinnerLineWidth = 3
        spinnerView.spinnerDuration = 0.5
        spinnerView.spinnerStrokeColor = UIColor.white.cgColor
        spinnerView.isHidden = true
        
        textView.backgroundColor = UIColor.white
        textView.textColor = UIColor.black
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func save() {
        if self.textView.text != nil && self.timeTextField.text != nil {
            // let user = Auth.auth().currentUser
            var date = self.timeTextField.text
            if let range: Range = date!.range(of: "/") {
                date?.replaceSubrange(range, with: "0")
                if let range: Range = date!.range(of: "/") {
                    date?.replaceSubrange(range, with: "0")
                }
            }
            if self.textView.text.count >= 100 {
                self.ref.child("calendar").child("\(date!)").child("date").setValue(self.timeTextField.text)
                self.ref.child("calendar").child("\(date!)").child("note").setValue(self.textView.text)
                spinnerView.isHidden = false
                let when = DispatchTime.now() + 1.5
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.spinnerView.isHidden = true
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                let alert: UIAlertController = UIAlertController(title: "文字数が足りません", message: "100文字以上入力してください！", preferredStyle:  UIAlertController.Style.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("OK")
                })
                let cancelAction: UIAlertAction = UIAlertAction(title: "前の画面に戻る", style: UIAlertAction.Style.cancel, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("Cancel")
                    self.navigationController?.popViewController(animated: true)
                })
                alert.addAction(cancelAction)
                alert.addAction(defaultAction)
                present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func dateChange(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        timeTextField.text = "\(formatter.string(from: datePicker.date))"
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return false
    }
    
    
}
