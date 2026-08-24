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

class LoginController: UIViewController {
	// MARK: Variables
	@IBOutlet weak var tfAccount: UITextField!
	@IBOutlet weak var tfPasswd: UITextField!
	@IBOutlet weak var btnLogin: UIButton!
	
	// MARK: Life Circle
	override func viewDidLoad() {
		super.viewDidLoad()
		initLayaout()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: Custom Functions
	func initLayaout() {
		//init account textfield
		tfAccount.leftViewMode = .always
		let accImgView = UIImageView(frame: CGRect(x:0, y:0, width:60.0, height:40.0))
		accImgView.contentMode = .scaleAspectFit
		accImgView.image = UIImage(named: "Icon_Account")
		tfAccount.leftView = accImgView
		
		//init passwd textfield
		tfPasswd.leftViewMode = .always
		let passwdImgView = UIImageView(frame: CGRect(x:0, y:0, width:60.0, height:40.0))
		passwdImgView.contentMode = .scaleAspectFit
		passwdImgView.image = UIImage(named: "Icon_Password")
		tfPasswd.leftView = passwdImgView
		
		//init login button
		btnLogin.clipsToBounds = true
		btnLogin.layer.cornerRadius = 5.0
		
		//add loading indicator
		//showPieHUD()
	}
	
	func showPieHUD() {
		let hud = JGProgressHUD(style: .dark)
		hud.vibrancyEnabled = true
		hud.indicatorView = JGProgressHUDPieIndicatorView()
		hud.detailTextLabel.text = "0%"
		hud.textLabel.text = "下載中..."
		hud.show(in: self.view)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
			self.incrementHUD(hud, progress: 0)
		}
	}
	
	func incrementHUD(_ hud: JGProgressHUD, progress previousProgress: Int) {
		let progress = previousProgress + 1
		hud.progress = Float(progress)/100.0
		hud.detailTextLabel.text = "\(progress)%"
		
		if progress == 100 {
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
				UIView.animate(withDuration: 0.1, animations: {
					hud.textLabel.text = "下載完成"
					hud.detailTextLabel.text = nil
					hud.indicatorView = JGProgressHUDSuccessIndicatorView()
				})
				
				hud.dismiss(afterDelay: 1.0)
			}
		}
		else {
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
				self.incrementHUD(hud, progress: progress)
			}
		}
	}
	
	func loginSuccess(success:Bool) {
		//push controller when success, show login error message
		if success {
			tfAccount.text = ""
			tfPasswd.text = ""
			self.navigationController?.pushViewController(FunctionSelectController(), animated: true)
			
		} else {
			tfPasswd.text = ""
			let hud = JGProgressHUD(style: .dark)
			hud.textLabel.text = NSLocalizedString("login_error", comment: "")
			hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
			hud.show(in: self.view)
			hud.dismiss(afterDelay: 1.0)
		}
		
	}
	/*
	func MD5(string: String) -> Data {
		let messageData = string.data(using:.utf8)!
		var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
		
		_ = digestData.withUnsafeMutableBytes {digestBytes in
			messageData.withUnsafeBytes {messageBytes in
				CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
			}
		}
		
		return digestData
	}
*/
	
	// MARK: Button Actions
	@IBAction func clickLogin(_ sender: Any) {
		//simulate api login
		//print(MD5(string: tfPasswd.text!).base64EncodedString())
		if login(account: tfAccount.text!, pwd: tfPasswd.text!) {
			loginSuccess(success: true)
		} else {
			loginSuccess(success: false)
		}
		
	}
	
	func login(account:String, pwd:String) -> Bool {
		do {
            
			let fileManager = FileManager.default
			let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
			let fileURL = documentDirectory.appendingPathComponent(SystemConstants.DBFileName)
			
			let db = try Connection(fileURL.absoluteString)
			//all fine with jsonData here
			let users = Table("UserMain")
			let useridx = Expression<String>("idx")
			let userid = Expression<String>("userid")
			let userpwd = Expression<String>("userpwd")
			
			let query = users.select(useridx, userid, userpwd)
				.filter(userid == account && userpwd == pwd)
			
			let count = try db.scalar(query.count)
			if count != 0 {
				for data in try db.prepare(query) {
					print("name: \(data[useridx])")
					UserDefaults.standard.set(data[useridx], forKey: "UserIdx")
					UserDefaults.standard.set(data[userid], forKey: "UserId")
				}
				return true
			} else {
				return false
			}
			
		} catch {
			//handle error
			print(error)
		}
		return false
	}
	
	@IBAction func btnSettingPressed(_ sender: Any) {
		self.navigationController?.pushViewController(IPController(), animated: true)
	}
}
