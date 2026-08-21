//
//  InsHouseCell.swift
//  Home-Maintenance
//
//  Created by Bani on 26/10/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
class InsDetect0ItemCell: UITableViewCell {
	@IBOutlet weak var lblTitle: UILabel!
	@IBOutlet weak var btnCheck: UIButton!
	@IBOutlet weak var btnMiss: UIButton!
	@IBOutlet weak var btnCamera: UIButton!
	@IBOutlet weak var tfNumber: UITextField!
	@IBOutlet weak var lblStatus: UILabel!
    public var isRecord = false
	
    @IBOutlet weak var lblLessAmount: UILabel!
    override func awakeFromNib() {
		super.awakeFromNib()
		initLayout()
	}
	
	func initLayout() {
		
		
	}
	
	public func setCheck(InsItem :InsItem) {
		self.btnMiss.isHidden = false
		self.lblStatus.isHidden = true
		self.tfNumber.isHidden = true
        self.lblLessAmount.text = ""
        if isRecord {
            self.tfNumber.isEnabled = false
        }
		if InsItem.check {
			if InsItem.result == 0 {
				self.btnCheck.setImage(UIImage.init(named: "check_red"), for: UIControlState.normal)
				self.btnMiss.setImage(UIImage.init(named: "missing_gray"), for: UIControlState.normal)
				self.btnCamera.isHidden = true
			} else {
				self.btnCheck.setImage(UIImage.init(named: "check_gray"), for: UIControlState.normal)
				if InsItem.amount.count != 0 && InsItem.amount != "0" {
                    if InsItem.CheckEquipType == "2" {
                        self.btnMiss.isHidden = true
                        self.lblStatus.isHidden = false
                        self.lblStatus.text = "缺少"
                        self.tfNumber.text = String(InsItem.detect_amount)
                        self.btnCamera.isHidden = true
                        self.tfNumber.isHidden = false
                    } else {
                        if InsItem.detect_amount != 0 {
                            self.lblLessAmount.text = String.init(format: "缺少:%d", InsItem.detect_amount)
                        }
                        self.btnMiss.setImage(UIImage.init(named: "missing_red"), for: UIControlState.normal)
                        self.btnCamera.isHidden = false
                        if InsItem.desId != "" || InsItem.inspRemark != "" || InsItem.picUrl != "" {
                            self.btnCamera.setImage(UIImage.init(named: "enclosure"), for: UIControlState.normal)
                        } else {
                            self.btnCamera.setImage(UIImage.init(named: "edit"), for: UIControlState.normal)
                        }
                    }
				} else {
					self.btnMiss.setImage(UIImage.init(named: "missing_red"), for: UIControlState.normal)
					self.btnCamera.isHidden = false
					if InsItem.desId != "" || InsItem.inspRemark != "" || InsItem.picUrl != "" {
						self.btnCamera.setImage(UIImage.init(named: "enclosure"), for: UIControlState.normal)
					} else {
						self.btnCamera.setImage(UIImage.init(named: "edit"), for: UIControlState.normal)
					}
				}
			}
		} else {
			self.btnCamera.isHidden = true
			self.btnCheck.setImage(UIImage.init(named: "check_gray"), for: UIControlState.normal)
			self.btnMiss.setImage(UIImage.init(named: "missing_gray"), for: UIControlState.normal)
		}
	}

}
