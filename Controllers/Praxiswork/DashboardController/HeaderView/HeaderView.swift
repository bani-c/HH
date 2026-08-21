//
//  HeaderView.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {
	@IBOutlet weak var lblTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	// MARK: Custom Functions
	func setBuilding(name:String) {
		lblTitle.text = name
	}
    
}
