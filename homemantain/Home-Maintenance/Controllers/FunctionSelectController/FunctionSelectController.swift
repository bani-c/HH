//
//  ViewController.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit

class FunctionSelectController: UIViewController {
	// MARK: Variables
	@IBOutlet weak var btnMaintain: UIButton!
	@IBOutlet weak var btnInspection: UIButton!
	@IBOutlet weak var btnMIS: UIButton!
	@IBOutlet weak var btnLogout: UIButton!
	
	// MARK: Life Circle
	override func viewDidLoad() {
		super.viewDidLoad()
		initLayaout()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: Custom Functions
	func initLayaout() {
		//init btnFMaintan
		btnMaintain.clipsToBounds = true
		btnMaintain.layer.cornerRadius = 5.0
		
		//init btnFInspection
		btnInspection.clipsToBounds = true
		btnInspection.layer.cornerRadius = 5.0
	}
	
	// MARK: Button Actions
	@IBAction func clickMaintain(_ sender: Any) {
		self.navigationController?.pushViewController(ChooseProjectController(), animated: true)
	}
	
	@IBAction func clickInspection(_ sender: Any) {
		self.navigationController?.pushViewController(InsChooseProjectController(), animated: true)
	}
    
    @IBAction func clickNews(_ sender: Any) {
        self.navigationController?.pushViewController(NewsController.init(), animated: true)
    }
	
	@IBAction func clickMIS(_ sender: Any) {
		self.navigationController?.pushViewController(MISController(), animated: true)
	}
	
	@IBAction func clickLogout(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	
}

