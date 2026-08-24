//
//  ChecklistSubtitleCell.swift
//  Home-Maintenance
//
//  Created by Yuchi Chen on 2017/9/18.
//  Copyright © 2017年 Ultron mobile. All rights reserved.
//

import UIKit

class ChecklistSubtitleCell: UITableViewCell {

    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblShortCount: UILabel!
    @IBOutlet var vwShortCount: UIView!
    @IBOutlet var vwSeparateLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initLayout()
    }

    func initLayout () {
        //init vwShortCount
        vwShortCount.layer.borderColor = UIColor(red:0.65, green:0.22, blue:0.22, alpha:1.00).cgColor
        vwShortCount.layer.borderWidth = 1.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setShortCount(_ count: Int) {
		lblShortCount.text = NSLocalizedString("missing_count", comment: "") + "：\(count)"
    }
    
    func setTitle(_ title: String) {
        lblTitle.text = title
    }
}
