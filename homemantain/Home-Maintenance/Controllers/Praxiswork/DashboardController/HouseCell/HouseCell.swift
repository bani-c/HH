//
//  HouseCell.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit

class HouseCell: UICollectionViewCell {

	@IBOutlet weak var lblUnrepaired: UILabel!
	@IBOutlet weak var lblRepaired: UILabel!
	@IBOutlet weak var lcProgress: NSLayoutConstraint!
	@IBOutlet weak var vwProgressFrame: UIView!
	@IBOutlet weak var lblNo: UILabel!
	@IBOutlet weak var vwDash: UIView!
	var standardProgressWidth:CGFloat = 0.0
    override func awakeFromNib() {
        super.awakeFromNib()
        initLayout()
    }
	
	func initLayout() {
		//init standardProgressWidth
		standardProgressWidth = lcProgress.constant
		
		//init vwDash layout
		vwDash.layer.borderColor = UIColor(red: 144/255, green: 33/255, blue: 38/255, alpha: 1).cgColor
		vwDash.layer.borderWidth = 1.0
		vwDash.clipsToBounds = true
		vwDash.layer.cornerRadius = 10.0
		
		//init vwProgressFrame layout
		vwProgressFrame.layer.borderColor = UIColor(red: 144/255, green: 33/255, blue: 38/255, alpha: 1).cgColor
		vwProgressFrame.layer.borderWidth = 1.0
		
	}
	
	// MARK: Custom Functions
	func isStartPair(start:Bool)
	{
		vwProgressFrame.isHidden = start
		lblRepaired.isHidden = start
		lblUnrepaired.isHidden = start
	}
	
	func setProgress(rate:Float) {
		
		lcProgress.constant = standardProgressWidth * CGFloat(rate)
		self.setNeedsUpdateConstraints()
	}
	
	func setRoom(name:String) {
		lblNo.text = name
	}
	
	func setRepair(no:Int) {
		lblRepaired.text = String(format: "%@: %d", NSLocalizedString("fixed", comment: ""), no)
	}
	
	func setUnrepair(no:Int) {
		lblUnrepaired.text = String(format: "%@: %d", NSLocalizedString("no_fix", comment: ""), no)
	}

}
