//
//  ViewController.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
import JGProgressHUD

class IPController: UIViewController{
	// MARK: Variables
	@IBOutlet weak var vwCharacter: UIView!
	@IBOutlet weak var tfCharacter: UITextField!
	@IBOutlet weak var btnLogin: UIButton!
	var ip = ""
	
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
		//init back button
		let btnBack = NaviTool.initBtnBack()
		btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
		self.view.addSubview(btnBack)
		
		//init character view
		vwCharacter.clipsToBounds = true
		vwCharacter.layer.cornerRadius = 5.0
		vwCharacter.layer.borderColor = UIColor.black.cgColor
		vwCharacter.layer.borderWidth = 1.0
		
		//init btnLogin
		btnLogin.clipsToBounds = true
		btnLogin.layer.cornerRadius = 5.0
		
		if UserDefaults.standard.string(forKey: "IP") == nil {
			ip = URLConstants.DefaultIP
		} else {
			ip = UserDefaults.standard.string(forKey: "IP")!
		}
		tfCharacter.placeholder = ip.prefix(6) + "********"
	}
	
	
	// MARK: Button Actions
	@IBAction func clickLogin(_ sender: Any) {
		//if tfCharacter.text?.count != 0 && isValidIP(s: tfCharacter.text!) {
		if tfCharacter.text?.count != 0 && isValidIP(s: tfCharacter.text!) {
			ip = tfCharacter.text!
        } else if tfCharacter.text?.count != 0 {
            let hud = JGProgressHUD(style: .dark)
            hud.textLabel.text = NSLocalizedString("ip_error", comment: "")
            hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.0)
            return
        }
		if  ip.count != 0 && isValidIP(s: ip) {
			UserDefaults.standard.set(ip, forKey: "IP")
			self.navigationController?.pushViewController(MISLoginController(), animated: true)
		} else {
			let hud = JGProgressHUD(style: .dark)
			hud.textLabel.text = NSLocalizedString("ip_error", comment: "")
			hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
			hud.show(in: self.view)
			hud.dismiss(afterDelay: 1.0)
		}
	}
	@objc func btnBackPressed(sender: UIBarButtonItem) {
		self.navigationController?.popViewController(animated: true)
	}
	
	func isValidIP(s: String) -> Bool {
		var address = s
		if(address.contains(":")) {
			address = address.substring(to: address.index(of: ":")!)
		}
		let parts = address.components(separatedBy:".")
		let nums = parts.flatMap { Int($0) }
		return parts.count == 4 && nums.count == 4 && nums.filter { $0 >= 0 && $0 < 256}.count == 4
	}
	
	
}

