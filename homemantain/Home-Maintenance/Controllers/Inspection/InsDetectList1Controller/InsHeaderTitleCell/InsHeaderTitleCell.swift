//
//  InsHouseCell.swift
//  Home-Maintenance
//
//  Created by Bani on 26/10/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
class InsHeaderTitleCell: UITableViewCell {
	@IBOutlet weak var lblTitle: UILabel!
	@IBOutlet weak var btnCheck: UIButton!
	@IBOutlet weak var btnMiss: UIButton!
	@IBOutlet weak var btnCamera: UIButton!
	override func awakeFromNib() {
		super.awakeFromNib()
		initLayout()
	}
	
	func initLayout() {
		
		
	}
	
	@IBAction func btnCheckPressed(_ sender: Any) {
		self.btnCheck.setImage(UIImage.init(named: "check_red"), for: UIControlState.normal)
		self.btnMiss.setImage(UIImage.init(named: "missing_gray"), for: UIControlState.normal)
		self.btnCamera.isHidden = true
	}
	
	@IBAction func btnMissPressed(_ sender: Any) {
		self.btnCheck.setImage(UIImage.init(named: "check_gray"), for: UIControlState.normal)
		self.btnMiss.setImage(UIImage.init(named: "missing_red"), for: UIControlState.normal)
		self.btnCamera.isHidden = false
		self.btnCamera.setImage(UIImage.init(named: "camera_red"), for: UIControlState.normal)
	}
	
	@IBAction func btnCameraPressed(_ sender: Any) {
		self.btnCamera.setImage(UIImage.init(named: "enclosure"), for: UIControlState.normal)
	}
}
