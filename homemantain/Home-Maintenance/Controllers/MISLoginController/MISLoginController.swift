//
//  ViewController.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
import JGProgressHUD
import VeloxDownloader

class MISLoginController: UIViewController{
	// MARK: Variables
	@IBOutlet weak var vwCharacter: UIView!
	@IBOutlet weak var tfCharacter: UITextField!
	@IBOutlet weak var btnLogin: UIButton!
    let hud = JGProgressHUD(style: .dark)
    var dlTimer = Timer()
	
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
		
	
    }
	
	// MARK: Button Actions
	@IBAction func clickLogin(_ sender: Any) {
		if  tfCharacter.text?.count != 0 && tfCharacter.text == SystemConstants.AdminPWD{
			loadDB()
        
            /*self.navigationController?.pushViewController(MISController(), animated: true)*/
		} else {
			let hud = JGProgressHUD(style: .dark)
			hud.textLabel.text = NSLocalizedString("mis_password_error", comment: "")
			hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
			hud.show(in: self.view)
			hud.dismiss(afterDelay: 1.0)
			tfCharacter.text = ""
		}
	}
    
    @objc func timerStop() {
        self.hud.dismiss(animated: false)
        let alert = UIAlertController(title: "提醒", message: "ip或網路錯誤\n", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
            self.navigationController?.popViewController(animated: true)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
	
	func loadDB() {
		hud.vibrancyEnabled = true
		hud.textLabel.text = "下載中..."
		hud.show(in: self.view)
		
		let veloxDownloader = VeloxDownloadManager.sharedInstance
		let urlString = URLConstants.DownloadDB
		let url = URL(string: urlString)
		
		let progressClosure : (CGFloat, VeloxDownloadInstance) -> (Void)
		let remainingTimeClosure : (CGFloat) -> Void
		let completionClosure : (Bool) -> Void
		
		
		progressClosure = {(progress,downloadInstace) in
			print("Progress of File : \(downloadInstace.filename) is \(Float(progress))")
			
			DispatchQueue.main.async {
				//self.incrementHUD(hud, progress: Float(progress))
			}
			
		}
		
		remainingTimeClosure = {(timeRemaning) in
			print("Remaining Time is : \(timeRemaning)")
		}
		
		completionClosure = {(status) in
            self.dlTimer.invalidate()
			print("is Download completed : \(status)")
				DispatchQueue.main.asyncAfter(deadline: .now()) {
                    if(self.hud.isVisible) {
                        self.hud.dismiss(animated: false)
						self.navigationController?.pushViewController(MISController(), animated: true)
						
					}
				}
			
		}
		
		let fileManager = FileManager.default
		do {
			let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
			let fileURL = documentDirectory.appendingPathComponent(SystemConstants.DBFileName)
            let fm = FileManager.default

            if fm.fileExists(atPath: fileURL.path) {
                try? fm.removeItem(at: fileURL)
            }
            dlTimer = Timer.scheduledTimer(timeInterval: TimeInterval(20), target: self, selector: #selector(MISLoginController.timerStop), userInfo: nil, repeats: false)
			veloxDownloader.downloadFile(
				withURL: url!,
				name: SystemConstants.DBFileName,
				directoryName: fileURL.absoluteString,
				friendlyName: nil,
				progressClosure: progressClosure,
				remainigtTimeClosure: remainingTimeClosure,
				completionClosure: completionClosure,
				backgroundingMode: false)
		} catch {
			print(error)
		}
		
	}
	/*
	func incrementHUD(_ hud: JGProgressHUD, progress: Float) {
		hud.progress = progress
		//hud.detailTextLabel.text = "\(Int(progress * 100))%"
		
		if progress == 1.0 {
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
				UIView.animate(withDuration: 0.1, animations: {
					hud.textLabel.text = "下載完成"
					hud.detailTextLabel.text = nil
					hud.indicatorView = JGProgressHUDSuccessIndicatorView()
					
					
				})
			}
		}
	}
*/
	@objc func btnBackPressed(sender: UIBarButtonItem) {
		self.navigationController?.popViewController(animated: true)
	}	
}

extension String {
    
    //将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    //将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
}

