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

class ChooseProjectController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
	// MARK: Variables
	@IBOutlet weak var vwCharacter: UIView!
	@IBOutlet weak var vwProject: UIView!
	@IBOutlet weak var tfCharacter: UITextField!
	@IBOutlet weak var tfProject: UITextField!
	@IBOutlet weak var btnConfirm: UIButton!
	var characters = ["業主", "工務"]
	var projectsData = [] as [String]
	var projectsNoData = [] as [String]
    var copNoData = [] as [String]
	var characterIndex = 0
	var projectIndex = 0
	
	// MARK: Life Circle
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		initLayaout()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: Custom Functions
	func initLayaout() {
		initData()
		
		//Change orientation
		let value = UIInterfaceOrientation.portrait.rawValue
		UIDevice.current.setValue(value, forKey: "orientation")
		
		//init back button
		let btnBack = NaviTool.initBtnBack()
		btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
		self.view.addSubview(btnBack)
		
		//init character view
		vwCharacter.clipsToBounds = true
		vwCharacter.layer.cornerRadius = 5.0
		vwCharacter.layer.borderColor = UIColor.black.cgColor
		vwCharacter.layer.borderWidth = 1.0
		
		//need load api data first
		//init textFields
		if characters.count != 0 {
			characterIndex = 0
			tfCharacter.text = characters[characterIndex]
		} else {
			characterIndex = -1
		}
		tfCharacter.tintColor = .clear
		initTextField(textField: tfCharacter, tag: 0)
		
		if projectsData.count != 0 {
			projectIndex = 0
			tfProject.text = projectsData[projectIndex]
		} else {
			projectIndex = -1
		}
		tfProject.tintColor = .clear
		initTextField(textField: tfProject, tag: 1)
		
		//init project view
		vwProject.clipsToBounds = true
		vwProject.layer.cornerRadius = 5.0
		vwProject.layer.borderColor = UIColor.black.cgColor
		vwProject.layer.borderWidth = 1.0
	}
	
	func initData() {
		do {
			//check if data is download
			let userDefaults = UserDefaults.standard
			if userDefaults.dictionary(forKey: "downloadSqlite") != nil {
				var downloadSqlite = [:] as [String:[String]]
				downloadSqlite = userDefaults.dictionary(forKey: "downloadSqlite") as! [String : [String]]
				
				for key in downloadSqlite.keys {
					let buildings = downloadSqlite[key]
					if buildings?.count != 0 {
						let fileManager = FileManager.default
						let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
						let fileURL = documentDirectory.appendingPathComponent(SystemConstants.DBFileName)
						
						let db = try Connection(fileURL.absoluteString)
						
						
						let projects = Table("HomeProject")
						let project_name = Expression<String?>("PROJM_NAME")
                        let COP_NO = Expression<String?>("COP_NO")
                        let project_no = Expression<String?>("PROJM_NO")
                        let query = projects.select(project_name, COP_NO).filter(project_no == key)
                        
                        for project in try db.prepare(query) {
                            print("name: \(project[project_name]!), key: \(key)")
                            projectsData.append(project[project_name]!)
                            copNoData.append(project[COP_NO]!)
                            projectsNoData.append(key)
                        }
					}
					
				}
				
			}
		} catch {
			//handle error
			print(error)
		}
	}
	
	func initTextField(textField: UITextField, tag: Int) {
        textField.tintColor = UIColor.clear
		//set dropdown image
		textField.rightViewMode = .always
		let dropdownImgView = UIImageView(frame: CGRect(x:0, y:0, width:60.0, height:40.0))
		dropdownImgView.contentMode = .scaleAspectFit
		dropdownImgView.image = UIImage(named: "Icon_Drop")
		textField.rightView = dropdownImgView
		
		//setup picker
		let picker: UIPickerView
		picker = UIPickerView(frame: CGRect(x:0, y:0, width:view.frame.width, height:300))
		picker.backgroundColor = .white
		
		picker.showsSelectionIndicator = true
		picker.delegate = self
		picker.dataSource = self
		picker.tag = tag
		
		let bgView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
		
		bgView.addSubview(picker)
		
		textField.inputView = bgView
	}

	// MARK: Button Actions
	@IBAction func clickConfirm(_ sender: Any) {
		if characterIndex == -1 || projectIndex == -1 {
			let hud = JGProgressHUD(style: .dark)
			hud.textLabel.text = NSLocalizedString("choose_character_project_again", comment: "")
			hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
			hud.show(in: self.view)
			hud.dismiss(afterDelay: 1.0)
		}
		else {
			//go to dashboard page
            UserDefaults.standard.setValue(tfProject.text, forKey: "PROJECT_NAME")
            UserDefaults.standard.setValue(projectsNoData[projectIndex], forKey: "PROJECT_NO")
            UserDefaults.standard.setValue(projectIndex, forKey: "PROJECT_INDEX")
            UserDefaults.standard.setValue(copNoData[projectIndex], forKey: "COP_NO")
            UserDefaults.standard.setValue(tfCharacter.text, forKey: "CHARACTER_NAME")
            UserDefaults.standard.setValue(characterIndex, forKey: "CHARACTER_INDEX")
			UserDefaults.standard.synchronize()
			self.navigationController?.pushViewController(DashboardController(), animated: true)
			
		}
	}
	
	@objc func btnBackPressed(sender: UIBarButtonItem) {
		self.navigationController?.popViewController(animated: true)
	}
	
	// MARK: UIPickerViewDelegate
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView.tag == 0 {
			return characters.count
		} else if pickerView.tag == 1 {
			return projectsData.count
		} else {
			return 0
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if pickerView.tag == 0 {
			return characters[row]
		} else if pickerView.tag == 1 {
			return projectsData[row]
		} else {
			return ""
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if characters.count == 0 {
            return
        }
		if pickerView.tag == 0 {
			characterIndex = row
			tfCharacter.text = characters[characterIndex]
		} else if pickerView.tag == 1 {
			projectIndex = row
			tfProject.text = projectsData[projectIndex]
		} else {
			
		}
	}
	
	// control orientation
	override var shouldAutorotate: Bool {
		return false
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}
	
}

