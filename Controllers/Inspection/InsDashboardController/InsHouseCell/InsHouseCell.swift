//
//  InsHouseCell.swift
//  Home-Maintenance
//
//  Created by Bani on 26/10/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
class InsHouseCell: UITableViewCell {
	
	@IBOutlet weak var lblNo: UILabel!
	@IBOutlet weak var lblTime: UILabel!
	@IBOutlet weak var lblBuild: UILabel!
	@IBOutlet weak var lblFloor: UILabel!
	@IBOutlet weak var lblRoom: UILabel!
	@IBOutlet weak var lblProgress: UILabel!
    @IBOutlet weak var ivCheck: UIImageView!
    override func awakeFromNib() {
		super.awakeFromNib()
		initLayout()
	}
	
	func initLayout() {
		
		
	}
	
	
	
}
