//
//  ViewController.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
import JGProgressHUD
import SQLite
import FSCalendar

class BookingController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var lblDate: UILabel!
    // MARK: Variables
    var lunarCalendar:NSCalendar?
    var lunarChars:[String] = []
    var targetDate = Date()
    let dateFormatter = DateFormatter()
    let dateFormatterBook = DateFormatter()
    var bookingDates = ["2018/06/20", "2018/06/25", "2018/06/28", "2018/06/30", "2018/07/05", "2018/07/07", "2018/07/10", "2018/07/18"]
    var bookingDatas:[BookingData] = []
    @IBOutlet weak var tableView: UITableView!
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    @IBOutlet weak var calendar: FSCalendar!
    
	// MARK: Life Circle
	override func viewDidLoad() {
		super.viewDidLoad()
        initData()
		initLayaout()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: Custom Functions
	func initLayaout() {
		//Change orientation
		let value = UIInterfaceOrientation.landscapeRight.rawValue
		UIDevice.current.setValue(value, forKey: "orientation")
		
		//init back button
		let btnBack = NaviTool.initBtnBack()
		btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
		self.view.addSubview(btnBack)
        tableView.register(UINib(nibName: "BookingCell", bundle: nil), forCellReuseIdentifier: "BookingCell")
        self.calendar.today = nil;
        self.calendar.locale = Locale.init(identifier: "zh-TW")
        self.calendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 25)
        self.calendar.appearance.headerTitleColor = UIColor.white
        self.calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 18)
        self.calendar.appearance.titleFont = UIFont.systemFont(ofSize: 20)
        self.calendar.appearance.subtitleFont = UIFont.systemFont(ofSize: 16)
         self.calendar.calendarHeaderView.backgroundColor = UIColor(red: 144/255, green: 33/255, blue: 38/255, alpha: 1)
        self.calendar.calendarWeekdayView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        self.calendar.calendarWeekdayView.layer.borderWidth = 0.3
        self.calendar.calendarWeekdayView.layer.borderColor = UIColor.white.cgColor
        self.calendar.select(targetDate)
        dateFormatter.dateFormat = "yyyy年M月d日"
        dateFormatterBook.dateFormat = "yyyy/MM/dd"
        lblDate.text =  dateFormatter.string(from: targetDate)
        lunarCalendar = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.chinese)
        lunarCalendar?.locale = Locale.init(identifier: "zh-TW")
        lunarChars = ["初一","初二","初三","初四","初五","初六","初七","初八","初九","初十","十一","十二","十三","十四","十五","十六","十七","十八","十九","二十","二一","二二","二三","二四","二五","二六","二七","二八","二九","三十"]
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "cell")
        var index = 0
        for label in calendar.calendarWeekdayView.weekdayLabels {
            if index == 0 || index == 6 {
                label.textColor = UIColor(red: 144/255, green: 33/255, blue: 38/255, alpha: 1)
            } else {
                label.textColor = UIColor.black
            }
            switch index {
            case 0:
                label.text = "星期日"
                break
            case 1:
                label.text = "星期ㄧ"
                break
            case 2:
                label.text = "星期二"
                break
            case 3:
                label.text = "星期三"
                break
            case 4:
                label.text = "星期四"
                break
            case 5:
                label.text = "星期五"
                break
            case 6:
                label.text = "星期六"
                break
            default:
                break
            }
            
            index += 1
        }
        
       
        
		
	}
	
	func initData() {
		var data = BookingData()
        data.timeString = "09:00-10:00"
        data.customorName = "黃先生"
        bookingDatas.append(data)
        data = BookingData()
        data.timeString = "09:00-11:00"
        data.customorName = "李小姐"
        bookingDatas.append(data)
        data = BookingData()
        data.timeString = "12:00-14:00"
        data.customorName = "張先生"
        bookingDatas.append(data)
        data = BookingData()
        data.timeString = "13:00-14:00"
        data.customorName = "袁先生"
        bookingDatas.append(data)
        data = BookingData()
       
        data.timeString = "14:00-15:00"
        data.customorName = "陳小姐"
        bookingDatas.append(data)
        data = BookingData()
        data.timeString = "14:00-16:00"
        data.customorName = "洪先生"
        bookingDatas.append(data)
        data = BookingData()
         /*
        data.timeString = "16:00-17:00"
        data.customorName = "張小姐"
        bookingDatas.append(data)
 */
       
	}
	
	@objc func btnBackPressed(sender: UIBarButtonItem) {
		self.navigationController?.popViewController(animated: true)
	}
	
	
	
	// control orientation
	override var shouldAutorotate: Bool {
		return false
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .landscapeRight
	}
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        cell.layer.borderWidth = 0.3
        cell.layer.borderColor = UIColor(red: 144/255, green: 33/255, blue: 38/255, alpha: 1).cgColor
        if self.gregorian.isDateInToday(date) {
            cell.titleLabel.textColor = UIColor(red: 144/255, green: 33/255, blue: 38/255, alpha: 1)
        }
        return cell
    }
    
    
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        if self.gregorian.isDateInToday(date) {
            return "今天"
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        let day = lunarCalendar?.components(.day, from: date).day
        return lunarChars[day!-1]
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if self.gregorian.isDateInToday(date) {
            return UIColor(red: 144/255, green: 33/255, blue: 38/255, alpha: 1)
        }
        return nil
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return UIColor(red: 144/255, green: 33/255, blue: 38/255, alpha: 1)
    }
    
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        let dateString = dateFormatterBook.string(from: date)
        if bookingDates.contains(dateString) {
            return UIImage(named: "booking_icon")
        } else {
           return nil
        }
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventColorFor date: Date) -> UIColor? {
        return UIColor(red: 144/255, green: 33/255, blue: 38/255, alpha: 1)
    }
	
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dateString = dateFormatterBook.string(from: targetDate)
        if bookingDates.contains(dateString) {
            return Int(arc4random_uniform(UInt32(bookingDatas.count)) + 1)
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as! BookingCell
        let data = bookingDatas[indexPath.row]
        cell.lblTitle.text = String(format: "%@ 驗屋(%@)", data.timeString, data.customorName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let data = bookingDatas[indexPath.row]
        let bookingInfoController = BookingInfoController()
        bookingInfoController.name = data.customorName
        bookingInfoController.time = String(format: "%@ %@", dateFormatter.string(from: targetDate), data.timeString)
        bookingInfoController.modalPresentationStyle = .overCurrentContext
        present(bookingInfoController, animated: false, completion: nil)
       
    }

    @IBAction func clickAdd(_ sender: Any) {
        let addBookingController = AddBookingController()
        addBookingController.modalPresentationStyle = .overCurrentContext
        present(addBookingController, animated: false, completion: nil)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        targetDate = date
        lblDate.text = dateFormatter.string(from: targetDate)
        tableView.reloadData()
    }
}



class BookingData {
    var timeString = ""
    var customorName = ""
}

