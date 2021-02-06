//
//  ScheduleViewController.swift
//  RFDanceCircle
//
//  Created by 優樹永井 on 2021/02/06.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import Firebase
import FirebaseDatabase
import ASSpinnerView
import FirebaseAuth

class ScheduleViewController: UIViewController ,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var selectedLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet var button: UIButton!
    @IBOutlet var barButtonRightItem: UIBarButtonItem!
    @IBOutlet var barButtonLeftItem: UIBarButtonItem!
    @IBOutlet weak var spinnerView: ASSpinnerView!
    @IBOutlet var backgroundView: UIView!
    
    var ref: DatabaseReference!
    var isPoint: Bool! = false
    var notes: [Notes] = []
    var points: [Points] = []
    var number = 0
    var users: [Users] = []
    var contentsBool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendar.dataSource = self
        self.calendar.delegate = self
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        shadowView.layer.shadowColor = UIColor.white.cgColor
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowRadius = 4
        
        shadowView.layer.cornerRadius = 5
        detailTextView.layer.cornerRadius = 5
        detailTextView.layer.masksToBounds = true
        
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        
        ref = Database.database().reference()
        
        spinnerView.spinnerLineWidth = 3
        spinnerView.spinnerDuration = 0.5
        spinnerView.spinnerStrokeColor = UIColor.black.cgColor
        spinnerView.isHidden = true
        
        detailTextView.backgroundColor = UIColor.white
        
        let dt = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy/MM/dd", options: 0, locale: Locale(identifier: "ja_JP"))
        print(dateFormatter.string(from: dt))
        //self.selectedLabel.text = dateFormatter.string(from: dt)
        
        loadUser()
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        // read image
        let image = UIImage(named: "backgroundgreen.png")
        // set image to ImageView
        imageView.image = image
        // set alpha value of imageView
        imageView.alpha = 0.2
        // set imageView to backgroundView of CollectionView
        self.backgroundView.addSubview(imageView)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.dateStyle = .medium
        return formatter
    }()
    
    // 祝日判定を行い結果を返すメソッド(True:祝日)
    func judgeHoliday(_ date : Date) -> Bool {
        //祝日判定用のカレンダークラスのインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)
        
        // 祝日判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        
        // CalculateCalendarLogic()：祝日判定のインスタンスの生成
        let holiday = CalculateCalendarLogic()
        
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    // date型 -> 年月日をIntで取得
    func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }
    
    //曜日判定(日曜日:1 〜 土曜日:7)
    func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    
    // 土日や祝日の日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        //祝日判定をする（祝日は赤色で表示する）
        if self.judgeHoliday(date){
            return UIColor.red
        }
        
        //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekday = self.getWeekIdx(date)
        if weekday == 1 {   //日曜日
            return UIColor.red
        }
        else if weekday == 7 {  //土曜日
            return UIColor.blue
        }
        
        return nil
    }
    
//    func calendar(calendar: FSCalendar!, hasEventForDate date: NSDate!) -> Bool {
//
//        return shouldShowEventDot
//    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        let nmonth = NSString(format: "%02d", month) as! String
        let nday = NSString(format: "%02d", day) as! String
        
        selectedLabel.text = "\(year)/\(nmonth)/\(nday)"
        
        self.loadUser()
        self.pointCalculate()
        self.loadData()
    }
    
    func loadData() {
        ref.child("calendar").observe(DataEventType.value) { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for (key, val) in values {
                    let obs: NSDictionary! = val as! NSDictionary
                    let date = obs.value(forKey: "date") as! String
                    if obs.value(forKey: "note") != nil {
                        let note = obs.value(forKey: "note") as! String
                        let noteContents = Notes(date: date, note: note)
                        self.notes.append(noteContents)
                        print("読み取りは成功")
                    }
                }
                self.spinnerView.isHidden = false
                let when = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: when) {
                    
                    self.spinnerView.isHidden = true
                    for data in self.notes {
                        if  self.selectedLabel.text == data.date {
                            self.detailTextView.text = data.note
                            if data.note != nil {
                                self.contentsBool = true
                            }
                            print("大成功！！")
                            self.notes.removeAll()
                            return
                        } else {
                            print("大失敗")
                            self.detailTextView.text = " "
                        }
                    }
                }
            }
        }
    }
    
    func loadUser() {
        ref.child("user").observe(DataEventType.value) { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for (key, val) in values {
                    let userName = key
                    let ob: NSDictionary! = val as! NSDictionary
                    let attribute = ob.value(forKey: "attribute") as! String
                    let name = ob.value(forKey: "name") as! String
                    let mail = ob.value(forKey: "mail") as! String
                    let point = ob.value(forKey: "point") as! Int
                    let userInfo = Users(userName: name, mail: mail, attribute: attribute, point: point, uid: Auth.auth().currentUser!.uid)
                    self.users.append(userInfo)
                    let user = Auth.auth().currentUser
                    if user?.email == mail {
                        for user in self.users {
                            if user.attribute == "Member" {
                                self.barButtonRightItem.isEnabled = false
                                self.barButtonLeftItem.isEnabled = false
                                self.detailTextView.isEditable = false
                                self.barButtonRightItem.tintColor = UIColor.clear
                                self.barButtonLeftItem.tintColor = UIColor.clear
                            } else if user.attribute == "Teacher" {
                                self.barButtonRightItem.isEnabled = true
                                self.barButtonLeftItem.isEnabled = true
                                self.detailTextView.isEditable = true
                                self.barButtonRightItem.tintColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                                self.barButtonLeftItem.tintColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    @IBAction func participate() {
        if Auth.auth().currentUser != nil {
            var date = self.selectedLabel.text
            let userID = Auth.auth().currentUser?.uid
            if let range: Range = date!.range(of: "/") {
                date?.replaceSubrange(range, with: "0")
                if let range: Range = date!.range(of: "/") {
                    date?.replaceSubrange(range, with: "0")
                }
            }
            date = date! + userID!
            self.ref.child("point").child("\(date!)").setValue(self.selectedLabel.text)
            
            self.spinnerView.isHidden = false
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.pointCalculate()
                self.spinnerView.isHidden = true
            }
        }
    }
    
    func pointCalculate() {
        ref.child("point").observe(DataEventType.value) { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for (key, val) in values {
                    if Auth.auth().currentUser != nil {
                        let ob: String! = key as? String
                        let data = ob.prefix(10)
                        var labelDate = self.selectedLabel.text
                        if let range: Range = labelDate!.range(of: "/") {
                            labelDate?.replaceSubrange(range, with: "0")
                            if let range: Range = labelDate!.range(of: "/") {
                                labelDate?.replaceSubrange(range, with: "0")
                            }
                        }
                        let labelDateString = labelDate!
                        if labelDateString == data {
                            self.number += 1
                            print("正しい！")
                        }
                    }
                    
                }
                self.pointLabel.text = String(self.number)
                self.number = 0
            }
        }
    }
    
    @IBAction func editRefresh() {
        if self.detailTextView.text != nil {
            // let user = Auth.auth().currentUser
            var date = self.selectedLabel.text
            if let range: Range = date!.range(of: "/") {
                date?.replaceSubrange(range, with: "0")
                if let range: Range = date!.range(of: "/") {
                    date?.replaceSubrange(range, with: "0")
                }
            }
            if self.detailTextView.text.count >= 100 {
                self.ref.child("calendar").child("\(date!)").child("note").setValue(self.detailTextView.text)
                spinnerView.isHidden = false
                let when = DispatchTime.now() + 1.5
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.spinnerView.isHidden = true
                    self.loadData()
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
    
}

