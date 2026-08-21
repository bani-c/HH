//
//  ChecklistItemCell.swift
//  Home-Maintenance
//
//  Created by Yuchi Chen on 2017/9/18.
//  Copyright © 2017年 Ultron mobile. All rights reserved.
//

import UIKit

class ChecklistItemCell: UITableViewCell {

    @IBOutlet var btnFix: CustomButton!
    @IBOutlet var btnFile: CustomButton!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var sgIsFixed: UISegmentedControl!
    
	@IBOutlet weak var btnFixedBefore: CustomButton!
	@IBOutlet weak var btnFixedAfter: CustomButton!
	//MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        initLayout()
    }
    
    //MARK: Custom Functions
    func initLayout() {
        //init btnFix
        btnFix.layer.borderColor = UIColor(red:0.65, green:0.22, blue:0.22, alpha:1.00).cgColor
        btnFix.layer.borderWidth = 1.0
        
        //init sgIsFixed layout
        let font = UIFont.systemFont(ofSize: 18.0)
        sgIsFixed.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        
        sgIsFixed.isHidden = true
        btnFixedAfter.isHidden = true
        btnFixedBefore.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTitle(_ title:String) {
        lblTitle.text = title;
    }
    
    func setLayout(_ insItem:InsItem) {
        if insItem.isFixed == "Y" {
            btnFix.backgroundColor = UIColor.init(red: 162.0/255.0, green: 53.0/255.0, blue: 54.0/255.0, alpha: 1.0)
            btnFix.setTitleColor(UIColor.white, for: .normal)
            btnFix.setTitle("已修正", for: .normal)
        }
        else {
            btnFix.backgroundColor = UIColor.white
            btnFix.setTitleColor(UIColor.init(red: 162.0/255.0, green: 53.0/255.0, blue: 54.0/255.0, alpha: 1.0), for: .normal)
            btnFix.setTitle("修正", for: .normal)
            
        }
        if insItem.desId != "" || insItem.inspRemark != "" || insItem.picUrl != "" || (insItem.amount != "" && insItem.amount != "0")  {
            btnFile.isHidden = false
            
        } else {
            btnFile.isHidden = true
        }
    }
    
    func setIsFixed(_ isFixed:Bool) {
        if isFixed == true {
            btnFile.isHidden = true
            sgIsFixed.isHidden = false
			btnFixedAfter.isHidden = false
			btnFixedBefore.isHidden = false
        }
        else {
            btnFile.isHidden = false
            sgIsFixed.isHidden = true
			btnFixedAfter.isHidden = true
			btnFixedBefore.isHidden = true
        }
    }
}
